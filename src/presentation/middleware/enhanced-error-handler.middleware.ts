import { Request, Response, NextFunction } from 'express';
import { StatusCodes } from '../config/constant';
import { 
    ApplicationError,
    ValidationError,
    BadRequestError,
    UnauthorizedError,
    ForbiddenError,
    ProductNotFoundError,
    InsufficientPermissionsError
} from '../../application/errors/application-error';

interface ErrorResponse {
    success: false;
    message: string;
    error?: {
        type: string;
        details?: any;
        stack?: string;
    };
    timestamp: string;
    path: string;
    method: string;
}

export class EnhancedErrorHandler {
    static handle(error: any, req: Request, res: Response, next: NextFunction): void {
        console.error('Error occurred:', {
            message: error.message,
            stack: error.stack,
            path: req.path,
            method: req.method,
            body: req.body,
            query: req.query,
            params: req.params,
            user: req.user?.id || 'anonymous'
        });

        const errorResponse: ErrorResponse = {
            success: false,
            message: 'حدث خطأ غير متوقع',
            timestamp: new Date().toISOString(),
            path: req.path,
            method: req.method
        };

        // Handle different error types
        if (error instanceof ApplicationError) {
            errorResponse.message = error.message;
            errorResponse.error = {
                type: error.constructor.name,
                details: (error as any).details || error.message
            };

            // Set appropriate status codes
            if (error instanceof ValidationError) {
                res.status(StatusCodes.UNPROCESSABLE_ENTITY);
            } else if (error instanceof BadRequestError) {
                res.status(StatusCodes.BAD_REQUEST);
            } else if (error instanceof UnauthorizedError) {
                res.status(StatusCodes.UNAUTHORIZED);
            } else if (error instanceof ForbiddenError || error instanceof InsufficientPermissionsError) {
                res.status(StatusCodes.FORBIDDEN);
            } else if (error instanceof ProductNotFoundError) {
                res.status(StatusCodes.NOT_FOUND);
            } else {
                res.status(StatusCodes.INTERNAL_SERVER_ERROR);
            }
        } else if (error.name === 'ValidationError') {
            // Mongoose validation error
            res.status(StatusCodes.UNPROCESSABLE_ENTITY);
            errorResponse.message = 'بيانات غير صالحة';
            errorResponse.error = {
                type: 'ValidationError',
                details: EnhancedErrorHandler.formatMongooseValidationError(error)
            };
        } else if (error.name === 'CastError') {
            // MongoDB cast error (invalid ObjectId, etc.)
            res.status(StatusCodes.BAD_REQUEST);
            errorResponse.message = 'معرف غير صالح';
            errorResponse.error = {
                type: 'CastError',
                details: {
                    field: error.path,
                    value: error.value,
                    expectedType: error.kind
                }
            };
        } else if (error.code === 11000) {
            // MongoDB duplicate key error
            res.status(StatusCodes.CONFLICT);
            errorResponse.message = 'البيانات موجودة مسبقاً';
            errorResponse.error = {
                type: 'DuplicateKeyError',
                details: EnhancedErrorHandler.formatDuplicateKeyError(error)
            };
        } else if (error.name === 'JsonWebTokenError') {
            // JWT errors
            res.status(StatusCodes.UNAUTHORIZED);
            errorResponse.message = 'رمز المصادقة غير صالح';
            errorResponse.error = {
                type: 'JsonWebTokenError'
            };
        } else if (error.name === 'TokenExpiredError') {
            // JWT expired
            res.status(StatusCodes.UNAUTHORIZED);
            errorResponse.message = 'انتهت صلاحية رمز المصادقة';
            errorResponse.error = {
                type: 'TokenExpiredError'
            };
        } else if (error.name === 'MulterError') {
            // File upload errors
            res.status(StatusCodes.BAD_REQUEST);
            errorResponse.message = EnhancedErrorHandler.formatMulterError(error);
            errorResponse.error = {
                type: 'MulterError',
                details: {
                    code: error.code,
                    field: error.field
                }
            };
        } else if (error.type === 'entity.parse.failed') {
            // JSON parsing error
            res.status(StatusCodes.BAD_REQUEST);
            errorResponse.message = 'تنسيق البيانات غير صالح';
            errorResponse.error = {
                type: 'ParseError'
            };
        } else if (error.code === 'ECONNREFUSED' || error.code === 'ENOTFOUND') {
            // Network/Database connection errors
            res.status(StatusCodes.SERVICE_UNAVAILABLE);
            errorResponse.message = 'الخدمة غير متوفرة حالياً';
            errorResponse.error = {
                type: 'ConnectionError'
            };
        } else {
            // Generic server error
            res.status(StatusCodes.INTERNAL_SERVER_ERROR);
            errorResponse.message = 'حدث خطأ داخلي في الخادم';
            errorResponse.error = {
                type: 'InternalServerError'
            };
        }

        // Add stack trace in development
        if (process.env.NODE_ENV === 'development') {
            errorResponse.error = errorResponse.error || { type: 'Unknown' };
            errorResponse.error.stack = error.stack;
        }

        // Send error response
        res.json(errorResponse);
    }

