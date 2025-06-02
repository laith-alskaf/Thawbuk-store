import { CategoryInfoDTO } from "../../application/dtos/category.dto";

export interface ICategory {
  _id: string;
  name: string;
  description: string | null;
  image: string ;
  createdBy: string,
  createdAt?: Date;
  updatedAt?: Date;
}

export class CategoryMapper {
  static toDTO(category: ICategory): CategoryInfoDTO {
    return {
      _id: category._id,
      name: category.name,
      description: category.description,
      // image: category.image
    };
  }
}