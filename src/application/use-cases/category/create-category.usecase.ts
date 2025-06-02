import { CategoryRepository } from "../../../domain/repository/category.repository";
import { CreateCategoryDTO } from "../../dtos/category.dto";
import { IdGeneratorService } from "../../../domain/services/id-generator.service";

export class CreateCategoryUseCase {
    constructor(
        private readonly categoryRepository: CategoryRepository,
        private readonly uuidGeneratorService: IdGeneratorService,
    ) { }
    execute = async (createCategoryDTO: Partial<CreateCategoryDTO>): Promise<void> => {

        const category = {
            ...createCategoryDTO,
            _id: this.uuidGeneratorService.generate(),
        }
        console.log(category);

        await this.categoryRepository.create(category);

    }
}