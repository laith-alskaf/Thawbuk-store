import { IWishlist } from '../../../domain/entity/wishlist';
import { WishlistRepository } from '../../../domain/repository/wishlist.repository';
import { WishlistModel } from '../../database/mongodb/models/wishlist.model';

export class MongoWishlistRepository implements WishlistRepository {

    async create(userId: string): Promise<IWishlist> {
        const wishlist = new WishlistModel({
            userId,
            productsId: [],
        });
        await wishlist.save();
        return wishlist;
    }

    async findById(userId: string): Promise<IWishlist | null> {
        console.log(userId);
        return await WishlistModel.findOne({ userId: userId }).populate('productsId');
    }

    async add(userId: string, productId: string): Promise<void> {
        await WishlistModel.updateOne(
            { userId },
            { $addToSet: { productsId: productId } }
        );

    }

    async removeProdut(userId: string, productId: string): Promise<void> {
        await WishlistModel.updateOne(
            { userId },
            { $pull: { productsId: productId } }
        );
    }

    async removeAllProdut(userId: string): Promise<void> {
        await WishlistModel.updateOne(
            { userId },
            { $set: { productsId: [] } }
        );
    }



}
