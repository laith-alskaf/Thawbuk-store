import { IProduct, ProductMapper } from "../../../domain/entity/product";
import { WishlistRepository } from "../../../domain/repository/wishlist.repository";
import { ProductInfoDTO } from "../../dtos/product.dto";
import { WishlistDTO } from "../../dtos/wishlist.dto";

export class GetWishlistUseCase {
    constructor(
        private readonly wishlistRepository: WishlistRepository,
    ) { }
    execute = async (userId: string): Promise<WishlistDTO> => {
        var wishlist;
        wishlist = await this.wishlistRepository.findById(userId);

        if (!wishlist) {
            wishlist = await this.wishlistRepository.create(userId);
            console.log("GetWishlistUseCase - Wishlist created:", wishlist);
        }

        const products: IProduct[] = wishlist.productsId as [];
        const productsData: ProductInfoDTO[] = products.map(ProductMapper.toDTO);
        return { products: productsData };

    }
}