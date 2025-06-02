import { Request, Response, NextFunction } from 'express';
import { Messages } from '../config/constant';
import { UserRepository } from '../../domain/repository/user.repository';
import { CONFIG } from '../config/env';
import { TokenService } from '../../domain/services/token.service';
import { excludedPathsForAuth } from '../../application/constants/auth.exclusions';
import { BadRequestError, ForbiddenError, UnauthorizedError } from '../../application/errors/application-error';

declare global {
    namespace Express {
        interface Request {
            user: {
                id: string;
                role?: string;
            };
        }
    }
}

export const authMiddleware = (tokenService: TokenService, userRepository: UserRepository) => {
    return async (req: Request, res: Response, next: NextFunction): Promise<any> => {
        try {
            const isExcluded = excludedPathsForAuth.some(path => {
                if (typeof path === "string") {
                    return req.path === path;
                }
                if (path instanceof RegExp) {
                    return path.test(req.path);
                }
                return false;
            });

            if (isExcluded) {
                return next();
            }

            const authHeader = req.header('Authorization')?.trim();
            if (!authHeader || !authHeader.startsWith('Bearer ')) {
                throw new UnauthorizedError(Messages.AUTH.AUTHENTICATION_REQUIRED_EN);
            }
            const token = authHeader.split(' ')[1];
            if (!token) {
                throw new UnauthorizedError(Messages.AUTH.AUTHENTICATION_REQUIRED_EN);
            }

            const userInfo = await tokenService.verify(token, CONFIG.JWT_SECRET_ACCESS_TOKEN) as { id: string, role: string };
            if (!userInfo.id || !userInfo.role) {
                throw new ForbiddenError(Messages.AUTH.INVALID_TOKEN_EN);
            }

            const user = await userRepository.findById(userInfo.id);
            if (!user) {
                throw new BadRequestError(Messages.USER.USER_NOT_FOUND_EN)
            }

            req.user = {
                id: userInfo.id,
                role: userInfo.role
            };
            next();
        } catch (error) {
            throw new UnauthorizedError((error as any).message)
        }
    };
};