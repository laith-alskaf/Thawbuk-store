// import { createClient, RedisClientType } from 'redis';
// import { CONFIG } from '../../presentation/config/env';

// export interface CacheService {
//     get<T>(key: string): Promise<T | null>;
//     set(key: string, value: any, ttlSeconds?: number): Promise<void>;
//     delete(key: string): Promise<void>;
//     deletePattern(pattern: string): Promise<void>;
//     exists(key: string): Promise<boolean>;
//     increment(key: string, value?: number): Promise<number>;
//     expire(key: string, ttlSeconds: number): Promise<void>;
// }

// export class RedisCacheService implements CacheService {
//     private client: RedisClientType;
//     private isConnected: boolean = false;

//     constructor() {
//         this.client = createClient({
//             url: CONFIG.REDIS_URL || 'redis://localhost:6379',
//             socket: {
//                 connectTimeout: 5000,
//                 lazyConnect: true
//             }
//         });

//         this.client.on('error', (err) => {
//             console.error('Redis Client Error:', err);
//             this.isConnected = false;
//         });

//         this.client.on('connect', () => {
//             console.log('Redis Client Connected');
//             this.isConnected = true;
//         });

//         this.client.on('disconnect', () => {
//             console.log('Redis Client Disconnected');
//             this.isConnected = false;
//         });
//     }

//     async connect(): Promise<void> {
//         try {
//             if (!this.isConnected) {
//                 await this.client.connect();
//             }
//         } catch (error) {
//             console.error('Failed to connect to Redis:', error);
//             throw error;
//         }
//     }

//     async disconnect(): Promise<void> {
//         try {
//             if (this.isConnected) {
//                 await this.client.disconnect();
//             }
//         } catch (error) {
//             console.error('Failed to disconnect from Redis:', error);
//         }
//     }

//     async get<T>(key: string): Promise<T | null> {
//         try {
//             if (!this.isConnected) {
//                 await this.connect();
//             }

//             const value = await this.client.get(key);
//             if (!value) return null;

//             return JSON.parse(value) as T;
//         } catch (error) {
//             console.error(`Error getting cache key ${key}:`, error);
//             return null; // Fail gracefully
//         }
//     }

//     async set(key: string, value: any, ttlSeconds: number = 3600): Promise<void> {
//         try {
//             if (!this.isConnected) {
//                 await this.connect();
//             }

//             const serializedValue = JSON.stringify(value);
//             await this.client.setEx(key, ttlSeconds, serializedValue);
//         } catch (error) {
//             console.error(`Error setting cache key ${key}:`, error);
//             // Don't throw error to avoid breaking the main flow
//         }
//     }

//     async delete(key: string): Promise<void> {
//         try {
//             if (!this.isConnected) {
//                 await this.connect();
//             }

//             await this.client.del(key);
//         } catch (error) {
//             console.error(`Error deleting cache key ${key}:`, error);
//         }
//     }

//     async deletePattern(pattern: string): Promise<void> {
//         try {
//             if (!this.isConnected) {
//                 await this.connect();
//             }

//             const keys = await this.client.keys(pattern);
//             if (keys.length > 0) {
//                 await this.client.del(keys);
//             }
//         } catch (error) {
//             console.error(`Error deleting cache pattern ${pattern}:`, error);
//         }
//     }

//     async exists(key: string): Promise<boolean> {
//         try {
//             if (!this.isConnected) {
//                 await this.connect();
//             }

//             const result = await this.client.exists(key);
//             return result === 1;
//         } catch (error) {
//             console.error(`Error checking cache key existence ${key}:`, error);
//             return false;
//         }
//     }

//     async increment(key: string, value: number = 1): Promise<number> {
//         try {
//             if (!this.isConnected) {
//                 await this.connect();
//             }

//             return await this.client.incrBy(key, value);
//         } catch (error) {
//             console.error(`Error incrementing cache key ${key}:`, error);
//             return 0;
//         }
//     }

//     async expire(key: string, ttlSeconds: number): Promise<void> {
//         try {
//             if (!this.isConnected) {
//                 await this.connect();
//             }

//             await this.client.expire(key, ttlSeconds);
//         } catch (error) {
//             console.error(`Error setting expiration for cache key ${key}:`, error);
//         }
//     }

