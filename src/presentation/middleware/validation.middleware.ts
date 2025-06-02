import { NextFunction } from 'express';
import Joi from 'joi';
import { Request, Response } from 'express';
import { Messages, StatusCodes } from '../config/constant';
import { ApplicationResponse } from '../../application/response/application-resposne';


interface ValidationConfig {
    schema: Joi.ObjectSchema;
    dataSource: 'body' | 'query' | 'params' | 'composite';
    useAsync?: boolean;
};

export const createValidationMiddleware = ({
    schema,
    dataSource,
    useAsync = false
}: ValidationConfig) => {
    return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
        try {

            const data = dataSource === 'composite'
                ? { ...req.params, ...req.body }
                : req[dataSource];

            if (useAsync) {
                await validateAsync(data, schema);
            } else {
                validateSync(data, schema);
            }
            next();
        } catch (error: any) {
            return new ApplicationResponse(res, {
                success: false,
                statusCode: StatusCodes.BAD_REQUEST,
                message: error.message
            }).send();
        }
    };
};
const validateAsync = async (data: any, schema: Joi.ObjectSchema) => {
    const { error } = await schema.validateAsync(data, {
        abortEarly: false,
        stripUnknown: true
    });
    if (error) throw new Error(error.message);
};

const validateSync = (data: any, schema: Joi.ObjectSchema) => {
    const { error } = schema.validate(data, {
        abortEarly: false,
        stripUnknown: true
    });
    if (error) throw new Error(error.message);
};