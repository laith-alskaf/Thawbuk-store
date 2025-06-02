import { Request, Response, NextFunction } from 'express';
import { ApplicationError } from '../../application/errors/application-error';
import { ApplicationResponse } from '../../application/response/application-resposne';
import { Messages, StatusCodes } from '../config/constant';


export const errorHandler = (err: Error, _: Request, res: Response, __: NextFunction) => {

    if (err instanceof ApplicationError) {
        return new ApplicationResponse(res, {
            statusCode: err.statusCode,
            success: false,
            message: err.message,
        }).send()
    }

    return new ApplicationResponse(res, {
        statusCode: res.statusCode || StatusCodes.INTERNAL_SERVER_ERROR,
        success: false,
        message: err.message || Messages.GENERAL.INTERNAL_ERROR_EN,
    }).send()

};

export const notFoundHandler = (req: Request, res: Response) => {
    return new ApplicationResponse(res, {
        statusCode: StatusCodes.NOT_FOUND,
        success: false,
        message: `Not Found - ${req.originalUrl}`,
    }).send()
};
