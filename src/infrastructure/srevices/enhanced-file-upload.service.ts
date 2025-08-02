import multer from 'multer';
import { Request } from 'express';
import { CloudService } from '../../domain/services/cloud.service';
import { BadRequestError, ValidationError } from '../../application/errors/application-error';

export interface FileUploadOptions {
    maxFileSize?: number; // in bytes
    maxFiles?: number;
    allowedMimeTypes?: string[];
    allowedExtensions?: string[];
    generateFileName?: (originalName: string, userId: string) => string;
}

export interface UploadedFileInfo {
    originalName: string;
    fileName: string;
    mimeType: string;
    size: number;
    url: string;
    uploadedAt: Date;
}

export class EnhancedFileUploadService {
    private readonly defaultOptions: Required<FileUploadOptions> = {
        maxFileSize: 5 * 1024 * 1024, // 5MB
        maxFiles: 10,
        allowedMimeTypes: [
            'image/jpeg',
            'image/jpg',
            'image/png',
            'image/gif',
            'image/webp'
        ],
        allowedExtensions: ['.jpg', '.jpeg', '.png', '.gif', '.webp'],
        generateFileName: (originalName: string, userId: string) => {
            const timestamp = Date.now();
            const random = Math.random().toString(36).substring(2, 15);
            const extension = originalName.substring(originalName.lastIndexOf('.'));
            return `${userId}_${timestamp}_${random}${extension}`;
        }
    };

    constructor(
        private readonly cloudService: CloudService,
        private readonly options: FileUploadOptions = {}
    ) {
        this.options = { ...this.defaultOptions, ...options };
    }

    // Create multer middleware with enhanced validation
    createMulterMiddleware() {
        const storage = multer.memoryStorage();

        return multer({
            storage,
            limits: {
                fileSize: this.options.maxFileSize,
                files: this.options.maxFiles
            },
            fileFilter: (req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
                try {
                    this.validateFile(file);
                    cb(null, true);
                } catch (error: any) {
                    cb(error);
                }
            }
        });
    }

    // Validate individual file
    private validateFile(file: Express.Multer.File): void {
        // Check MIME type
        if (!this.options.allowedMimeTypes!.includes(file.mimetype)) {
            throw new ValidationError(
                `نوع الملف غير مدعوم. الأنواع المدعومة: ${this.options.allowedMimeTypes!.join(', ')}`
            );
        }

        // Check file extension
        const extension = file.originalname.toLowerCase().substring(file.originalname.lastIndexOf('.'));
        if (!this.options.allowedExtensions!.includes(extension)) {
            throw new ValidationError(
                `امتداد الملف غير مدعوم. الامتدادات المدعومة: ${this.options.allowedExtensions!.join(', ')}`
            );
        }

        // Additional security checks
        this.performSecurityChecks(file);
    }

    // Perform security checks on file
    private performSecurityChecks(file: Express.Multer.File): void {
        // Check for suspicious file names
        const suspiciousPatterns = [
            /\.php$/i,
            /\.exe$/i,
            /\.bat$/i,
            /\.cmd$/i,
            /\.scr$/i,
            /\.vbs$/i,
            /\.js$/i,
            /\.html$/i,
            /\.htm$/i
        ];

        for (const pattern of suspiciousPatterns) {
            if (pattern.test(file.originalname)) {
                throw new ValidationError('اسم الملف يحتوي على أحرف غير مسموحة');
            }
        }

        // Check for null bytes (security vulnerability)
        if (file.originalname.includes('\0')) {
            throw new ValidationError('اسم الملف غير صالح');
        }

        // Check file name length
        if (file.originalname.length > 255) {
            throw new ValidationError('اسم الملف طويل جداً');
        }
    }

    // Upload multiple files with enhanced error handling
    async uploadFiles(
        files: Express.Multer.File[],
        userId: string,
        folderName?: string
    ): Promise<UploadedFileInfo[]> {
        if (!files || files.length === 0) {
            throw new BadRequestError('لم يتم اختيار أي ملفات للرفع');
        }

        if (files.length > this.options.maxFiles!) {
            throw new BadRequestError(
                `عدد الملفات يتجاوز الحد المسموح (${this.options.maxFiles})`
            );
        }

        const uploadPromises = files.map(file => this.uploadSingleFile(file, userId, folderName));
        
        try {
            const results = await Promise.allSettled(uploadPromises);
            const uploadedFiles: UploadedFileInfo[] = [];
            const errors: string[] = [];

            results.forEach((result, index) => {
                if (result.status === 'fulfilled') {
                    uploadedFiles.push(result.value);
                } else {
                    errors.push(`ملف ${files[index].originalname}: ${result.reason.message}`);
                }
            });

            if (errors.length > 0 && uploadedFiles.length === 0) {
                throw new BadRequestError(`فشل في رفع جميع الملفات: ${errors.join(', ')}`);
            }

            if (errors.length > 0) {
                console.warn('بعض الملفات فشلت في الرفع:', errors);
            }

            return uploadedFiles;
        } catch (error: any) {
            console.error('خطأ في رفع الملفات:', error);
            throw new BadRequestError(error.message || 'فشل في رفع الملفات');
        }
    }

