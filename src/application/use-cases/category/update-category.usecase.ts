import { CategoryMapper } from "../../../domain/entity/category";
import { CategoryRepository } from "../../../domain/repository/category.repository";
import { CategoryInfoDTO, UpdateCategoryDTO } from "../../dtos/category.dto";

export class UpdateCategoryUseCase {
    constructor(
        private readonly categoryRepository: CategoryRepository,
    ) { }
    execute = async (updateCategoryDTO: Partial<UpdateCategoryDTO>): Promise<CategoryInfoDTO | null> => {
        updateCategoryDTO.updatedAt = new Date();

        const updatedCategory = await this.categoryRepository.update(updateCategoryDTO.categoryId!, updateCategoryDTO);
        if (!updatedCategory) throw new Error("Category not found");
        const categoryData: CategoryInfoDTO = CategoryMapper.toDTO(updatedCategory);
        return categoryData;

    }
}