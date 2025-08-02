import { IProduct } from "../../domain/entity/product";
import { ProductRepository } from "../../domain/repository/product.repository";
import { CacheService, InMemoryCacheService } from "../../infrastructure/cache/memory-cache.service";

export interface SearchFilters {
    category?: string;
    minPrice?: number;
    maxPrice?: number;
    sizes?: string[];
    colors?: string[];
    brands?: string[];
    inStock?: boolean;
    rating?: number;
    sortBy?: 'newest' | 'oldest' | 'priceAsc' | 'priceDesc' | 'rating' | 'popularity';
}

export interface SearchOptions {
    page?: number;
    limit?: number;
    includeInactive?: boolean;
    fuzzySearch?: boolean;
}

export interface SearchResult {
    products: IProduct[];
    total: number;
    page: number;
    totalPages: number;
    hasNextPage: boolean;
    hasPrevPage: boolean;
    filters: SearchFilters;
    searchTime: number;
    suggestions?: string[];
}

export class EnhancedSearchService {
    private readonly CACHE_TTL = 5 * 60; // 5 minutes
    private readonly SEARCH_HISTORY_LIMIT = 100;

    constructor(
        private readonly productRepository: ProductRepository,
        private readonly cacheService: CacheService
    ) {}

    async search(
        query: string,
        filters: SearchFilters = {},
        options: SearchOptions = {}
    ): Promise<SearchResult> {
        const startTime = Date.now();
        
        // Normalize and validate inputs
        const normalizedQuery = this.normalizeQuery(query);
        const validatedFilters = this.validateFilters(filters);
        const searchOptions = this.normalizeOptions(options);

        // Generate cache key
        const cacheKey = this.generateSearchCacheKey(normalizedQuery, validatedFilters, searchOptions);

        try {
            // Try to get from cache first
            const cachedResult = await this.cacheService.get<SearchResult>(cacheKey);
            if (cachedResult) {
                // Update search time for cached result
                cachedResult.searchTime = Date.now() - startTime;
                return cachedResult;
            }

            // Perform search
            const searchResult = await this.performSearch(normalizedQuery, validatedFilters, searchOptions);
            
            // Calculate search metrics
            const searchTime = Date.now() - startTime;
            const totalPages = Math.ceil(searchResult.total / searchOptions.limit);

            const result: SearchResult = {
                products: searchResult.products,
                total: searchResult.total,
                page: searchOptions.page,
                totalPages,
                hasNextPage: searchOptions.page < totalPages,
                hasPrevPage: searchOptions.page > 1,
                filters: validatedFilters,
                searchTime,
                suggestions: await this.generateSuggestions(normalizedQuery, searchResult.total)
            };

            // Cache the result
            await this.cacheService.set(cacheKey, result, this.CACHE_TTL);

            // Store search analytics
            await this.storeSearchAnalytics(normalizedQuery, validatedFilters, searchResult.total, searchTime);

            return result;
        } catch (error: any) {
            console.error('Search error:', error);
            throw error;
        }
    }

    private async performSearch(
        query: string,
        filters: SearchFilters,
        options: SearchOptions
    ): Promise<{ products: IProduct[]; total: number }> {
        // Build MongoDB query
        const mongoQuery: any = {};

        // Text search
        if (query && query.trim()) {
            // Use MongoDB text search or regex
            mongoQuery.$or = [
                { name: { $regex: query, $options: 'i' } },
                { nameAr: { $regex: query, $options: 'i' } },
                { description: { $regex: query, $options: 'i' } },
                { descriptionAr: { $regex: query, $options: 'i' } },
                { brand: { $regex: query, $options: 'i' } }
            ];
        }

        // Category filter
        if (filters.category) {
            mongoQuery.categoryId = filters.category;
        }

        // Price range filter
        if (filters.minPrice !== undefined || filters.maxPrice !== undefined) {
            mongoQuery.price = {};
            if (filters.minPrice !== undefined) {
                mongoQuery.price.$gte = filters.minPrice;
            }
            if (filters.maxPrice !== undefined) {
                mongoQuery.price.$lte = filters.maxPrice;
            }
        }

        // Size filter
        if (filters.sizes && filters.sizes.length > 0) {
            mongoQuery.sizes = { $in: filters.sizes };
        }

        // Color filter
        if (filters.colors && filters.colors.length > 0) {
            mongoQuery.colors = { $in: filters.colors };
        }

        // Brand filter
        if (filters.brands && filters.brands.length > 0) {
            mongoQuery.brand = { $in: filters.brands };
        }

        // Stock filter
        if (filters.inStock === true) {
            mongoQuery.stock = { $gt: 0 };
        }

        // Rating filter
        if (filters.rating !== undefined) {
            mongoQuery.rating = { $gte: filters.rating };
        }

        // Active products only (unless specified otherwise)
        if (!options.includeInactive) {
            mongoQuery.isActive = { $ne: false };
        }

        // Perform the search using repository
        const result = await this.productRepository.allProduct(options.page!, options.limit!, mongoQuery);
        return result || { products: [], total: 0 };
    }

