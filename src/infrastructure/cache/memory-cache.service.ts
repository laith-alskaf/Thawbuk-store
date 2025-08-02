export interface CacheService {
    get<T>(key: string): Promise<T | null>;
    set(key: string, value: any, ttlSeconds?: number): Promise<void>;
    delete(key: string): Promise<void>;
    deletePattern(pattern: string): Promise<void>;
    exists(key: string): Promise<boolean>;
    increment(key: string, value?: number): Promise<number>;
    expire(key: string, ttlSeconds: number): Promise<void>;
    getOrSet<T>(key: string, fetchFunction: () => Promise<T>, ttlSeconds?: number): Promise<T>;
}

// In-Memory Cache Service (production ready)
export class InMemoryCacheService implements CacheService {
    private cache: Map<string, { value: any; expiry: number }> = new Map();
    private cleanupInterval: NodeJS.Timeout;
    private maxSize: number;
    private hitCount: number = 0;
    private missCount: number = 0;

    constructor(maxSize: number = 10000) {
        this.maxSize = maxSize;
        
        // Clean up expired entries every 5 minutes
        this.cleanupInterval = setInterval(() => {
            this.cleanup();
        }, 5 * 60 * 1000);

        // Log cache stats every 30 minutes
        setInterval(() => {
            this.logStats();
        }, 30 * 60 * 1000);
    }

    private cleanup(): void {
        const now = Date.now();
        let cleanedCount = 0;
        
        for (const [key, entry] of this.cache.entries()) {
            if (entry.expiry < now) {
                this.cache.delete(key);
                cleanedCount++;
            }
        }

        if (cleanedCount > 0) {
            console.log(`Cache cleanup: removed ${cleanedCount} expired entries`);
        }

        // If cache is still too large, remove oldest entries
        if (this.cache.size > this.maxSize) {
            this.evictOldest();
        }
    }

    private evictOldest(): void {
        const entries = Array.from(this.cache.entries());
        entries.sort((a, b) => a[1].expiry - b[1].expiry);
        
        const toRemove = entries.slice(0, Math.floor(this.maxSize * 0.1)); // Remove 10%
        toRemove.forEach(([key]) => this.cache.delete(key));
        
        console.log(`Cache eviction: removed ${toRemove.length} oldest entries`);
    }

    private logStats(): void {
        const total = this.hitCount + this.missCount;
        const hitRate = total > 0 ? (this.hitCount / total * 100).toFixed(2) : '0.00';
        
        console.log(`Cache Stats - Size: ${this.cache.size}, Hit Rate: ${hitRate}%, Hits: ${this.hitCount}, Misses: ${this.missCount}`);
    }

    async get<T>(key: string): Promise<T | null> {
        const entry = this.cache.get(key);
        
        if (!entry) {
            this.missCount++;
            return null;
        }

        if (entry.expiry < Date.now()) {
            this.cache.delete(key);
            this.missCount++;
            return null;
        }

        this.hitCount++;
        return entry.value as T;
    }

    async set(key: string, value: any, ttlSeconds: number = 3600): Promise<void> {
        // Check if cache is full
        if (this.cache.size >= this.maxSize && !this.cache.has(key)) {
            this.evictOldest();
        }

        const expiry = Date.now() + (ttlSeconds * 1000);
        this.cache.set(key, { value, expiry });
    }

    async delete(key: string): Promise<void> {
        this.cache.delete(key);
    }

    async deletePattern(pattern: string): Promise<void> {
        const regex = new RegExp(pattern.replace(/\*/g, '.*'));
        const keysToDelete: string[] = [];
        
        for (const key of this.cache.keys()) {
            if (regex.test(key)) {
                keysToDelete.push(key);
            }
        }

        keysToDelete.forEach(key => this.cache.delete(key));
        
        if (keysToDelete.length > 0) {
            console.log(`Cache pattern delete: removed ${keysToDelete.length} entries matching ${pattern}`);
        }
    }

    async exists(key: string): Promise<boolean> {
        const entry = this.cache.get(key);
        if (!entry) return false;

        if (entry.expiry < Date.now()) {
            this.cache.delete(key);
            return false;
        }

        return true;
    }

    async increment(key: string, value: number = 1): Promise<number> {
        const current = await this.get<number>(key) || 0;
        const newValue = current + value;
        await this.set(key, newValue);
        return newValue;
    }

    async expire(key: string, ttlSeconds: number): Promise<void> {
        const entry = this.cache.get(key);
        if (entry) {
            entry.expiry = Date.now() + (ttlSeconds * 1000);
        }
    }

    async getOrSet<T>(
        key: string, 
        fetchFunction: () => Promise<T>, 
        ttlSeconds: number = 3600
    ): Promise<T> {
        try {
            // Try to get from cache first
            const cached = await this.get<T>(key);
            if (cached !== null) {
                return cached;
            }

            // If not in cache, fetch the data
            const data = await fetchFunction();
            
            // Store in cache for next time
            await this.set(key, data, ttlSeconds);
            
            return data;
        } catch (error) {
            console.error(`Error in getOrSet for key ${key}:`, error);
            // If cache fails, still return the fetched data
            return await fetchFunction();
        }
    }

    // Generate cache keys
    static generateKey(prefix: string, ...parts: (string | number)[]): string {
        return `${prefix}:${parts.join(':')}`;
    }

    // Cache key patterns for products
    static readonly KEYS = {
        PRODUCT: {
            BY_ID: (id: string) => InMemoryCacheService.generateKey('product', 'id', id),
            BY_CATEGORY: (categoryId: string, page: number, limit: number) => 
                InMemoryCacheService.generateKey('product', 'category', categoryId, page, limit),
            BY_USER: (userId: string, page: number, limit: number) => 
                InMemoryCacheService.generateKey('product', 'user', userId, page, limit),
            ALL: (page: number, limit: number, filter: string) => 
                InMemoryCacheService.generateKey('product', 'all', page, limit, filter),
            SEARCH: (query: string, page: number, limit: number) => 
                InMemoryCacheService.generateKey('product', 'search', query, page, limit),
            PATTERN: 'product:*'
        },
        CATEGORY: {
            BY_ID: (id: string) => InMemoryCacheService.generateKey('category', 'id', id),
            ALL: () => InMemoryCacheService.generateKey('category', 'all'),
            PATTERN: 'category:*'
        },
        USER: {
            BY_ID: (id: string) => InMemoryCacheService.generateKey('user', 'id', id),
            PATTERN: 'user:*'
        }
    };

    // Get cache statistics
    getStats() {
        const total = this.hitCount + this.missCount;
        return {
            size: this.cache.size,
            maxSize: this.maxSize,
            hitCount: this.hitCount,
            missCount: this.missCount,
            hitRate: total > 0 ? (this.hitCount / total * 100).toFixed(2) + '%' : '0.00%'
        };
    }

    // Clear all cache
    clear(): void {
        this.cache.clear();
        this.hitCount = 0;
        this.missCount = 0;
        console.log('Cache cleared');
    }

    destroy(): void {
        if (this.cleanupInterval) {
            clearInterval(this.cleanupInterval);
        }
        this.cache.clear();
        console.log('Cache service destroyed');
    }
}