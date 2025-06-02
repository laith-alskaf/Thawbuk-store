import { CategoryMapper } from "../../../domain/entity/category";
import { CategoryRepository } from "../../../domain/repository/category.repository";
import { Messages } from "../../../presentation/config/constant";
import { CategoryInfoDTO } from "../../dtos/category.dto";

export class GetAllCategoriesUseCase {
    constructor(
        private readonly categoryRepository: CategoryRepository,
    ) { }
    execute = async (): Promise<CategoryInfoDTO[] | null> => {
        const categories = await this.categoryRepository.allCategory();
        if (!categories) throw new Error(Messages.CATEGORY.NOT_FOUND_CATEGORIES_EN);

        const categoryData: CategoryInfoDTO[] = categories.map(CategoryMapper.toDTO);;
        return categoryData;

    }
}