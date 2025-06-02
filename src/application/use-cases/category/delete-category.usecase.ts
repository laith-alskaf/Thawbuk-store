import { CategoryRepository } from "../../../domain/repository/category.repository";
import { DeleteCategoryDTO } from "../../dtos/category.dto";

export class DeleteCategoryUseCase {
    constructor(
        private readonly categoryRepository: CategoryRepository,
    ) { }
    execute = async (categoryId:string): Promise<void> => {
        await this.categoryRepository.delete(categoryId);
    }
}