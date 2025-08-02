import { ProductRepository } from "../../../domain/repository/product.repository";
import { WishlistRepository } from "../../../domain/repository/wishlist.repository";
import { IProduct } from "../../../domain/entity/product";

export interface ToggleWishlistResult {
    isFavorite: boolean;
    favoritesCount: number;
}

export class ToggleWishlistUseCase {
    constructor(
        private readonly wishlistRepository: WishlistRepository,
        private readonly productRepository: ProductRepository
    ) { }

    execute = async (userId: string, productId: string): Promise<ToggleWishlistResult> => {
        const wishlist = await this.wishlistRepository.findById(userId);
        if (!wishlist) {
            // This case should ideally not happen for a logged-in user
            // but as a fallback, create a wishlist
            await this.wishlistRepository.create(userId);
        }

        const product = await this.productRepository.findById(productId);
        if (!product) {
            throw new Error("Product not found");
        }

        const isCurrentlyFavorite = wishlist?.productsId.some(p => p.toString() === productId);

        if (isCurrentlyFavorite) {
            await this.wishlistRepository.removeProdut(userId, productId);
            await this.productRepository.decrementFavoritesCount(productId);
        } else {
            await this.wishlistRepository.add(userId, productId);
            await this.productRepository.incrementFavoritesCount(productId);
        }

        const updatedProduct = await this.productRepository.findById(productId);
        
        return {
            isFavorite: !isCurrentlyFavorite,
            favoritesCount: updatedProduct?.favoritesCount ?? product.favoritesCount ?? 0,
        };
    }
}
