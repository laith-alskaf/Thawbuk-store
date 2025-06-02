import { Request, Response } from 'express';
import { CreateProductDTO, DeleteProductDTO, GetProductsByUserIdDTO, PeginationProductDTO, SearchProductDTO, UpdateProductDTO } from '../../application/dtos/product.dto';
import { Messages, StatusCodes } from '../config/constant';
import {
    GetProductByIdUseCase,
    GetProductsByCategoryIdUseCase,
    GetProductsByUserIdUseCase,
    DeleteProductUseCase,
    CreateProductUseCase,
    UpdatedProductUseCase,
    GetAllProductsUseCase,
    SearchProductsUseCase,
} from "../../application/use-cases/product";
import { ApplicationResponse } from '../../application/response/application-resposne';
import { BadRequestError } from '../../application/errors/application-error';


export class ProductController {

    constructor(
        private readonly getProductByIdUseCase: GetProductByIdUseCase,
        private readonly getProductsByCategoryIdUseCase: GetProductsByCategoryIdUseCase,
        private readonly getProductsByUserIdUseCase: GetProductsByUserIdUseCase,
        private readonly deleteProductUseCase: DeleteProductUseCase,
        private readonly createProductUseCase: CreateProductUseCase,
        private readonly updatedProductUseCase: UpdatedProductUseCase,
        private readonly getAllProductsUseCase: GetAllProductsUseCase,
        private readonly searchProductsUseCase: SearchProductsUseCase
    ) { }

    async getAllProducts(req: Request, res: Response): Promise<void> {
        try {
            const peginationProductDTO: PeginationProductDTO = {
                page: parseInt(req.query.page as string) || 1,
                limit: parseInt(req.query.limit as string) || 5
            };
            const { productData, total } = await this.getAllProductsUseCase.execute(peginationProductDTO, {});

            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.GET_ALL_SUCCESS_EN,
                body: {
                    currentPage: peginationProductDTO.page,
                    totalPages: Math.ceil(total / peginationProductDTO.limit),
                    totalItems: total,
                    products: productData,
                }
            }).send();

        } catch (error: any) {
            throw new BadRequestError(Messages.PRODUCT.NOT_FOUND_PRODUCTS_EN);
        }
    }

    async createProduct(req: Request, res: Response): Promise<void> {

        try {
            const body = req.body;
            const userId = req.user.id
            const createProductDTO: CreateProductDTO = {
                ...body,
                createdBy: userId
            };
            createProductDTO.createdBy = req.user.id;
            await this.createProductUseCase.execute(createProductDTO);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.CREATED,
                message: Messages.PRODUCT.CREATE_SUCCESS_EN,
            }).send();
        } catch (error: any) {
            throw new BadRequestError(error.message);
        }
    }

    async deleteProduct(req: Request, res: Response): Promise<void> {
        try {
            const { productId } = req.params;
            console.log(productId);
            const deleteProductDTO: DeleteProductDTO = { productId: productId };
            await this.deleteProductUseCase.execute(deleteProductDTO);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.DELETE_SUCCESS_EN,
            }).send();

        } catch (error: any) {
            throw new BadRequestError(Messages.PRODUCT.NOT_FOUND_OPERATION_EN);
        }
    }

    async updateProduct(req: Request, res: Response): Promise<void> {
        try {
            const { product } = req.body;
            const { productId } = req.params;
            const updateProductDTO: UpdateProductDTO = {
                productId,
                product,
                updatedAt: new Date(),
            }
            const updatedProduct = await this.updatedProductUseCase.execute(updateProductDTO);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.UPDATE_SUCCESS_EN,
                body: {
                    product: updatedProduct
                }
            }).send();

        } catch (error: any) {
            throw new BadRequestError(Messages.PRODUCT.NOT_FOUND_OPERATION_EN);
        }
    }

    async getSingleProduct(req: Request, res: Response): Promise<void> {
        try {
            const { productId } = req.params;
            const prodcut = await this.getProductByIdUseCase.execute(productId);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.GET_SUCCESS_EN,
                body: {
                    product: prodcut
                }
            }).send();

        } catch (error: any) {
            throw new BadRequestError(error.message);
        }
    }

    async getProductsByCategoryId(req: Request, res: Response): Promise<void> {
        try {
            const { categoryId } = req.params;
            const prodcuts = await this.getProductsByCategoryIdUseCase.execute(categoryId);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.GET_ALL_SUCCESS_EN,
                body: {
                    products: prodcuts
                }
            }).send();

        } catch (error: any) {
            throw new BadRequestError(Messages.PRODUCT.NOT_FOUND_PRODUCTS_EN);
        }
    }


    async searchProducts(req: Request, res: Response): Promise<void> {
        try {
            const { title = '', categoryId = null, page = 1, limit = 10, createdId = null } = req.query;
            const searchProductDTO: SearchProductDTO = {
                title: title as string,
                categoryId: categoryId as string,
                createdId: createdId as string,
                peginationProduct: {
                    page: parseInt(page as string) || 1,
                    limit: parseInt(limit as string) || 10,
                }
            }
            const prodcuts = await this.searchProductsUseCase.execute(searchProductDTO);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.GET_ALL_SUCCESS_EN,
                body: {
                    total: prodcuts.total,
                    products: prodcuts.productData,
                }
            }).send();

        } catch (error: any) {
            throw new BadRequestError(Messages.PRODUCT.NO_RESULTS_EN);
        }
    }

    async getProductsByUserId(req: Request, res: Response): Promise<void> {
        try {
            const userId = req.user.id;
            console.log(userId);
            const { page = 1, limit = 10 } = req.query;
            const getProductsByUserIdDTO: GetProductsByUserIdDTO = {
                filter: { createdBy: userId },
                peginationProduct: {
                    page: parseInt(page as string),
                    limit: parseInt(limit as string),
                }

            }
            const { productData, total } = await this.getProductsByUserIdUseCase.execute(getProductsByUserIdDTO);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.PRODUCT.GET_ALL_SUCCESS_EN,
                body: {
                    currentPage: getProductsByUserIdDTO.peginationProduct.page,
                    totalPages: Math.ceil(total / getProductsByUserIdDTO.peginationProduct.limit),
                    totalItems: total,
                    products: productData,
                }
            }).send();

        } catch (error: any) {
            throw new BadRequestError(Messages.PRODUCT.NOT_FOUND_PRODUCTS_EN);
        }
    }


}