    private normalizeQuery(query: string): string {
        if (!query) return '';
        
        return query
            .trim()
            .toLowerCase()
            .replace(/[^\w\s\u0600-\u06FF]/g, '') // Keep only alphanumeric and Arabic characters
            .replace(/\s+/g, ' '); // Replace multiple spaces with single space
    }

    private validateFilters(filters: SearchFilters): SearchFilters {
        const validated: SearchFilters = {};

        if (filters.category && typeof filters.category === 'string') {
            validated.category = filters.category.trim();
        }

        if (filters.minPrice !== undefined && filters.minPrice >= 0) {
            validated.minPrice = Math.max(0, filters.minPrice);
        }

        if (filters.maxPrice !== undefined && filters.maxPrice >= 0) {
            validated.maxPrice = Math.max(0, filters.maxPrice);
        }

        // Ensure minPrice <= maxPrice
        if (validated.minPrice !== undefined && validated.maxPrice !== undefined) {
            if (validated.minPrice > validated.maxPrice) {
                [validated.minPrice, validated.maxPrice] = [validated.maxPrice, validated.minPrice];
            }
        }

        if (filters.sizes && Array.isArray(filters.sizes)) {
            validated.sizes = filters.sizes.filter(size => typeof size === 'string' && size.trim());
        }

        if (filters.colors && Array.isArray(filters.colors)) {
            validated.colors = filters.colors.filter(color => typeof color === 'string' && color.trim());
        }

        if (filters.brands && Array.isArray(filters.brands)) {
            validated.brands = filters.brands.filter(brand => typeof brand === 'string' && brand.trim());
        }

        if (typeof filters.inStock === 'boolean') {
            validated.inStock = filters.inStock;
        }

        if (filters.rating !== undefined && filters.rating >= 0 && filters.rating <= 5) {
            validated.rating = Math.max(0, Math.min(5, filters.rating));
        }

        if (filters.sortBy && ['newest', 'oldest', 'priceAsc', 'priceDesc', 'rating', 'popularity'].includes(filters.sortBy)) {
            validated.sortBy = filters.sortBy;
        }

        return validated;
    }

    private normalizeOptions(options: SearchOptions): Required<SearchOptions> {
        return {
            page: Math.max(1, options.page || 1),
            limit: Math.min(100, Math.max(1, options.limit || 20)),
            includeInactive: options.includeInactive || false,
            fuzzySearch: options.fuzzySearch || false
        };
    }

    private generateSearchCacheKey(query: string, filters: SearchFilters, options: SearchOptions): string {
        const keyParts = [
            'search',
            query || 'empty',
            JSON.stringify(filters),
            `page:${options.page}`,
            `limit:${options.limit}`,
            `inactive:${options.includeInactive}`,
            `fuzzy:${options.fuzzySearch}`
        ];

        return InMemoryCacheService.generateKey('search', ...keyParts.map(String));
    }

