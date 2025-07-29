import { CategoryInfoDTO } from "../../application/dtos/category.dto";

export interface ICategory {
  _id: string;
  name: string;
  nameAr: string;
  description: string | null;
  descriptionAr: string | null;
  image: string;
  productsCount?: number;
  createdBy: string,
  createdAt?: Date;
  updatedAt?: Date;
}

export class CategoryMapper {
  static toDTO(category: ICategory): CategoryInfoDTO {
    return {
      _id: category._id,
      name: category.name,
      nameAr: category.nameAr,
      description: category.description,
      descriptionAr: category.descriptionAr,
      image: category.image,
      productsCount: category.productsCount,
    };
  }
}
