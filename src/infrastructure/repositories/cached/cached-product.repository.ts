import { IProduct } from "../../../domain/entity/product";
import { ProductRepository } from "../../../domain/repository/product.repository";
import { CacheService, InMemoryCacheService } from "../../cache/memory-cache.service";

export class CachedProductRepository implements ProductRepository {
    private readonly CACHE_TTL = {
        PRODUCT_BY_ID: 30 * 60, // 30 minutes
        PRODUCTS_LIST: 10 * 60, // 10 minutes
        SEARCH_RESULTS: 5 * 60, // 5 minutes
        USER_PRODUCTS: 15 * 60, // 15 minutes
        CATEGORY_PRODUCTS: 20 * 60 // 20 minutes
    };

    constructor(
        private readonly baseRepository: ProductRepository,
        private readonly cacheService: CacheService
    ) {}

    async findById(id: string): Promise<IProduct | null> {
        const cacheKey = InMemoryCacheService.KEYS.PRODUCT.BY_ID(id);
        
        return await this.cacheService.getOrSet(
            cacheKey,
            () => this.baseRepository.findById(id),
            this.CACHE_TTL.PRODUCT_BY_ID
        );
    }

    async allProduct(page: number, limit: number, filter: {}): Promise<{ products: IProduct[], total: number } | null> {
        const filterHash = this.generateFilterHash(filter);
        const cacheKey = InMemoryCacheService.KEYS.PRODUCT.ALL(page, limit, filterHash);
        
        return await this.cacheService.getOrSet(
            cacheKey,
            () => this.baseRepository.allProduct(page, limit, filter),
            this.CACHE_TTL.PRODUCTS_LIST
        );
    }

    async findByUserId(page: number, limit: number, filter: any): Promise<{ products: IProduct[], total: number } | null> {
        const userId = filter.createdBy || 'unknown';
        const cacheKey = InMemoryCacheService.KEYS.PRODUCT.BY_USER(userId, page, limit);
        
        return await this.cacheService.getOrSet(
            cacheKey,
            () => this.baseRepository.findByUserId(page, limit, filter),
            this.CACHE_TTL.USER_PRODUCTS
        );
    }

    async findByCategoryId(categoryId: string): Promise<IProduct[] | null> {
        const cacheKey = InMemoryCacheService.KEYS.PRODUCT.BY_CATEGORY(categoryId, 1, 100);
        
        return await this.cacheService.getOrSet(
            cacheKey,
            () => this.baseRepository.findByCategoryId(categoryId),
            this.CACHE_TTL.CATEGORY_PRODUCTS
        );
    }

    async filter(params: any): Promise<IProduct[]> {
        const paramsHash = this.generateFilterHash(params);
        const cacheKey = InMemoryCacheService.generateKey('product', 'filter', paramsHash);
        
        return await this.cacheService.getOrSet(
            cacheKey,
            () => this.baseRepository.filter(params),
            this.CACHE_TTL.SEARCH_RESULTS
        );
    }

    async search(name: string, categoryId: string, createdId: string, page: number, limit: number): Promise<{ products: IProduct[], total: number }> {
        const cacheKey = InMemoryCacheService.KEYS.PRODUCT.SEARCH(
            `${name}-${categoryId}-${createdId}`, 
            page, 
            limit
        );
        
        return await this.cacheService.getOrSet(
            cacheKey,
            async () => {
                // Use allProduct with search filters instead of search method
                const filter: any = {};
                
                if (name) {
                    filter.$or = [
                        { name: { $regex: name, $options: 'i' } },
                        { nameAr: { $regex: name, $options: 'i' } }
                    ];
                }
                
                if (categoryId) {
                    filter.categoryId = categoryId;
                }
                
                if (createdId) {
                    filter.createdBy = createdId;
                }
                
                const result = await this.baseRepository.allProduct(page, limit, filter);
                return result || { products: [], total: 0 };
            },
            this.CACHE_TTL.SEARCH_RESULTS
        );
    }

    // Write operations - invalidate cache
    async create(product: Partial<IProduct>): Promise<IProduct> {
        const result = await this.baseRepository.create(product);
        
        // Invalidate related caches
        await this.invalidateProductCaches(result);
        
        return result;
    }

    async update(productId: string, productData: Partial<IProduct>): Promise<IProduct | null> {
        const result = await this.baseRepository.update(productId, productData);
        
        if (result) {
            // Invalidate related caches
            await this.invalidateProductCaches(result);
        }
        
        return result;
    }

    async delete(id: string): Promise<void> {
        // Get product before deletion for cache invalidation
        const product = await this.baseRepository.findById(id);
        
        await this.baseRepository.delete(id);
        
        if (product) {
            // Invalidate related caches
            await this.invalidateProductCaches(product);
        }
    }

    async incrementFavoritesCount(productId: string): Promise<void> {
        await this.baseRepository.incrementFavoritesCount(productId);
        
        // Invalidate specific product cache
        const cacheKey = InMemoryCacheService.KEYS.PRODUCT.BY_ID(productId);
        await this.cacheService.delete(cacheKey);
    }

    async decrementFavoritesCount(productId: string): Promise<void> {
        await this.baseRepository.decrementFavoritesCount(productId);
        
        // Invalidate specific product cache
        const cacheKey = InMemoryCacheService.KEYS.PRODUCT.BY_ID(productId);
        await this.cacheService.delete(cacheKey);
    }

    // Helper methods
    private async invalidateProductCaches(product: IProduct): Promise<void> {
        try {
            // Invalidate specific product cache
            const productCacheKey = InMemoryCacheService.KEYS.PRODUCT.BY_ID(product._id);
            await this.cacheService.delete(productCacheKey);

            // Invalidate category-related caches
            if (product.categoryId) {
                const categoryPattern = `product:category:${product.categoryId}:*`;
                await this.cacheService.deletePattern(categoryPattern);
            }

            // Invalidate user-related caches
            if (product.createdBy) {
                const userPattern = `product:user:${product.createdBy}:*`;
                await this.cacheService.deletePattern(userPattern);
            }

            // Invalidate general product list caches
            await this.cacheService.deletePattern('product:all:*');
            await this.cacheService.deletePattern('product:search:*');
            await this.cacheService.deletePattern('product:filter:*');

            console.log(`Cache invalidated for product: ${product._id}`);
        } catch (error) {
            console.error('Error invalidating product caches:', error);
        }
    }

    private generateFilterHash(filter: any): string {
        try {
            // Create a consistent hash from filter object
            const sortedFilter = Object.keys(filter)
                .sort()
                .reduce((result: any, key) => {
                    result[key] = filter[key];
                    return result;
                }, {});
            
            return Buffer.from(JSON.stringify(sortedFilter)).toString('base64').slice(0, 16);
        } catch (error) {
            console.error('Error generating filter hash:', error);
            return 'default';
        }
    }

    // Cache management methods
    async clearProductCache(): Promise<void> {
        await this.cacheService.deletePattern(InMemoryCacheService.KEYS.PRODUCT.PATTERN);
        console.log('Product cache cleared');
    }

    async warmupCache(): Promise<void> {
        try {
            console.log('Starting cache warmup...');
            
            // Warmup popular products (first page)
            await this.allProduct(1, 20, {});
            
            // You can add more warmup logic here based on your app's usage patterns
            
            console.log('Cache warmup completed');
        } catch (error) {
            console.error('Error during cache warmup:', error);
        }
    }
}