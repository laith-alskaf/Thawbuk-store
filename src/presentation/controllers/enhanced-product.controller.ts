import { Request, Response } from 'express';
import { CreateProductDTO, DeleteProductDTO, GetProductsByUserIdDTO, PeginationProductDTO, SearchProductDTO, UpdateProductDTO } from '../../application/dtos/product.dto';
import { Messages, StatusCodes } from '../config/constant';
import {
    GetProductByIdUseCase,
    GetProductsByCategoryIdUseCase,
    GetFilteredProductsUseCase,
    GetProductsByUserIdUseCase,
    GetAllProductsUseCase,
    SearchProductsUseCase,
} from "../../application/use-cases/product";
import { EnhancedCreateProductUseCase } from '../../application/use-cases/product/enhanced-create-product.usecase';
import { EnhancedUpdateProductUseCase } from '../../application/use-cases/product/enhanced-update-product.usecase';
import { EnhancedDeleteProductUseCase } from '../../application/use-cases/product/enhanced-delete-product.usecase';
import { EnhancedSearchService, SearchFilters, SearchOptions } from '../../application/services/enhanced-search.service';
import { ApplicationResponse } from '../../application/response/application-resposne';
import { 
    BadRequestError, 
    ValidationError, 
    ProductNotFoundError,
    InsufficientPermissionsError 
} from '../../application/errors/application-error';

export class EnhancedProductController {

    constructor(
        private readonly getProductByIdUseCase: GetProductByIdUseCase,
        private readonly getProductsByCategoryIdUseCase: GetProductsByCategoryIdUseCase,
        private readonly getFilteredProductsUseCase: GetFilteredProductsUseCase,
        private readonly getProductsByUserIdUseCase: GetProductsByUserIdUseCase,
        private readonly getAllProductsUseCase: GetAllProductsUseCase,
        private readonly searchProductsUseCase: SearchProductsUseCase,
        // Enhanced Use Cases
        private readonly enhancedCreateProductUseCase: EnhancedCreateProductUseCase,
        private readonly enhancedUpdateProductUseCase: EnhancedUpdateProductUseCase,
        private readonly enhancedDeleteProductUseCase: EnhancedDeleteProductUseCase,
        // Enhanced Services
        private readonly enhancedSearchService: EnhancedSearchService,
    ) { }

