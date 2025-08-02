import { ProductRepository } from "../../../domain/repository/product.repository";
import { WishlistRepository } from "../../../domain/repository/wishlist.repository";

export class RemoveProductFromWishlistUseCase {
    constructor(
        private readonly wishlistRepository: WishlistRepository,
        private readonly productRepository: ProductRepository
    ) { }
    execute = async (userId: string, productId: string): Promise<void> => {
        const wishlist = await this.wishlistRepository.findById(userId);
        if (wishlist?.productsId.includes(productId as any)) {
            await this.productRepository.decrementFavoritesCount(productId);
        }
        await this.wishlistRepository.removeProdut(userId, productId);
    }
}