//     // Helper methods for common cache patterns
//     async getOrSet<T>(
//         key: string, 
//         fetchFunction: () => Promise<T>, 
//         ttlSeconds: number = 3600
//     ): Promise<T> {
//         try {
//             // Try to get from cache first
//             const cached = await this.get<T>(key);
//             if (cached !== null) {
//                 return cached;
//             }

//             // If not in cache, fetch the data
//             const data = await fetchFunction();
            
//             // Store in cache for next time
//             await this.set(key, data, ttlSeconds);
            
//             return data;
//         } catch (error) {
//             console.error(`Error in getOrSet for key ${key}:`, error);
//             // If cache fails, still return the fetched data
//             return await fetchFunction();
//         }
//     }

//     // Generate cache keys
//     static generateKey(prefix: string, ...parts: (string | number)[]): string {
//         return `${prefix}:${parts.join(':')}`;
//     }

//     // Cache key patterns for products
//     static readonly KEYS = {
//         PRODUCT: {
//             BY_ID: (id: string) => RedisCacheService.generateKey('product', 'id', id),
//             BY_CATEGORY: (categoryId: string, page: number, limit: number) => 
//                 RedisCacheService.generateKey('product', 'category', categoryId, page, limit),
//             BY_USER: (userId: string, page: number, limit: number) => 
//                 RedisCacheService.generateKey('product', 'user', userId, page, limit),
//             ALL: (page: number, limit: number, filter: string) => 
//                 RedisCacheService.generateKey('product', 'all', page, limit, filter),
//             SEARCH: (query: string, page: number, limit: number) => 
//                 RedisCacheService.generateKey('product', 'search', query, page, limit),
//             PATTERN: 'product:*'
//         },
//         CATEGORY: {
//             BY_ID: (id: string) => RedisCacheService.generateKey('category', 'id', id),
//             ALL: () => RedisCacheService.generateKey('category', 'all'),
//             PATTERN: 'category:*'
//         },
//         USER: {
//             BY_ID: (id: string) => RedisCacheService.generateKey('user', 'id', id),
//             PATTERN: 'user:*'
//         }
//     };
// }

// // In-Memory Cache Service (fallback when Redis is not available)
// export class InMemoryCacheService implements CacheService {
//     private cache: Map<string, { value: any; expiry: number }> = new Map();
//     private cleanupInterval: NodeJS.Timeout;

//     constructor() {
//         // Clean up expired entries every 5 minutes
//         this.cleanupInterval = setInterval(() => {
//             this.cleanup();
//         }, 5 * 60 * 1000);
//     }

//     private cleanup(): void {
//         const now = Date.now();
//         for (const [key, entry] of this.cache.entries()) {
//             if (entry.expiry < now) {
//                 this.cache.delete(key);
//             }
//         }
//     }

//     async get<T>(key: string): Promise<T | null> {
//         const entry = this.cache.get(key);
//         if (!entry) return null;

//         if (entry.expiry < Date.now()) {
//             this.cache.delete(key);
//             return null;
//         }

//         return entry.value as T;
//     }

//     async set(key: string, value: any, ttlSeconds: number = 3600): Promise<void> {
//         const expiry = Date.now() + (ttlSeconds * 1000);
//         this.cache.set(key, { value, expiry });
//     }

//     async delete(key: string): Promise<void> {
//         this.cache.delete(key);
//     }

//     async deletePattern(pattern: string): Promise<void> {
//         const regex = new RegExp(pattern.replace('*', '.*'));
//         for (const key of this.cache.keys()) {
//             if (regex.test(key)) {
//                 this.cache.delete(key);
//             }
//         }
//     }

//     async exists(key: string): Promise<boolean> {
//         const entry = this.cache.get(key);
//         if (!entry) return false;

//         if (entry.expiry < Date.now()) {
//             this.cache.delete(key);
//             return false;
//         }

//         return true;
//     }

//     async increment(key: string, value: number = 1): Promise<number> {
//         const current = await this.get<number>(key) || 0;
//         const newValue = current + value;
//         await this.set(key, newValue);
//         return newValue;
//     }

//     async expire(key: string, ttlSeconds: number): Promise<void> {
//         const entry = this.cache.get(key);
//         if (entry) {
//             entry.expiry = Date.now() + (ttlSeconds * 1000);
//         }
//     }

//     destroy(): void {
//         if (this.cleanupInterval) {
//             clearInterval(this.cleanupInterval);
//         }
//         this.cache.clear();
//     }
// }