    async getAllProducts(req: Request, res: Response): Promise<void> {
        try {
            const peginationProductDTO: PeginationProductDTO = {
                page: Math.max(1, parseInt(req.query.page as string) || 1),
                limit: Math.min(100, Math.max(1, parseInt(req.query.limit as string) || 10))
            };

            const { productData, total } = await this.getAllProductsUseCase.execute(peginationProductDTO, {});
            
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.GET_ALL_SUCCESS_EN,
                body: {
                    data: {
                        currentPage: peginationProductDTO.page,
                        totalPages: Math.ceil(total / peginationProductDTO.limit),
                        totalItems: total,
                        products: productData,
                        hasNextPage: peginationProductDTO.page < Math.ceil(total / peginationProductDTO.limit),
                        hasPrevPage: peginationProductDTO.page > 1
                    }
                }
            }).send();

        } catch (error: any) {
            console.error('Error in getAllProducts:', error);
            throw new BadRequestError(
                error.message || Messages.PRODUCT.NOT_FOUND_PRODUCTS_EN || 'فشل في تحميل المنتجات'
            );
        }
    }

    async createProduct(req: Request, res: Response): Promise<void> {
        try {
            const body = req.body;
            const userId = req.user.id;
            const userRole = req.user.role;

            // التحقق من الصلاحيات
            if (userRole !== 'admin') {
                throw new InsufficientPermissionsError('create product');
            }

            const createProductDTO: CreateProductDTO = {
                ...body,
                createdBy: userId
            };

            const createdProduct = await this.enhancedCreateProductUseCase.execute(createProductDTO, req);
            
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.CREATED,
                message: Messages.PRODUCT.CREATE_SUCCESS_EN || 'تم إنشاء المنتج بنجاح',
                body: {
                    data: createdProduct
                }
            }).send();

        } catch (error: any) {
            console.error('Error in createProduct:', error);
            
            if (error instanceof ValidationError) {
                throw error;
            }
            
            throw new BadRequestError(
                error.message || Messages.PRODUCT.CREATE_FAILED_EN || 'فشل في إنشاء المنتج'
            );
        }
    }

    async updateProduct(req: Request, res: Response): Promise<void> {
        try {
            const { product } = req.body;
            const { productId } = req.params;
            const userId = req.user.id;
            const userRole = req.user.role;

            if (!productId) {
                throw new BadRequestError('معرف المنتج مطلوب');
            }

            const updateProductDTO: UpdateProductDTO = {
                productId,
                product: {
                    ...product,
                    updatedAt: new Date(),
                }
            };

            const updatedProduct = await this.enhancedUpdateProductUseCase.execute(updateProductDTO);
            
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.UPDATE_SUCCESS_EN || 'تم تحديث المنتج بنجاح',
                body: {
                    data: updatedProduct
                }
            }).send();

        } catch (error: any) {
            console.error('Error in updateProduct:', error);
            
            if (error instanceof ValidationError || error instanceof ProductNotFoundError) {
                throw error;
            }
            
            throw new BadRequestError(
                error.message || Messages.PRODUCT.UPDATE_FAILED_EN || 'فشل في تحديث المنتج'
            );
        }
    }

    async deleteProduct(req: Request, res: Response): Promise<void> {
        try {
            const { productId } = req.params;
            const userId = req.user.id;
            const userRole = req.user.role;

            if (!productId) {
                throw new BadRequestError('معرف المنتج مطلوب');
            }

            const deleteProductDTO: DeleteProductDTO = { productId };
            await this.enhancedDeleteProductUseCase.execute(deleteProductDTO);
            
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.DELETE_SUCCESS_EN || 'تم حذف المنتج بنجاح',
            }).send();

        } catch (error: any) {
            console.error('Error in deleteProduct:', error);
            
            if (error instanceof ProductNotFoundError) {
                throw error;
            }
            
            throw new BadRequestError(
                error.message || Messages.PRODUCT.DELETE_FAILED_EN || 'فشل في حذف المنتج'
            );
        }
    }

    async getSingleProduct(req: Request, res: Response): Promise<void> {
        try {
            const { productId } = req.params;
            
            if (!productId) {
                throw new BadRequestError('معرف المنتج مطلوب');
            }

            const product = await this.getProductByIdUseCase.execute(productId);
            
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.GET_SUCCESS_EN || 'تم تحميل المنتج بنجاح',
                body: {
                    data: product
                }
            }).send();

        } catch (error: any) {
            console.error('Error in getSingleProduct:', error);
            throw new BadRequestError(
                error.message || Messages.PRODUCT.NOT_FOUND_EN || 'المنتج غير موجود'
            );
        }
    }

    async getProductsByCategoryId(req: Request, res: Response): Promise<void> {
        try {
            const { categoryId } = req.params;
            
            if (!categoryId) {
                throw new BadRequestError('معرف الفئة مطلوب');
            }

            const products = await this.getProductsByCategoryIdUseCase.execute(categoryId);
            
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.GET_ALL_SUCCESS_EN || 'تم تحميل المنتجات بنجاح',
                body: {
                    data: products || [],
                    count: products ? products.length : 0
                }
            }).send();

        } catch (error: any) {
            console.error('Error in getProductsByCategoryId:', error);
            throw new BadRequestError(
                error.message || Messages.PRODUCT.NOT_FOUND_PRODUCTS_EN || 'لم يتم العثور على منتجات'
            );
        }
    }

    async filterProducts(req: Request, res: Response): Promise<void> {
        try {
            const {
                category,
                searchQuery,
                sizes,
                colors,
                minPrice,
                maxPrice,
                sortBy,
            } = req.query;

            const params = {
                category: category as string | undefined,
                searchQuery: searchQuery as string | undefined,
                sizes: sizes ? (sizes as string).split(',').map(s => s.trim()) : undefined,
                colors: colors ? (colors as string).split(',').map(c => c.trim()) : undefined,
                minPrice: minPrice ? Math.max(0, parseFloat(minPrice as string)) : undefined,
                maxPrice: maxPrice ? Math.max(0, parseFloat(maxPrice as string)) : undefined,
                sortBy: sortBy as string | undefined,
            };

            // التحقق من صحة المعاملات
            if (params.minPrice && params.maxPrice && params.minPrice > params.maxPrice) {
                throw new BadRequestError('الحد الأدنى للسعر لا يمكن أن يكون أكبر من الحد الأقصى');
            }

            const products = await this.getFilteredProductsUseCase.execute(params);
            
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.GET_ALL_SUCCESS_EN || 'تم تحميل المنتجات بنجاح',
                body: {
                    data: products,
                    count: products.length,
                    filters: params
                }
            }).send();

        } catch (error: any) {
            console.error('Error in filterProducts:', error);
            throw new BadRequestError(
                error.message || Messages.PRODUCT.NOT_FOUND_PRODUCTS_EN || 'فشل في البحث عن المنتجات'
            );
        }
    }

    async searchProducts(req: Request, res: Response): Promise<void> {
        try {
            const { title = '', categoryId = null, page = 1, limit = 10, createdId = null } = req.query;
            
            const searchProductDTO: SearchProductDTO = {
                name: (title as string).trim(),
                categoryId: categoryId as string,
                createdId: createdId as string,
                peginationProduct: {
                    page: Math.max(1, parseInt(page as string) || 1),
                    limit: Math.min(100, Math.max(1, parseInt(limit as string) || 10)),
                }
            };

            const products = await this.searchProductsUseCase.execute(searchProductDTO);
            
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.GET_ALL_SUCCESS_EN || 'تم البحث بنجاح',
                body: {
                    data: {
                        total: products.total,
                        products: products.productData,
                        currentPage: searchProductDTO.peginationProduct.page,
                        totalPages: Math.ceil(products.total / searchProductDTO.peginationProduct.limit),
                        searchQuery: searchProductDTO.name
                    }
                }
            }).send();

        } catch (error: any) {
            console.error('Error in searchProducts:', error);
            throw new BadRequestError(
                error.message || Messages.PRODUCT.NO_RESULTS_EN || 'لم يتم العثور على نتائج'
            );
        }
    }

    async getProductsByUserId(req: Request, res: Response): Promise<void> {
        try {
            const userId = req.user.id;
            const userRole = req.user.role;
            const { page = 1, limit = 10 } = req.query;

            const getProductsByUserIdDTO: GetProductsByUserIdDTO = {
                filter: { createdBy: userId },
                peginationProduct: {
                    page: Math.max(1, parseInt(page as string)),
                    limit: Math.min(100, Math.max(1, parseInt(limit as string))),
                }
            };

            const { productData, total } = await this.getProductsByUserIdUseCase.execute(getProductsByUserIdDTO);
            
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.GET_ALL_SUCCESS_EN || 'تم تحميل منتجاتك بنجاح',
                body: {
                    data: {
                        currentPage: getProductsByUserIdDTO.peginationProduct.page,
                        totalPages: Math.ceil(total / getProductsByUserIdDTO.peginationProduct.limit),
                        totalItems: total,
                        products: productData,
                        hasNextPage: getProductsByUserIdDTO.peginationProduct.page < Math.ceil(total / getProductsByUserIdDTO.peginationProduct.limit),
                        hasPrevPage: getProductsByUserIdDTO.peginationProduct.page > 1
                    }
                }
            }).send();

        } catch (error: any) {
            console.error('Error in getProductsByUserId:', error);
            throw new BadRequestError(
                error.message || Messages.PRODUCT.NOT_FOUND_PRODUCTS_EN || 'فشل في تحميل منتجاتك'
            );
        }
    }

    // Enhanced Search Methods
    async enhancedSearch(req: Request, res: Response): Promise<void> {
        try {
            const { 
                q: query = '', 
                category, 
                minPrice, 
                maxPrice, 
                sizes, 
                colors, 
                brands,
                inStock,
                rating,
                sortBy,
                page = 1, 
                limit = 20,
                includeInactive = false,
                fuzzySearch = false
            } = req.query;

            // Parse filters
            const filters: SearchFilters = {
                category: category as string,
                minPrice: minPrice ? parseFloat(minPrice as string) : undefined,
                maxPrice: maxPrice ? parseFloat(maxPrice as string) : undefined,
                sizes: sizes ? (sizes as string).split(',').map(s => s.trim()) : undefined,
                colors: colors ? (colors as string).split(',').map(c => c.trim()) : undefined,
                brands: brands ? (brands as string).split(',').map(b => b.trim()) : undefined,
                inStock: inStock === 'true',
                rating: rating ? parseFloat(rating as string) : undefined,
                sortBy: sortBy as any
            };

            // Parse options
            const options: SearchOptions = {
                page: Math.max(1, parseInt(page as string)),
                limit: Math.min(100, Math.max(1, parseInt(limit as string))),
                includeInactive: includeInactive === 'true',
                fuzzySearch: fuzzySearch === 'true'
            };

            const searchResult = await this.enhancedSearchService.search(
                query as string, 
                filters, 
                options
            );

            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: searchResult.total > 0 
                    ? `تم العثور على ${searchResult.total} منتج`
                    : 'لم يتم العثور على منتجات مطابقة',
                body: {
                    data: searchResult
                }
            }).send();

        } catch (error: any) {
            console.error('Error in enhancedSearch:', error);
            throw new BadRequestError(
                error.message || 'فشل في البحث عن المنتجات'
            );
        }
    }

    async getAutocompleteSuggestions(req: Request, res: Response): Promise<void> {
        try {
            const { q: query = '', limit = 10 } = req.query;

            if (!query || (query as string).length < 2) {
                new ApplicationResponse(res, {
                    success: true,
                    statusCode: StatusCodes.OK,
                    message: 'يجب أن يكون طول الاستعلام أكثر من حرفين',
                    body: {
                        data: {
                            suggestions: []
                        }
                    }
                }).send();
                return;
            }

            const suggestions = await this.enhancedSearchService.getAutocompleteSuggestions(
                query as string,
                Math.min(20, Math.max(1, parseInt(limit as string)))
            );

            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: 'تم تحميل الاقتراحات بنجاح',
                body: {
                    data: {
                        query: query,
                        suggestions: suggestions
                    }
                }
            }).send();

        } catch (error: any) {
            console.error('Error in getAutocompleteSuggestions:', error);
            throw new BadRequestError(
                error.message || 'فشل في تحميل الاقتراحات'
            );
        }
    }

    async getSearchAnalytics(req: Request, res: Response): Promise<void> {
        try {
            const userRole = req.user.role;

            // Only admins can access search analytics
            if (userRole !== 'admin') {
                throw new InsufficientPermissionsError('view search analytics');
            }

            const { days = 7 } = req.query;
            const analytics = await this.enhancedSearchService.getSearchAnalytics(
                Math.min(30, Math.max(1, parseInt(days as string)))
            );

            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: 'تم تحميل إحصائيات البحث بنجاح',
                body: {
                    data: analytics
                }
            }).send();

        } catch (error: any) {
            console.error('Error in getSearchAnalytics:', error);
            
            if (error instanceof InsufficientPermissionsError) {
                throw error;
            }
            
            throw new BadRequestError(
                error.message || 'فشل في تحميل إحصائيات البحث'
            );
        }
    }

    async clearSearchCache(req: Request, res: Response): Promise<void> {
        try {
            const userRole = req.user.role;

            // Only admins can clear search cache
            if (userRole !== 'admin') {
                throw new InsufficientPermissionsError('clear search cache');
            }

            await this.enhancedSearchService.clearSearchCache();

            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: 'تم مسح ذاكرة التخزين المؤقت للبحث بنجاح'
            }).send();

        } catch (error: any) {
            console.error('Error in clearSearchCache:', error);
            
            if (error instanceof InsufficientPermissionsError) {
                throw error;
            }
            
            throw new BadRequestError(
                error.message || 'فشل في مسح ذاكرة التخزين المؤقت'
            );
        }
    }
}