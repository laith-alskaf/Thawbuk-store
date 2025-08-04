import express, { Express } from "express";
import { CONFIG } from "./config/env";
import authRoutes from './routes/auth.route';
import { setupDependencies } from './dependencies';
import { authMiddleware } from './middleware/auth.middleware';
import cors from 'cors';
import { corsOptions } from './config/corsOptions';
import categoryRouters from './routes/category.routes.ts/category.route';
import { 
    enhancedProductRoutes, 
    enhancedUserProductRoutes, 
    enhancedAdminProductRoutes 
} from "./routes/enhanced-product.routes";
import wishlistRoutes from "./routes/wishlist.route";
import publicCategoryRouters from "./routes/category.routes.ts/public-category.route";
import cartRoutes from "./routes/cart.route";
import orderRoutes from "./routes/order.route";
import { errorHandler } from "./middleware/error-handler.middleware";
import { logger } from "./middleware/logger.middleware";
import userRoutes from "./routes/user.routes";
import citiesRoutes from "./routes/cities.routes";
import bodyParser from "body-parser";
import { createRateLimit, RateLimitConfigs } from "./middleware/rate-limit.middleware";
import { EnhancedErrorHandler, notFoundHandler, healthCheck } from "./middleware/enhanced-error-handler.middleware";

export default class Server {
    private app: Express;
    private container: any;

    constructor() {
        this.app = express();
    }

    private setupMiddleware() {
        this.app.use(logger);
        this.app.use(express.json());
        this.app.use(bodyParser.urlencoded({ extended: true }));
        this.app.use(bodyParser.json());
        
        // Rate limiting
        this.app.use('/api/auth', createRateLimit(this.container.cacheService, RateLimitConfigs.AUTH));
        this.app.use('/api/v2/product/enhanced-search', createRateLimit(this.container.cacheService, RateLimitConfigs.SEARCH));
        this.app.use('/api/v2/user/product', createRateLimit(this.container.cacheService, RateLimitConfigs.PRODUCT_CREATE));
        this.app.use('/api', createRateLimit(this.container.cacheService, RateLimitConfigs.GENERAL));
        
        
        this.app.use(authMiddleware(this.container.tokenService, this.container.userRepository))
    }

    private setupRoutes() {
        this.app.use(cors(corsOptions));
        
        // Health check endpoint
        this.app.get('/health', healthCheck);
        this.app.get('/api/health', healthCheck);
        
        // Authentication routes
        this.app.use('/api/auth', authRoutes(this.container.authController));
        
        // User routes
        this.app.use('/api/user', userRoutes(this.container.userController));
        
        // Enhanced Product routes (NEW - with role-based access control)
        this.app.use('/api/v2/product', enhancedProductRoutes(this.container.enhancedProductController));
        this.app.use('/api/v2/user/product', enhancedUserProductRoutes(this.container.enhancedProductController));
        this.app.use('/api/v2/admin/product', enhancedAdminProductRoutes(this.container.enhancedProductController));
        
        // Legacy Product routes (keeping for backward compatibility)
        // this.app.use('/api/user/product', productRouters(this.container.productController));
        // this.app.use('/api/product', publicProductRoutes(this.container.productController));
        
        // Category routes
        this.app.use('/api/user/category', categoryRouters(this.container.categoryController));
        this.app.use('/api/category', publicCategoryRouters(this.container.categoryController));
        
        // Other routes
        this.app.use('/api/user/wishlist', wishlistRoutes(this.container.wishlistController));
        this.app.use('/api/user/cart', cartRoutes(this.container.cartController));
        this.app.use('/api/user/order', orderRoutes(this.container.orderController));
        this.app.use('/api/cities', citiesRoutes());

        // 404 handler for undefined routes
        this.app.use('*', notFoundHandler);

        // Enhanced error handler (must be last)
        this.app.use(EnhancedErrorHandler.handle);
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
        // this.app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
        this.container = setupDependencies();
        this.setupMiddleware();
        this.setupRoutes();
        this.setupErrorHandlers();
    }
}