    private static formatMongooseValidationError(error: any): any {
        const errors: any = {};
        
        if (error.errors) {
            Object.keys(error.errors).forEach(key => {
                const err = error.errors[key];
                errors[key] = {
                    message: err.message,
                    value: err.value,
                    kind: err.kind
                };
            });
        }

        return errors;
    }

    private static formatDuplicateKeyError(error: any): any {
        const keyValue = error.keyValue || {};
        const duplicateFields = Object.keys(keyValue);
        
        return {
            fields: duplicateFields,
            values: keyValue,
            message: `القيم التالية موجودة مسبقاً: ${duplicateFields.join(', ')}`
        };
    }

    private static formatMulterError(error: any): string {
        switch (error.code) {
            case 'LIMIT_FILE_SIZE':
                return 'حجم الملف كبير جداً';
            case 'LIMIT_FILE_COUNT':
                return 'عدد الملفات يتجاوز الحد المسموح';
            case 'LIMIT_FIELD_KEY':
                return 'اسم الحقل طويل جداً';
            case 'LIMIT_FIELD_VALUE':
                return 'قيمة الحقل طويلة جداً';
            case 'LIMIT_FIELD_COUNT':
                return 'عدد الحقول يتجاوز الحد المسموح';
            case 'LIMIT_UNEXPECTED_FILE':
                return 'ملف غير متوقع';
            case 'MISSING_FIELD_NAME':
                return 'اسم الحقل مفقود';
            default:
                return 'خطأ في رفع الملف';
        }
    }

    // Log error for monitoring/alerting systems
    private static logError(error: any, req: Request): void {
        const errorLog = {
            timestamp: new Date().toISOString(),
            level: 'ERROR',
            message: error.message,
            stack: error.stack,
            request: {
                method: req.method,
                url: req.url,
                headers: req.headers,
                body: req.body,
                query: req.query,
                params: req.params,
                ip: req.ip,
                userAgent: req.get('User-Agent')
            },
            user: req.user?.id || 'anonymous'
        };

        // In production, you would send this to a logging service
        console.error('ERROR_LOG:', JSON.stringify(errorLog, null, 2));
    }
}

// Async error wrapper for route handlers
export const asyncHandler = (fn: Function) => {
    return (req: Request, res: Response, next: NextFunction) => {
        Promise.resolve(fn(req, res, next)).catch(next);
    };
};

// 404 handler
export const notFoundHandler = (req: Request, res: Response): void => {
    res.status(StatusCodes.NOT_FOUND).json({
        success: false,
        message: 'المسار المطلوب غير موجود',
        error: {
            type: 'NotFound',
            path: req.path,
            method: req.method
        },
        timestamp: new Date().toISOString()
    });
};

// Health check endpoint
export const healthCheck = (req: Request, res: Response): void => {
    res.status(StatusCodes.OK).json({
        success: true,
        message: 'الخادم يعمل بشكل طبيعي',
        data: {
            status: 'healthy',
            timestamp: new Date().toISOString(),
            uptime: process.uptime(),
            memory: process.memoryUsage(),
            version: process.version
        }
    });
};