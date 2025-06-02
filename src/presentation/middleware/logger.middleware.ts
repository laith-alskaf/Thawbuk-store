import { Request, Response, NextFunction } from 'express';

export const logger = (req: Request, _: Response, next: NextFunction) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
    next();
};