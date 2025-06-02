import { Request, Response, NextFunction } from 'express';
import { Messages, StatusCodes, UserRoles } from '../config/constant';
import { Model } from 'mongoose';
import { ForbiddenError } from '../../application/errors/application-error';

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
                throw new Error(Messages.AUTH.AUTHENTICATION_REQUIRED_EN);
            }
            const resourceId = req.body[idKey] || req.params[idKey];
            const resource = await model.findById(resourceId);
            if (!resource) {
                throw new Error(Messages.GENERAL.INVALID_PARAMETERS_EN);
            }
            const isSuperAdmin = req.user.role === UserRoles.SUPER_ADMIN;
            const isOwner = resource.createdBy === req.user.id;

            if (!isSuperAdmin && !isOwner) {
                new ForbiddenError(Messages.USER.UNAUTHORIZED_ACTION_EN);
            }
            next();
        } catch (error: any) {
            throw error.message = Messages.GENERAL.INVALID_REQUEST_EN;
        }
    };
};