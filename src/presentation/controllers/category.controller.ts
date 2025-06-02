import { Request, Response } from 'express';
import { Messages, StatusCodes } from '../config/constant';
import { CreateCategoryDTO, UpdateCategoryDTO } from '../../application/dtos/category.dto';
import {
    GetAllCategoriesUseCase,
    CreateCategoryUseCase,
    DeleteCategoryUseCase,
    GetCategoryByIdUseCase,
    UpdateCategoryUseCase,
} from '../../application/use-cases/category';
import { ApplicationResponse } from '../../application/response/application-resposne';
import { BadRequestError } from '../../application/errors/application-error';

export class CategoryController {

    constructor(
        private readonly getAllCategoriesUseCase: GetAllCategoriesUseCase,
        private readonly createCategoryUseCase: CreateCategoryUseCase,
        private readonly deleteCategoryUseCase: DeleteCategoryUseCase,
        private readonly getCategoryByIdUseCase: GetCategoryByIdUseCase,
        private readonly updateCategoryUseCase: UpdateCategoryUseCase,
    ) { }

    async getAllCategory(_req: Request, res: Response): Promise<void> {
        try {
            const category = await this.getAllCategoriesUseCase.execute();

            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.CATEGORY.GET_ALL_SUCCESS_EN,
                body: { categories: category }
            }).send();


        } catch (error: any) {
            throw new BadRequestError(Messages.CATEGORY.NOT_FOUND_CATEGORIES_EN);
        }
    }

    async createCategory(req: Request, res: Response): Promise<void> {
        try {
            const createCategoryDTO: Partial<CreateCategoryDTO> = req.body;
            createCategoryDTO.createdBy = req.user.id;
            await this.createCategoryUseCase.execute(createCategoryDTO);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.CREATED,
                message: Messages.CATEGORY.CREATE_SUCCESS_EN,
            }).send();

        } catch (error: any) {
            throw new BadRequestError(error.message);
        }
    }

    async deleteCategory(req: Request, res: Response): Promise<void> {
        try {
            const { categoryId } = req.params;
            await this.deleteCategoryUseCase.execute(categoryId);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.CATEGORY.DELETE_SUCCESS_EN
            }).send();

        } catch (error: any) {
            throw new BadRequestError(error.message);
        }
    }

    async updateCategory(req: Request, res: Response): Promise<void> {
        try {
            const { categoryId } = req.params;
            const updateCategoryDTO: Partial<UpdateCategoryDTO> = req.body.category;
            updateCategoryDTO.categoryId = categoryId;
            const updatedCategory = await this.updateCategoryUseCase.execute(updateCategoryDTO);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.CATEGORY.UPDATE_SUCCESS_EN,
                body: {
                    category: updatedCategory
                }
            }).send();
        } catch (error: any) {
            throw new BadRequestError(error.message);
        }
    }

    async getSingleCategory(req: Request, res: Response): Promise<void> {
        try {
            const { categoryId } = req.params;
            const category = await this.getCategoryByIdUseCase.execute(categoryId);
            new ApplicationResponse(res, {
                success: true,
                statusCode: StatusCodes.OK,
                message: Messages.CATEGORY.GET_SUCCESS_EN,
                body: {
                    category: category
                }
            }).send();

        } catch (error: any) {
            throw new BadRequestError(error.message);
        }
    }

}