    private async generateSuggestions(query: string, resultCount: number): Promise<string[]> {
        if (resultCount > 0 || !query) return [];

        try {
            // Get popular search terms from cache
            const popularTerms = await this.getPopularSearchTerms();
            
            // Simple suggestion algorithm - find similar terms
            const suggestions = popularTerms
                .filter(term => 
                    term.toLowerCase().includes(query.toLowerCase()) ||
                    query.toLowerCase().includes(term.toLowerCase())
                )
                .slice(0, 5);

            return suggestions;
        } catch (error) {
            console.error('Error generating suggestions:', error);
            return [];
        }
    }

    private async getPopularSearchTerms(): Promise<string[]> {
        try {
            const cacheKey = 'search:popular_terms';
            const cached = await this.cacheService.get<string[]>(cacheKey);
            
            if (cached) return cached;

            // In a real implementation, you would get this from analytics data
            const defaultTerms = [
                'قميص', 'بنطلون', 'فستان', 'حذاء', 'حقيبة',
                'shirt', 'pants', 'dress', 'shoes', 'bag'
            ];

            await this.cacheService.set(cacheKey, defaultTerms, 60 * 60); // 1 hour
            return defaultTerms;
        } catch (error) {
            console.error('Error getting popular search terms:', error);
            return [];
        }
    }

    private async storeSearchAnalytics(
        query: string,
        filters: SearchFilters,
        resultCount: number,
        searchTime: number
    ): Promise<void> {
        try {
            const analyticsKey = `search:analytics:${Date.now()}`;
            const analytics = {
                query,
                filters,
                resultCount,
                searchTime,
                timestamp: new Date().toISOString()
            };

            // Store for 24 hours
            await this.cacheService.set(analyticsKey, analytics, 24 * 60 * 60);

            // Update search frequency counter
            if (query.trim()) {
                const frequencyKey = `search:frequency:${query.toLowerCase()}`;
                await this.cacheService.increment(frequencyKey);
            }
        } catch (error) {
            console.error('Error storing search analytics:', error);
        }
    }

    // Get search analytics
    async getSearchAnalytics(days: number = 7): Promise<any> {
        try {
            // This would typically query a proper analytics database
            // For now, return basic stats from cache
            const stats = {
                totalSearches: 0,
                averageSearchTime: 0,
                popularQueries: await this.getPopularSearchTerms(),
                noResultQueries: []
            };

            return stats;
        } catch (error) {
            console.error('Error getting search analytics:', error);
            return null;
        }
    }

    // Clear search cache
    async clearSearchCache(): Promise<void> {
        await this.cacheService.deletePattern('search:*');
        console.log('Search cache cleared');
    }

    // Auto-complete suggestions
    async getAutocompleteSuggestions(query: string, limit: number = 10): Promise<string[]> {
        if (!query || query.length < 2) return [];

        try {
            const cacheKey = `autocomplete:${query.toLowerCase()}`;
            const cached = await this.cacheService.get<string[]>(cacheKey);
            
            if (cached) return cached.slice(0, limit);

            // Get suggestions from product names
            const suggestions = await this.getProductNameSuggestions(query, limit);
            
            // Cache for 1 hour
            await this.cacheService.set(cacheKey, suggestions, 60 * 60);
            
            return suggestions;
        } catch (error) {
            console.error('Error getting autocomplete suggestions:', error);
            return [];
        }
    }

    private async getProductNameSuggestions(query: string, limit: number): Promise<string[]> {
        try {
            // This would ideally use a proper search index
            // For now, use a simple regex search
            const mongoQuery = {
                $or: [
                    { name: { $regex: query, $options: 'i' } },
                    { nameAr: { $regex: query, $options: 'i' } }
                ],
                isActive: { $ne: false }
            };

            const result = await this.productRepository.allProduct(1, limit * 2, mongoQuery);
            
            if (!result) return [];

            // Extract unique product names that match the query
            const suggestions = new Set<string>();
            
            result.products.forEach(product => {
                if (product.name.toLowerCase().includes(query.toLowerCase())) {
                    suggestions.add(product.name);
                }
                if (product.nameAr && product.nameAr.toLowerCase().includes(query.toLowerCase())) {
                    suggestions.add(product.nameAr);
                }
            });

            return Array.from(suggestions).slice(0, limit);
        } catch (error) {
            console.error('Error getting product name suggestions:', error);
            return [];
        }
    }
}