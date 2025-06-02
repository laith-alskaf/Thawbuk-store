import { WishlistRepository } from "../../../domain/repository/wishlist.repository";

export class RemoveAllProductfromWishlistUseCase {
    constructor(
        private readonly wishlistRepository: WishlistRepository,
    ) { }
    execute = async (userId: string): Promise<void> => {
        await this.wishlistRepository.removeAllProdut(userId);
    }
}