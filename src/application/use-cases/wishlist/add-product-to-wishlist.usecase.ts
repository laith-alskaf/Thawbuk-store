import { ProductRepository } from "../../../domain/repository/product.repository";
import { WishlistRepository } from "../../../domain/repository/wishlist.repository";

export class AddProductToWishlistUseCase {
    constructor(
        private readonly wishlistRepository: WishlistRepository,
        private readonly productRepository: ProductRepository
    ) { }
    execute = async (userId: string, productId: string): Promise<void> => {
        // We can check if the product is already in the wishlist to prevent incrementing the counter multiple times
        const wishlist = await this.wishlistRepository.findById(userId);
        if (!wishlist?.productsId.includes(productId as any)) {
            await this.productRepository.incrementFavoritesCount(productId);
        }
        await this.wishlistRepository.add(userId, productId);
    }
}
