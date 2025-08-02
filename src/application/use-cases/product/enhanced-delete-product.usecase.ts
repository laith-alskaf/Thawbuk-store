import { ProductRepository } from "../../../domain/repository/product.repository";
import { DeleteProductDTO } from "../../dtos/product.dto";
import { BadRequestError, NotFoundError } from "../../errors/application-error";
import { Messages } from "../../../presentation/config/constant";

export class EnhancedDeleteProductUseCase {
    constructor(
        private readonly productRepository: ProductRepository,
    ) { }

    execute = async (deleteProductDTO: DeleteProductDTO): Promise<void> => {
        try {
            // التحقق من البيانات المطلوبة
            this.validateDeleteData(deleteProductDTO);

            // التحقق من وجود المنتج
            const existingProduct = await this.productRepository.findById(deleteProductDTO.productId);
            
            if (!existingProduct) {
                throw new NotFoundError(
                    Messages.PRODUCT.NOT_FOUND_EN || 'المنتج غير موجود'
                );
            }

            // التحقق من إمكانية الحذف
            await this.validateDeletionPermission(existingProduct);

            // حذف المنتج
            await this.productRepository.delete(deleteProductDTO.productId);

            console.log(`Product ${deleteProductDTO.productId} deleted successfully`);

        } catch (error: any) {
            console.error('Error in EnhancedDeleteProductUseCase:', error);
            
            if (error instanceof BadRequestError || error instanceof NotFoundError) {
                throw error;
            }
            
            throw new BadRequestError(
                error.message || Messages.PRODUCT.DELETE_FAILED_EN || 'فشل في حذف المنتج'
            );
        }
    }

    private validateDeleteData(deleteProductDTO: DeleteProductDTO): void {
        if (!deleteProductDTO.productId || deleteProductDTO.productId.trim().length === 0) {
            throw new BadRequestError('معرف المنتج مطلوب للحذف');
        }
    }

    private async validateDeletionPermission(product: any): Promise<void> {
        // يمكن إضافة منطق إضافي هنا للتحقق من إمكانية الحذف
        // مثل التحقق من وجود طلبات مرتبطة بالمنتج
        
        // مثال: منع حذف المنتجات التي لها طلبات نشطة
        // if (product.hasActiveOrders) {
        //     throw new BadRequestError('لا يمكن حذف المنتج لوجود طلبات نشطة عليه');
        // }

        // مثال: منع حذف المنتجات المفضلة لدى عدد كبير من المستخدمين
        if (product.favoritesCount && product.favoritesCount > 10) {
            console.warn(`Deleting product with ${product.favoritesCount} favorites: ${product._id}`);
        }
    }
}