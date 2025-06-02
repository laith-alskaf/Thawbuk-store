import express, { Express } from "express";
import { CONFIG } from "./config/env";
import authRoutes from './routes/auth.route';
import { setupDependencies } from './dependencies';
import { authMiddleware } from './middleware/auth.middleware';
import cors from 'cors';
import swaggerUi from 'swagger-ui-express';
import swaggerSpec from './config/swagger';
import { corsOptions } from './config/corsOptions';
import categoryRouters from './routes/category.routes.ts/category.route';
import productRouters from './routes/product.routes.ts/product.route';
import publicProductRoutes from "./routes/product.routes.ts/public-product.route";
import wishlistRoutes from "./routes/wishlist.route";
import publicCategoryRouters from "./routes/category.routes.ts/public-category.route";
import { errorHandler, notFoundHandler } from "./middleware/error-handler.middleware";
import { logger } from "./middleware/logger.middleware";
import userRoutes from "./routes/user.routes";

export default class Server {
    private app: Express;
    private container: any;

    constructor() {
        this.app = express();
    }

    private setupMiddleware() {
        this.app.use(logger);
        this.app.use(express.json());
        this.app.use(authMiddleware(this.container.tokenService, this.container.userRepository))
    }

    private setupRoutes() {
        this.app.use(cors(corsOptions));
        this.app.use('/api/auth', authRoutes(this.container.authController));
        this.app.use('/api/user', userRoutes(this.container.userController));
        this.app.use('/api/user/product', productRouters(this.container.productController));
        this.app.use('/api/product', publicProductRoutes(this.container.productController));
        this.app.use('/api/user/category', categoryRouters(this.container.categoryController));
        this.app.use('/api/category', publicCategoryRouters(this.container.categoryController));
        this.app.use('/api/user/wishlist', wishlistRoutes(this.container.wishlistController));
    }

    private setupErrorHandlers() {
        this.app.use(notFoundHandler);
        this.app.use(errorHandler);
    }


    public async run(): Promise<void> {
        return new Promise((resolve) => {
            this.app.listen(CONFIG.PORT, () => {
                console.log(`Server is running on ${CONFIG.CLIENT_URL}`);
                resolve();
            });
        });
    }

    public init(): void {
        this.app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
        this.container = setupDependencies();
        this.setupMiddleware();
        this.setupRoutes();
        this.setupErrorHandlers();
    }
}

