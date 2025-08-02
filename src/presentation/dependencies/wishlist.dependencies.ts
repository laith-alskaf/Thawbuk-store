import { WishlistController } from '../controllers/wishlist.controller';
import { MongoWishlistRepository } from '../../infrastructure/repositories/mongo/mongo-wishlist.repository';
import {
    GetWishlistUseCase,
    RemoveAllProductfromWishlistUseCase,
    RemoveProductFromWishlistUseCase,
    AddProductToWishlistUseCase
} from "../../application/use-cases/wishlist";
import { WishlistRepository } from '../../domain/repository/wishlist.repository';

interface WishlistDependenciesType {
    wishlistRepository: WishlistRepository;
}

export const WishlistDependencies = ({
    wishlistRepository,
}: WishlistDependenciesType): WishlistController => {

    // Use Cases
    const addProductToWishlistUseCase = new AddProductToWishlistUseCase(wishlistRepository);
    const getWishlistUseCase = new GetWishlistUseCase(wishlistRepository);
    const removeAllProductfromWishlistUseCase = new RemoveAllProductfromWishlistUseCase(wishlistRepository);
    const removeProductFromWishlistUseCase = new RemoveProductFromWishlistUseCase(wishlistRepository);

    const wishlistController: WishlistController = new WishlistController(
        addProductToWishlistUseCase,
        getWishlistUseCase,
        removeAllProductfromWishlistUseCase,
        removeProductFromWishlistUseCase
    );


    return wishlistController;


}