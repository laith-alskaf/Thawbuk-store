import { Request } from "express";
import { IProduct, ProductMapper } from "../../../domain/entity/product";
import { ProductRepository } from "../../../domain/repository/product.repository";
import { CloudService } from "../../../domain/services/cloud.service";
import { IdGeneratorService } from "../../../domain/services/id-generator.service";
import { NotificationService } from "../../../domain/services/notification.service";
import { CreateProductDTO, ProductInfoDTO } from "../../dtos/product.dto";
import { BadRequestError, ValidationError } from "../../errors/application-error";
import { Messages } from "../../../presentation/config/constant";
import { handlerExtractImage } from "../../../presentation/utils/handle-extract-image";

export class EnhancedCreateProductUseCase {
    constructor(
        private readonly productRepository: ProductRepository,
        private readonly uuidGeneratorService: IdGeneratorService,
        private readonly newProductNotification: NotificationService,
        private readonly uploadImageService: CloudService,
    ) { }

    execute = async (productDTO: Partial<CreateProductDTO>, req: Request): Promise<ProductInfoDTO> => {
        try {
            // التحقق من البيانات المطلوبة
            this.validateProductData(productDTO);

            // التحقق من عدم وجود منتج بنفس الاسم للمستخدم نفسه
            await this.checkProductNameUniqueness(productDTO.name!, productDTO.createdBy!);

            // إنشاء معرف فريد للمنتج
            const uuid = this.uuidGeneratorService.generate();

            const product = {
                ...productDTO,
                _id: uuid,
                isActive: true, // المنتج نشط افتراضياً
                createdAt: new Date(),
                updatedAt: new Date(),
                // تعيين قيم افتراضية للحقول الاختيارية
                rating: 0,
                reviewsCount: 0,
                favoritesCount: 0,
                viewsCount: 0
            };

            // معالجة الصور
            const urlsImages = await this.handleProductImages(req, uuid, product.createdBy!);
            product.images = urlsImages;

            // إنشاء المنتج في قاعدة البيانات
            const newProduct: IProduct = await this.productRepository.create(product);

            // إرسال إشعار بالمنتج الجديد
            await this.sendNewProductNotification(newProduct);

            // إرجاع بيانات المنتج
            return ProductMapper.toDTO(newProduct);

        } catch (error: any) {
            console.error('Error in EnhancedCreateProductUseCase:', error);

            if (error instanceof BadRequestError || error instanceof ValidationError) {
                throw error;
            }

            throw new BadRequestError(
                error.message || Messages.PRODUCT.CREATE_FAILED_EN || 'فشل في إنشاء المنتج'
            );
        }
    }

    private validateProductData(productDTO: Partial<CreateProductDTO>): void {
        const errors: string[] = [];

        if (!productDTO.name || productDTO.name.trim().length === 0) {
            errors.push('اسم المنتج مطلوب');
        }

        if (!productDTO.description || productDTO.description.trim().length === 0) {
            errors.push('وصف المنتج مطلوب');
        }

        if (!productDTO.price || productDTO.price <= 0) {
            errors.push('سعر المنتج يجب أن يكون أكبر من صفر');
        }

        if (!productDTO.categoryId || productDTO.categoryId.trim().length === 0) {
            errors.push('فئة المنتج مطلوبة');
        }

        if (!productDTO.createdBy || productDTO.createdBy.trim().length === 0) {
            errors.push('معرف المنشئ مطلوب');
        }

        if (productDTO.stock !== undefined && productDTO.stock < 0) {
            errors.push('كمية المخزون لا يمكن أن تكون سالبة');
        }

        if (errors.length > 0) {
            throw new ValidationError(`بيانات المنتج غير صحيحة: ${errors.join(', ')}`);
        }
    }

    private async checkProductNameUniqueness(name: string, createdBy: string): Promise<void> {
        try {
            const existingProducts = await this.productRepository.allProduct(1, 1, {
                name: name.trim(),
                createdBy: createdBy
            });

            if (existingProducts && existingProducts.total > 0) {
                throw new BadRequestError('يوجد منتج بنفس الاسم لديك بالفعل');
            }
        } catch (error: any) {
            if (error instanceof BadRequestError) {
                throw error;
            }
            console.error('Error checking product name uniqueness:', error);
            // لا نرمي خطأ هنا لأن هذا فحص اختياري
        }
    }

    private async handleProductImages(req: Request, uuid: string, createdBy: string): Promise<string[]> {
        try {
            const urlsImages = await handlerExtractImage({
                req: req,
                uuid: uuid,
                folderName: createdBy,
                userId: 'products',
                uploadToCloudinary: this.uploadImageService
            });

            if (!urlsImages || urlsImages.length === 0) {
                throw new BadRequestError(
                    Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.IMAGE_URI_INVALID_EN ||
                    'يجب إرفاق صورة واحدة على الأقل للمنتج'
                );
            }

            return urlsImages;
        } catch (error: any) {
            console.error('Error handling product images:', error);
            throw new BadRequestError(
                error.message || 'فشل في رفع صور المنتج'
            );
        }
    }

    private async sendNewProductNotification(product: IProduct): Promise<void> {
        try {
            const productData: ProductInfoDTO = ProductMapper.toDTO(product);
            await this.newProductNotification.send(productData);
            console.log('New product notification sent successfully for product:', product._id);
        } catch (error: any) {
            console.error('Error sending new product notification:', error);
            // لا نرمي خطأ هنا لأن فشل الإشعار لا يجب أن يوقف إنشاء المنتج
        }
    }
}