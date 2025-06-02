import { CategoryMapper } from "../../../domain/entity/category";
import { CategoryRepository } from "../../../domain/repository/category.repository";
import { CategoryInfoDTO } from "../../dtos/category.dto";

export class GetCategoryByIdUseCase {
    constructor(
        private readonly categoryRepository: CategoryRepository,
    ) { }
    execute = async (categoryId: string): Promise<CategoryInfoDTO | null> => {
        const updatedCategory = await this.categoryRepository.findById(categoryId);
        if (!updatedCategory) throw new Error("Category not found");
        const categoryData: CategoryInfoDTO = CategoryMapper.toDTO(updatedCategory);
        return categoryData;

    }
}