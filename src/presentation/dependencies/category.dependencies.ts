import { CategoryController } from '../controllers/category.controller';
import { CategoryRepository } from '../../domain/repository/category.repository';

import {
    GetAllCategoriesUseCase,
    CreateCategoryUseCase,
    DeleteCategoryUseCase,
    GetCategoryByIdUseCase,
    UpdateCategoryUseCase,
} from '../../application/use-cases/category';
import { UuidGeneratorService } from '../../infrastructure/srevices/uuid-generator.service';
import { CloudService } from '../../domain/services/cloud.service';



interface CategoryDependenciesType {
    uuidGeneratorService: UuidGeneratorService
    categoryRepository: CategoryRepository;
    uploudImageService: CloudService
}

export const CategoryDependencies = ({
    uuidGeneratorService,
    categoryRepository,
    uploudImageService
}: CategoryDependenciesType): CategoryController => {

    // Use Cases
    const getAllCategoriesUseCase = new GetAllCategoriesUseCase(categoryRepository);
    const updateCategoryUseCase = new UpdateCategoryUseCase(categoryRepository);
    const deleteCategoryUseCase = new DeleteCategoryUseCase(categoryRepository);
    const createCategoryUseCase = new CreateCategoryUseCase(categoryRepository, uuidGeneratorService, uploudImageService);
    const getCategoryByIdUseCase = new GetCategoryByIdUseCase(categoryRepository);

    const categoryController: CategoryController = new CategoryController(
        getAllCategoriesUseCase,
        createCategoryUseCase,
        deleteCategoryUseCase,
        getCategoryByIdUseCase,
        updateCategoryUseCase,
    );


    return categoryController;


}