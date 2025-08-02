import { Request, Response, NextFunction } from 'express';
import { CacheService } from '../../infrastructure/cache/memory-cache.service';
import { StatusCodes } from '../config/constant';

interface RateLimitOptions {
    windowMs: number; // Time window in milliseconds
    maxRequests: number; // Maximum requests per window
    message?: string; // Custom error message
    keyGenerator?: (req: Request) => string; // Custom key generator
    skipSuccessfulRequests?: boolean; // Don't count successful requests
    skipFailedRequests?: boolean; // Don't count failed requests
}

interface RateLimitInfo {
    count: number;
    resetTime: number;
    firstRequest: number;
}

export class RateLimitMiddleware {
    private cacheService: CacheService;
    private options: Required<RateLimitOptions>;

    constructor(cacheService: CacheService, options: RateLimitOptions) {
        this.cacheService = cacheService;
        this.options = {
            windowMs: options.windowMs,
            maxRequests: options.maxRequests,
            message: options.message || 'Too many requests, please try again later.',
            keyGenerator: options.keyGenerator || this.defaultKeyGenerator,
            skipSuccessfulRequests: options.skipSuccessfulRequests || false,
            skipFailedRequests: options.skipFailedRequests || false
        };
    }

    private defaultKeyGenerator(req: Request): string {
        // Use IP address and user ID (if available) for rate limiting
        const ip = req.ip || req.connection.remoteAddress || 'unknown';
        const userId = req.user?.id || 'anonymous';
        return `rate_limit:${ip}:${userId}`;
    }

    middleware = () => {
        return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
            try {
                const key = this.options.keyGenerator(req);
                const now = Date.now();
                
                // Get current rate limit info
                let rateLimitInfo = await this.cacheService.get<RateLimitInfo>(key);
                
                if (!rateLimitInfo) {
                    // First request in the window
                    rateLimitInfo = {
                        count: 1,
                        resetTime: now + this.options.windowMs,
                        firstRequest: now
                    };
                } else {
                    // Check if window has expired
                    if (now > rateLimitInfo.resetTime) {
                        // Reset the window
                        rateLimitInfo = {
                            count: 1,
                            resetTime: now + this.options.windowMs,
                            firstRequest: now
                        };
                    } else {
                        // Increment count
                        rateLimitInfo.count++;
                    }
                }

                // Check if limit exceeded
                if (rateLimitInfo.count > this.options.maxRequests) {
                    const resetTimeSeconds = Math.ceil((rateLimitInfo.resetTime - now) / 1000);
                    
                    res.status(StatusCodes.TOO_MANY_REQUESTS).json({
                        success: false,
                        message: this.options.message,
                        retryAfter: resetTimeSeconds,
                        limit: this.options.maxRequests,
                        remaining: 0,
                        resetTime: new Date(rateLimitInfo.resetTime).toISOString()
                    });
                    return;
                }

                // Store updated rate limit info
                const ttlSeconds = Math.ceil((rateLimitInfo.resetTime - now) / 1000);
                await this.cacheService.set(key, rateLimitInfo, ttlSeconds);

                // Add rate limit headers
                const remaining = Math.max(0, this.options.maxRequests - rateLimitInfo.count);
                const resetTimeSeconds = Math.ceil((rateLimitInfo.resetTime - now) / 1000);

                res.set({
                    'X-RateLimit-Limit': this.options.maxRequests.toString(),
                    'X-RateLimit-Remaining': remaining.toString(),
                    'X-RateLimit-Reset': Math.ceil(rateLimitInfo.resetTime / 1000).toString(),
                    'X-RateLimit-RetryAfter': resetTimeSeconds.toString()
                });

                // Handle response tracking if needed
                if (this.options.skipSuccessfulRequests || this.options.skipFailedRequests) {
                    this.setupResponseTracking(req, res, key, rateLimitInfo);
                }

                next();
            } catch (error) {
                console.error('Rate limiting error:', error);
                // Don't block requests if rate limiting fails
                next();
            }
        };
    };

    private setupResponseTracking(req: Request, res: Response, key: string, rateLimitInfo: RateLimitInfo): void {
        const originalSend = res.send;
        const self = this;
        
        res.send = function(body: any) {
            const statusCode = res.statusCode;
            const isSuccessful = statusCode >= 200 && statusCode < 300;
            const isFailed = statusCode >= 400;

            // Adjust count based on response
            if ((isSuccessful && self.options.skipSuccessfulRequests) ||
                (isFailed && self.options.skipFailedRequests)) {
                rateLimitInfo.count = Math.max(0, rateLimitInfo.count - 1);
                
                // Update cache with adjusted count
                const now = Date.now();
                const ttlSeconds = Math.ceil((rateLimitInfo.resetTime - now) / 1000);
                self.cacheService.set(key, rateLimitInfo, ttlSeconds).catch(console.error);
            }

            return originalSend.call(this, body);
        };
    }
}

