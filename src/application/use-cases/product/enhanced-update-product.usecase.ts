import { IProduct, ProductMapper } from "../../../domain/entity/product";
import { ProductRepository } from "../../../domain/repository/product.repository";
import { UpdateProductDTO, ProductInfoDTO } from "../../dtos/product.dto";
import { BadRequestError, NotFoundError, ValidationError } from "../../errors/application-error";
import { Messages } from "../../../presentation/config/constant";

export class EnhancedUpdateProductUseCase {
    constructor(
        private readonly productRepository: ProductRepository,
    ) { }

    execute = async (updateProductDTO: UpdateProductDTO): Promise<ProductInfoDTO> => {
        try {
            // التحقق من البيانات المطلوبة
            this.validateUpdateData(updateProductDTO);

            // التحقق من وجود المنتج
            const existingProduct = await this.getExistingProduct(updateProductDTO.productId);

            // التحقق من عدم تكرار الاسم (إذا تم تغييره)
            if (updateProductDTO.product.name && 
                updateProductDTO.product.name !== existingProduct.name) {
                await this.checkProductNameUniqueness(
                    updateProductDTO.product.name, 
                    existingProduct.createdBy,
                    updateProductDTO.productId
                );
            }

            // تحضير بيانات التحديث
            const updateData = this.prepareUpdateData(updateProductDTO.product);

            // تحديث المنتج
            const updatedProduct = await this.productRepository.update(
                updateProductDTO.productId, 
                updateData
            );

            if (!updatedProduct) {
                throw new BadRequestError('فشل في تحديث المنتج');
            }

            return ProductMapper.toDTO(updatedProduct);

        } catch (error: any) {
            console.error('Error in EnhancedUpdateProductUseCase:', error);
            
            if (error instanceof BadRequestError || 
                error instanceof NotFoundError || 
                error instanceof ValidationError) {
                throw error;
            }
            
            throw new BadRequestError(
                error.message || Messages.PRODUCT.UPDATE_FAILED_EN || 'فشل في تحديث المنتج'
            );
        }
    }

    private validateUpdateData(updateProductDTO: UpdateProductDTO): void {
        const errors: string[] = [];

        if (!updateProductDTO.productId || updateProductDTO.productId.trim().length === 0) {
            errors.push('معرف المنتج مطلوب');
        }

        if (!updateProductDTO.product) {
            errors.push('بيانات المنتج مطلوبة');
        }

        const product = updateProductDTO.product;
        
        if (product.name !== undefined && (!product.name || product.name.trim().length === 0)) {
            errors.push('اسم المنتج لا يمكن أن يكون فارغاً');
        }

        if (product.description !== undefined && (!product.description || product.description.trim().length === 0)) {
            errors.push('وصف المنتج لا يمكن أن يكون فارغاً');
        }

        if (product.price !== undefined && product.price <= 0) {
            errors.push('سعر المنتج يجب أن يكون أكبر من صفر');
        }

        if (product.stock !== undefined && product.stock < 0) {
            errors.push('كمية المخزون لا يمكن أن تكون سالبة');
        }

        if (product.categoryId !== undefined && (!product.categoryId || product.categoryId.trim().length === 0)) {
            errors.push('فئة المنتج لا يمكن أن تكون فارغة');
        }

        if (errors.length > 0) {
            throw new ValidationError(`بيانات التحديث غير صحيحة: ${errors.join(', ')}`);
        }
    }

    private async getExistingProduct(productId: string): Promise<IProduct> {
        const existingProduct = await this.productRepository.findById(productId);
        
        if (!existingProduct) {
            throw new NotFoundError(
                Messages.PRODUCT.NOT_FOUND_EN || 'المنتج غير موجود'
            );
        }

        return existingProduct;
    }

    private async checkProductNameUniqueness(
        name: string, 
        createdBy: string, 
        excludeProductId: string
    ): Promise<void> {
        try {
            const existingProducts = await this.productRepository.allProduct(1, 10, { 
                name: name.trim(),
                createdBy: createdBy 
            });

            if (existingProducts && existingProducts.products.length > 0) {
                // التحقق من أن المنتج الموجود ليس نفس المنتج الذي نحدثه
                const duplicateProduct = existingProducts.products.find(
                    product => product._id !== excludeProductId
                );

                if (duplicateProduct) {
                    throw new BadRequestError('يوجد منتج آخر بنفس الاسم لديك بالفعل');
                }
            }
        } catch (error: any) {
            if (error instanceof BadRequestError) {
                throw error;
            }
            console.error('Error checking product name uniqueness:', error);
            // لا نرمي خطأ هنا لأن هذا فحص اختياري
        }
    }

    private prepareUpdateData(productData: Partial<IProduct>): Partial<IProduct> {
        const updateData: Partial<IProduct> = {
            ...productData,
            updatedAt: new Date()
        };

        // تنظيف البيانات - إزالة القيم undefined
        Object.keys(updateData).forEach(key => {
            if (updateData[key as keyof IProduct] === undefined) {
                delete updateData[key as keyof IProduct];
            }
        });

        // تنظيف النصوص
        if (updateData.name) {
            updateData.name = updateData.name.trim();
        }
        if (updateData.nameAr) {
            updateData.nameAr = updateData.nameAr.trim();
        }
        if (updateData.description) {
            updateData.description = updateData.description.trim();
        }
        if (updateData.descriptionAr) {
            updateData.descriptionAr = updateData.descriptionAr.trim();
        }

        return updateData;
    }
}