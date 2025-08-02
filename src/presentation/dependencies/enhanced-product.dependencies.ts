import { EnhancedProductController } from '../controllers/enhanced-product.controller';
import { UuidGeneratorService } from '../../infrastructure/srevices/uuid-generator.service';
import { ProductRepository } from '../../domain/repository/product.repository';

import {
    GetProductByIdUseCase,
    GetProductsByCategoryIdUseCase,
    GetFilteredProductsUseCase,
    GetProductsByUserIdUseCase,
    GetAllProductsUseCase,
    SearchProductsUseCase,
} from "../../application/use-cases/product";

// Enhanced Use Cases
import { EnhancedCreateProductUseCase } from '../../application/use-cases/product/enhanced-create-product.usecase';
import { EnhancedUpdateProductUseCase } from '../../application/use-cases/product/enhanced-update-product.usecase';
import { EnhancedDeleteProductUseCase } from '../../application/use-cases/product/enhanced-delete-product.usecase';

// Enhanced Services
import { EnhancedSearchService } from '../../application/services/enhanced-search.service';
import { CacheService, InMemoryCacheService } from '../../infrastructure/cache/memory-cache.service';
import { CachedProductRepository } from '../../infrastructure/repositories/cached/cached-product.repository';

import { NotificationService } from '../../domain/services/notification.service';
import { CloudService } from '../../domain/services/cloud.service';

interface EnhancedProductDependenciesType {
    productRepository: ProductRepository;
    uuidGeneratorService: UuidGeneratorService;
    newProductNotification: NotificationService;
    uploadImageService: CloudService;
    cacheService?: CacheService;
}

export const EnhancedProductDependencies = ({
    productRepository,
    uuidGeneratorService,
    newProductNotification,
    uploadImageService,
    cacheService
}: EnhancedProductDependenciesType): EnhancedProductController => {

    // Initialize cache service if not provided
    const cache = cacheService || new InMemoryCacheService();

    // Create cached repository wrapper
    const cachedProductRepository = new CachedProductRepository(productRepository, cache);

    // Standard Use Cases (using cached repository)
    const getProductByIdUseCase = new GetProductByIdUseCase(cachedProductRepository);
    const getProductsByCategoryIdUseCase = new GetProductsByCategoryIdUseCase(cachedProductRepository);
    const getFilteredProductsUseCase = new GetFilteredProductsUseCase(cachedProductRepository);
    const getProductsByUserIdUseCase = new GetProductsByUserIdUseCase(cachedProductRepository);
    const getAllProductsUseCase = new GetAllProductsUseCase(cachedProductRepository);
    const searchProductsUseCase = new SearchProductsUseCase(cachedProductRepository);

    // Enhanced Use Cases (using original repository for write operations)
    const enhancedCreateProductUseCase = new EnhancedCreateProductUseCase(
        cachedProductRepository, // This will handle cache invalidation
        uuidGeneratorService, 
        newProductNotification, 
        uploadImageService
    );
    const enhancedUpdateProductUseCase = new EnhancedUpdateProductUseCase(cachedProductRepository);
    const enhancedDeleteProductUseCase = new EnhancedDeleteProductUseCase(cachedProductRepository);

    // Enhanced Services
    const enhancedSearchService = new EnhancedSearchService(cachedProductRepository, cache);

    // Enhanced Controller
    const enhancedProductController = new EnhancedProductController(
        getProductByIdUseCase,
        getProductsByCategoryIdUseCase,
        getFilteredProductsUseCase,
        getProductsByUserIdUseCase,
        getAllProductsUseCase,
        searchProductsUseCase,
        // Enhanced Use Cases
        enhancedCreateProductUseCase,
        enhancedUpdateProductUseCase,
        enhancedDeleteProductUseCase,
        // Enhanced Services
        enhancedSearchService
    );

    return enhancedProductController;
};