// Predefined rate limit configurations
export const RateLimitConfigs = {
    // General API rate limiting
    GENERAL: {
        windowMs: 15 * 60 * 1000, // 15 minutes
        maxRequests: 1000, // 1000 requests per 15 minutes
        message: 'تم تجاوز الحد المسموح من الطلبات. يرجى المحاولة لاحقاً.'
    },

    // Authentication endpoints (more restrictive)
    AUTH: {
        windowMs: 15 * 60 * 1000, // 15 minutes
        maxRequests: 10, // 10 login attempts per 15 minutes
        message: 'تم تجاوز عدد محاولات تسجيل الدخول. يرجى المحاولة بعد 15 دقيقة.'
    },

    // Product creation (for admins)
    PRODUCT_CREATE: {
        windowMs: 60 * 60 * 1000, // 1 hour
        maxRequests: 50, // 50 products per hour
        message: 'تم تجاوز الحد المسموح لإنشاء المنتجات. يرجى المحاولة بعد ساعة.'
    },

    // File upload
    FILE_UPLOAD: {
        windowMs: 60 * 60 * 1000, // 1 hour
        maxRequests: 100, // 100 uploads per hour
        message: 'تم تجاوز الحد المسموح لرفع الملفات. يرجى المحاولة بعد ساعة.'
    },

    // Search endpoints
    SEARCH: {
        windowMs: 60 * 1000, // 1 minute
        maxRequests: 30, // 30 searches per minute
        message: 'تم تجاوز الحد المسموح للبحث. يرجى المحاولة بعد دقيقة.'
    },

    // Password reset
    PASSWORD_RESET: {
        windowMs: 60 * 60 * 1000, // 1 hour
        maxRequests: 3, // 3 password reset attempts per hour
        message: 'تم تجاوز عدد محاولات إعادة تعيين كلمة المرور. يرجى المحاولة بعد ساعة.'
    }
};

// Factory functions for creating rate limiters
export const createRateLimit = (cacheService: CacheService, config: RateLimitOptions) => {
    const rateLimiter = new RateLimitMiddleware(cacheService, config);
    return rateLimiter.middleware();
};

// IP-based rate limiter
export const createIPRateLimit = (cacheService: CacheService, config: RateLimitOptions) => {
    const ipConfig = {
        ...config,
        keyGenerator: (req: Request) => {
            const ip = req.ip || req.connection.remoteAddress || 'unknown';
            return `rate_limit:ip:${ip}`;
        }
    };
    
    const rateLimiter = new RateLimitMiddleware(cacheService, ipConfig);
    return rateLimiter.middleware();
};

// User-based rate limiter
export const createUserRateLimit = (cacheService: CacheService, config: RateLimitOptions) => {
    const userConfig = {
        ...config,
        keyGenerator: (req: Request) => {
            const userId = req.user?.id || 'anonymous';
            return `rate_limit:user:${userId}`;
        }
    };
    
    const rateLimiter = new RateLimitMiddleware(cacheService, userConfig);
    return rateLimiter.middleware();
};