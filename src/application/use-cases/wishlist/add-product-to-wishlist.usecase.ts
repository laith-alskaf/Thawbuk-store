import { WishlistRepository } from "../../../domain/repository/wishlist.repository";

export class AddProductToWishlistUseCase {
    constructor(
        private readonly wishlistRepository: WishlistRepository,
    ) { }
    execute = async (userId: string, productId: string): Promise<void> => {
        await this.wishlistRepository.add(userId, productId);
    }
}