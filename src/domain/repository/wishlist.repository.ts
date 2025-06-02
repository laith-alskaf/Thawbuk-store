import { IWishlist } from "../entity/wishlist";

export interface WishlistRepository {
    findById(id: string): Promise<IWishlist | null>;
    create(id: string): Promise<IWishlist>;
    add(userId: string, productId: string): Promise<void>;
    removeProdut(userId: string, productId: string): Promise<void>;
    removeAllProdut(userId: string): Promise<void>;
}