    // Upload single file
    private async uploadSingleFile(
        file: Express.Multer.File,
        userId: string,
        folderName?: string
    ): Promise<UploadedFileInfo> {
        try {
            // Generate unique filename
            const fileName = this.options.generateFileName!(file.originalname, userId);
            
            // Create folder path
            const folder = folderName ? `${folderName}/${userId}` : userId;
            
            // Upload to cloud service
            const url = await this.cloudService.uploadImage(file.buffer, fileName);

            return {
                originalName: file.originalname,
                fileName,
                mimeType: file.mimetype,
                size: file.size,
                url,
                uploadedAt: new Date()
            };
        } catch (error: any) {
            console.error(`خطأ في رفع الملف ${file.originalname}:`, error);
            throw new BadRequestError(`فشل في رفع الملف ${file.originalname}: ${error.message}`);
        }
    }

    // Delete files from cloud
    async deleteFiles(urls: string[]): Promise<void> {
        if (!urls || urls.length === 0) return;

        const deletePromises = urls.map(url => this.deleteFile(url));
        
        try {
            await Promise.allSettled(deletePromises);
        } catch (error) {
            console.error('خطأ في حذف الملفات:', error);
            // Don't throw error as this is cleanup operation
        }
    }

    // Delete single file
    private async deleteFile(url: string): Promise<void> {
        try {
            // Extract file path from URL for deletion
            // This depends on your cloud service implementation
            // For now, we'll skip the actual deletion since we need userId and uuid
            console.log(`File deletion requested for: ${url}`);
            // await this.cloudService.deleteImage(url, userId, uuid);
        } catch (error) {
            console.error(`خطأ في حذف الملف ${url}:`, error);
        }
    }

    // Validate file size before upload
    validateFileSize(file: Express.Multer.File): void {
        if (file.size > this.options.maxFileSize!) {
            const maxSizeMB = (this.options.maxFileSize! / (1024 * 1024)).toFixed(2);
            throw new ValidationError(`حجم الملف يتجاوز الحد المسموح (${maxSizeMB} ميجابايت)`);
        }
    }

    // Get file info without uploading
    getFileInfo(file: Express.Multer.File): Omit<UploadedFileInfo, 'url' | 'fileName' | 'uploadedAt'> {
        return {
            originalName: file.originalname,
            mimeType: file.mimetype,
            size: file.size
        };
    }

    // Create optimized image versions (if needed)
    async createImageVariants(
        file: Express.Multer.File,
        userId: string,
        variants: { name: string; width: number; height?: number; quality?: number }[]
    ): Promise<{ [key: string]: string }> {
        // This would require image processing library like Sharp
        // For now, just return the original image URL for all variants
        const originalUrl = await this.uploadSingleFile(file, userId);
        
        const variantUrls: { [key: string]: string } = {};
        variants.forEach(variant => {
            variantUrls[variant.name] = originalUrl.url;
        });

        return variantUrls;
    }
}

// Predefined upload configurations
export const FileUploadConfigs = {
    PRODUCT_IMAGES: {
        maxFileSize: 5 * 1024 * 1024, // 5MB
        maxFiles: 10,
        allowedMimeTypes: ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'],
        allowedExtensions: ['.jpg', '.jpeg', '.png', '.webp']
    },

    CATEGORY_IMAGES: {
        maxFileSize: 2 * 1024 * 1024, // 2MB
        maxFiles: 1,
        allowedMimeTypes: ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'],
        allowedExtensions: ['.jpg', '.jpeg', '.png', '.webp']
    },

    USER_AVATAR: {
        maxFileSize: 1 * 1024 * 1024, // 1MB
        maxFiles: 1,
        allowedMimeTypes: ['image/jpeg', 'image/jpg', 'image/png'],
        allowedExtensions: ['.jpg', '.jpeg', '.png']
    }
};