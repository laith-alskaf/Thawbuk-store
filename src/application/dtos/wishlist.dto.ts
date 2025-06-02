import { ProductInfoDTO } from "./product.dto";

export interface ProductWishlistDTO {
    productId: string,
}

export interface WishlistDTO {
    products: ProductInfoDTO[];
}