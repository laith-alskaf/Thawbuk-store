import { IAgeRange } from "../../domain/entity/product";

export interface CreateProductDTO {
    name: string;
    nameAr: string;
    description: string;
    descriptionAr: string;
    price: number;
    categoryId: string;
    createdBy: string;
    images: string[];
    sizes: string[];
    colors: string[];
    stock: number;
    brand?: string;
    ageRange?: IAgeRange;
    isActive?: boolean;
}


export interface UpdateProductDTO {
    productId: string,
    product: Partial<ProductInfoDTO>,
    updatedAt?: Date
}
export interface ProductInfoDTO {
    _id: string,
    name: string;
    nameAr: string;
    description: string;
    descriptionAr: string;
    price: number;
    categoryId: string;
    images: string[];
    sizes: string[];
    colors: string[];
    stock: number;
    brand?: string;
    ageRange?: IAgeRange;
    rating?: number;
    reviewsCount?: number;
    favoritesCount?: number;
    viewsCount?: number;
    isActive?: boolean;
}
export interface PeginationProductDTO {
    limit: number | 10,
    page: number | 1,
}

export interface SearchProductDTO {
    peginationProduct: PeginationProductDTO,
    name: string,
    categoryId: string | null,
    createdId: string | null,
}

export interface GetProductsByUserIdDTO {
    peginationProduct: PeginationProductDTO,
    filter: { createdBy: string }
}
export interface DeleteProductDTO {
    productId: string
}
