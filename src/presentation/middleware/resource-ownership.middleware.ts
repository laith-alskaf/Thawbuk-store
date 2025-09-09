import { Request, Response, NextFunction } from 'express';
import { Messages, StatusCodes, UserRoles } from '../config/constant';
import { Model } from 'mongoose';
import { ForbiddenError } from '../../application/errors/application-error';
import { CategoryModel } from '../../infrastructure/database/mongodb/models/category.model';
import { ProductModel } from '../../infrastructure/database/mongodb/models/product.model';

export interface IOwnership {
    createdBy: string;
}
export type ResourceDocument<T> = Document & T & IOwnership;

export const checkResourceOwnership = <T extends IOwnership>(
    model: Model<T>,
    idKey: string
) => {
    return async (req: Request, res: Response, next: NextFunction): Promise<any> => {
        try {
            if (!req.user) {
                throw new Error(Messages.AUTH.AUTHENTICATION_REQUIRED);
            }
            const resourceId = req.body[idKey] || req.params[idKey];
            var resource;
            if (idKey == 'productId') {
                resource = await ProductModel.findById(resourceId);
            }
            if (idKey == 'categoryId') {
                resource = await CategoryModel.findById(resourceId);
            }


            if (!resource) {
                throw new Error(Messages.GENERAL.INVALID_PARAMETERS);
            }
            const isSuperAdmin = req.user.role === UserRoles.SUPER_ADMIN;
            const isOwner = resource.createdBy === req.user.id;

            if (!isSuperAdmin && !isOwner) {
                new ForbiddenError(Messages.USER.UNAUTHORIZED_ACTION);
            }
            next();
        } catch (error: any) {
            throw error.message = Messages.GENERAL.INVALID_REQUEST;
        }
    };
};
