import { WishlistRepository } from "../../../domain/repository/wishlist.repository";

export class RemoveProductFromWishlistUseCase {
    constructor(
        private readonly wishlistRepository: WishlistRepository,
    ) { }
    execute = async (userId: string, productId: string): Promise<void> => {
        await this.wishlistRepository.removeProdut(userId, productId);

    }
}