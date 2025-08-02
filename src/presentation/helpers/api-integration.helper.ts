import { Request, Response } from 'express';
import { StatusCodes } from '../config/constant';

export interface ApiResponse<T = any> {
    success: boolean;
    message: string;
    data?: T;
    meta?: {
        page?: number;
        limit?: number;
        total?: number;
        totalPages?: number;
        hasNextPage?: boolean;
        hasPrevPage?: boolean;
    };
    errors?: any[];
    timestamp: string;
}

export class ApiIntegrationHelper {
    // Standardized success response
    static sendSuccess<T>(
        res: Response, 
        data: T, 
        message: string = 'تم بنجاح',
        statusCode: number = StatusCodes.OK,
        meta?: any
    ): void {
        const response: ApiResponse<T> = {
            success: true,
            message,
            data,
            timestamp: new Date().toISOString()
        };

        if (meta) {
            response.meta = meta;
        }

        res.status(statusCode).json(response);
    }

    // Standardized error response
    static sendError(
        res: Response,
        message: string = 'حدث خطأ',
        statusCode: number = StatusCodes.INTERNAL_SERVER_ERROR,
        errors?: any[]
    ): void {
        const response: ApiResponse = {
            success: false,
            message,
            timestamp: new Date().toISOString()
        };

        if (errors && errors.length > 0) {
            response.errors = errors;
        }

        res.status(statusCode).json(response);
    }

    // Paginated response helper
    static sendPaginatedResponse<T>(
        res: Response,
        data: T[],
        total: number,
        page: number,
        limit: number,
        message: string = 'تم تحميل البيانات بنجاح'
    ): void {
        const totalPages = Math.ceil(total / limit);
        
        const meta = {
            page,
            limit,
            total,
            totalPages,
            hasNextPage: page < totalPages,
            hasPrevPage: page > 1
        };

        ApiIntegrationHelper.sendSuccess(res, data, message, StatusCodes.OK, meta);
    }

    // Extract pagination parameters from request
    static extractPaginationParams(req: Request): { page: number; limit: number } {
        const page = Math.max(1, parseInt(req.query.page as string) || 1);
        const limit = Math.min(100, Math.max(1, parseInt(req.query.limit as string) || 20));
        
        return { page, limit };
    }

    // Extract sort parameters from request
    static extractSortParams(req: Request, allowedFields: string[] = []): { sortBy?: string; sortOrder?: 'asc' | 'desc' } {
        const sortBy = req.query.sortBy as string;
        const sortOrder = (req.query.sortOrder as string)?.toLowerCase() === 'desc' ? 'desc' : 'asc';

        if (sortBy && allowedFields.length > 0 && !allowedFields.includes(sortBy)) {
            return {};
        }

        return { sortBy, sortOrder };
    }

    // Extract filter parameters from request
    static extractFilterParams(req: Request, allowedFilters: string[] = []): Record<string, any> {
        const filters: Record<string, any> = {};

        allowedFilters.forEach(filter => {
            const value = req.query[filter];
            if (value !== undefined && value !== null && value !== '') {
                // Handle different data types
                if (typeof value === 'string') {
                    // Try to parse as number
                    const numValue = parseFloat(value);
                    if (!isNaN(numValue)) {
                        filters[filter] = numValue;
                    } else if (value.toLowerCase() === 'true') {
                        filters[filter] = true;
                    } else if (value.toLowerCase() === 'false') {
                        filters[filter] = false;
                    } else {
                        filters[filter] = value;
                    }
                } else {
                    filters[filter] = value;
                }
            }
        });

        return filters;
    }

    // Validate required fields
    static validateRequiredFields(data: any, requiredFields: string[]): string[] {
        const errors: string[] = [];

        requiredFields.forEach(field => {
            if (data[field] === undefined || data[field] === null || data[field] === '') {
                errors.push(`الحقل '${field}' مطلوب`);
            }
        });

        return errors;
    }

    // Sanitize user input
    static sanitizeInput(input: any): any {
        if (typeof input === 'string') {
            return input.trim().replace(/[<>]/g, '');
        }
        
        if (Array.isArray(input)) {
            return input.map(item => ApiIntegrationHelper.sanitizeInput(item));
        }
        
        if (typeof input === 'object' && input !== null) {
            const sanitized: any = {};
            Object.keys(input).forEach(key => {
                sanitized[key] = ApiIntegrationHelper.sanitizeInput(input[key]);
            });
            return sanitized;
        }
        
        return input;
    }

    // Generate cache key for requests
    static generateCacheKey(prefix: string, req: Request): string {
        const keyParts = [
            prefix,
            req.path,
            JSON.stringify(req.query),
            req.user?.id || 'anonymous'
        ];
        
        return keyParts.join(':');
    }

    // Check if request is from mobile app
    static isMobileRequest(req: Request): boolean {
        const userAgent = req.get('User-Agent') || '';
        return /Mobile|Android|iPhone|iPad/.test(userAgent);
    }

    // Get client IP address
    static getClientIP(req: Request): string {
        return req.ip || 
               req.connection.remoteAddress || 
               req.socket.remoteAddress || 
               'unknown';
    }

    // Format validation errors for API response
    static formatValidationErrors(errors: any[]): any[] {
        return errors.map(error => ({
            field: error.path || error.field,
            message: error.message,
            value: error.value,
            code: error.code || 'VALIDATION_ERROR'
        }));
    }

    // Create search metadata
    static createSearchMeta(query: string, filters: any, results: number, searchTime: number): any {
        return {
            query,
            filters,
            resultsCount: results,
            searchTime: `${searchTime}ms`,
            timestamp: new Date().toISOString()
        };
    }

    // Handle file upload response
    static handleFileUploadResponse(
        res: Response,
        uploadedFiles: any[],
        message: string = 'تم رفع الملفات بنجاح'
    ): void {
        const response = {
            success: true,
            message,
            data: {
                files: uploadedFiles,
                count: uploadedFiles.length
            },
            timestamp: new Date().toISOString()
        };

        res.status(StatusCodes.CREATED).json(response);
    }

    // Create audit log entry
    static createAuditLog(req: Request, action: string, resource: string, resourceId?: string): any {
        return {
            userId: req.user?.id || 'anonymous',
            action,
            resource,
            resourceId,
            ip: ApiIntegrationHelper.getClientIP(req),
            userAgent: req.get('User-Agent'),
            timestamp: new Date().toISOString(),
            method: req.method,
            path: req.path,
            query: req.query,
            body: req.body
        };
    }

    // Rate limit headers helper
    static setRateLimitHeaders(res: Response, limit: number, remaining: number, resetTime: number): void {
        res.set({
            'X-RateLimit-Limit': limit.toString(),
            'X-RateLimit-Remaining': remaining.toString(),
            'X-RateLimit-Reset': resetTime.toString()
        });
    }

    // CORS headers helper
    static setCorsHeaders(res: Response): void {
        res.set({
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
            'Access-Control-Max-Age': '86400'
        });
    }

    // Security headers helper
    static setSecurityHeaders(res: Response): void {
        res.set({
            'X-Content-Type-Options': 'nosniff',
            'X-Frame-Options': 'DENY',
            'X-XSS-Protection': '1; mode=block',
            'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
            'Referrer-Policy': 'strict-origin-when-cross-origin'
        });
    }
}