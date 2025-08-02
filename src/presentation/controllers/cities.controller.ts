import { Request, Response } from 'express';
import { SYRIAN_CITIES } from '../../application/constants/syrian-cities';
import { ApplicationResponse } from '../../application/response/application-resposne';
import { StatusCodes } from '../config/constant';

export class CitiesController {
    getSyrianCities = async (_req: Request, res: Response): Promise<void> => {
        try {
            return new ApplicationResponse(res, {
                statusCode: StatusCodes.OK,
                success: true,
                message: "تم جلب قائمة المحافظات بنجاح",
                body: { cities: SYRIAN_CITIES },
            }).send();
        } catch (error) {
            throw error;
        }
    };
}