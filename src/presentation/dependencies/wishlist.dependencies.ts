import { WishlistController } from '../controllers/wishlist.controller';
import { MongoWishlistRepository } from '../../infrastructure/repositories/mongo/mongo-wishlist.repository';
import {
    GetWishlistUseCase,
    RemoveAllProductfromWishlistUseCase,
    RemoveProductFromWishlistUseCase,
    AddProductToWishlistUseCase,
    ToggleWishlistUseCase
} from "../../application/use-cases/wishlist";
import { ProductRepository } from '../../domain/repository/product.repository';
import { WishlistRepository } from '../../domain/repository/wishlist.repository';

interface WishlistDependenciesType {
    wishlistRepository: WishlistRepository;
    productRepository: ProductRepository;
}

export const WishlistDependencies = ({
    wishlistRepository,
    productRepository,
}: WishlistDependenciesType): WishlistController => {

    // Use Cases
    const addProductToWishlistUseCase = new AddProductToWishlistUseCase(wishlistRepository, productRepository);
    const getWishlistUseCase = new GetWishlistUseCase(wishlistRepository);
    const removeAllProductfromWishlistUseCase = new RemoveAllProductfromWishlistUseCase(wishlistRepository);
    const removeProductFromWishlistUseCase = new RemoveProductFromWishlistUseCase(wishlistRepository, productRepository);
    const toggleWishlistUseCase = new ToggleWishlistUseCase(wishlistRepository, productRepository);

    const wishlistController: WishlistController = new WishlistController(
        addProductToWishlistUseCase,
        getWishlistUseCase,
        removeAllProductfromWishlistUseCase,
        removeProductFromWishlistUseCase,
        toggleWishlistUseCase
    );


    return wishlistController;


}
