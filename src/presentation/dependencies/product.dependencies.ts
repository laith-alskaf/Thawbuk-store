import { ProductController } from '../controllers/product.controller';
import { UuidGeneratorService } from '../../infrastructure/srevices/uuid-generator.service';
import { ProductRepository } from '../../domain/repository/product.repository';

import {
    GetProductByIdUseCase,
    GetProductsByCategoryIdUseCase,
    GetFilteredProductsUseCase,
    GetProductsByUserIdUseCase,
    DeleteProductUseCase,
    CreateProductUseCase,
    UpdatedProductUseCase,
    GetAllProductsUseCase,
    SearchProductsUseCase,
} from "../../application/use-cases/product";
import { NotificationService } from '../../domain/services/notification.service';
import { CloudService } from '../../domain/services/cloud.service';

interface ProductDependenciesType {
    productRepository: ProductRepository;
    uuidGeneratorService: UuidGeneratorService
    newProductNotification: NotificationService,
    uploudImageService:CloudService
}

export const ProductDependencies = ({
    productRepository,
    uuidGeneratorService,
    newProductNotification,
    uploudImageService
}: ProductDependenciesType): ProductController => {

    // Use Cases
    const getProductByIdUseCase = new GetProductByIdUseCase(productRepository);
    const getProductsByCategoryIdUseCase = new GetProductsByCategoryIdUseCase(productRepository);
    const getFilteredProductsUseCase = new GetFilteredProductsUseCase(productRepository);
    const getProductsByUserIdUseCase = new GetProductsByUserIdUseCase(productRepository);
    const deleteProductUseCase = new DeleteProductUseCase(productRepository);
    const createProductUseCase = new CreateProductUseCase(productRepository, uuidGeneratorService,newProductNotification,uploudImageService);
    const updatedProductUseCase = new UpdatedProductUseCase(productRepository);
    const getAllProductsUseCase = new GetAllProductsUseCase(productRepository);
    const searchProductsUseCase = new SearchProductsUseCase(productRepository);

    const productController: ProductController = new ProductController(
        getProductByIdUseCase,
        getProductsByCategoryIdUseCase,
        getFilteredProductsUseCase,
        getProductsByUserIdUseCase,
        deleteProductUseCase,
        createProductUseCase,
        updatedProductUseCase,
        getAllProductsUseCase,
        searchProductsUseCase
    );


    return productController;


}
