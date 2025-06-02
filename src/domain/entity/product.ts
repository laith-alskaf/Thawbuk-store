import { ProductInfoDTO } from "../../application/dtos/product.dto";
export interface IAgeRange {
  minAge: number;
  maxAge: number;
}
export interface IProduct {
  _id: string;
  name: string;
  description: string;
  price: number;
  categoryId: string;
  createdBy: string;
  images: string[];
  sizes: string[];
  colors: string[];
  stock: number;
  brand?: string;
  ageRange?: IAgeRange; 
  createdAt: Date;
  updatedAt: Date;

}

export class ProductMapper {
  static toDTO(product: IProduct): ProductInfoDTO {
    return {
      _id: product._id,
      name: product.name,
      stockQuantity: product.stock,
      description: product.description,
      price: product.price,
      categoryId: product.categoryId,
      images: product.images ,
    };
  }
}