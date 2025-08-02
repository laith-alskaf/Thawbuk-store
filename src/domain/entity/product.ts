import { ProductInfoDTO } from "../../application/dtos/product.dto";
export interface IAgeRange {
  minAge: number;
  maxAge: number;
}
export interface IProduct {
  _id: string;
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
  rating?: number;
  reviewsCount?: number;
  favoritesCount?: number;
  viewsCount?: number;
  isActive?: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export class ProductMapper {
  static toDTO(product: IProduct): ProductInfoDTO {
    return {
      _id: product._id,
      name: product.name,
      stock: product.stock,
      description: product.description,
      price: product.price,
      categoryId: product.categoryId,
      images: product.images,
      sizes: product.sizes,
      colors: product.colors,
      brand: product.brand,
      ageRange: product.ageRange,
      nameAr: product.nameAr,
      descriptionAr: product.descriptionAr,
      rating: product.rating,
      reviewsCount: product.reviewsCount,
      favoritesCount: product.favoritesCount,
      viewsCount: product.viewsCount,
      isActive: product.isActive,
    };
  }
}
