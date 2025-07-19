import { CONFIG } from '../config/env';

// Srevices
import { JwtTokenService } from '../../infrastructure/srevices/jwt-token.service';
import { BcryptPasswordHasher } from '../../infrastructure/srevices/bcrypt-password-hasher.service';
import { NodemailerGmailService } from '../../infrastructure/srevices/nodemailer-gmail.service';
import { OTPGeneratorService } from '../../infrastructure/srevices/otp-generator.service';
import { UuidGeneratorService } from '../../infrastructure/srevices/uuid-generator.service';

// Repositories
import { MongoUserRepository } from '../../infrastructure/repositories/mongo/mongo-user.repository';
import { MongoProductRepository } from '../../infrastructure/repositories/mongo/mongo-product.repository';
import { MongoCategoryRepository } from '../../infrastructure/repositories/mongo/mongo-category.repository';
import { CartRepository } from '../../infrastructure/repositories/cart.repository';
import { OrderRepository } from '../../infrastructure/repositories/order.repository';

// Controllers Dependencies
import { AuthDependencies } from './auth.dependencies';
import { ProductDependencies } from './product.dependencies';
import { CategoryDependencies } from './category.dependencies';
import { WishlistDependencies } from './wishlist.dependencies';
import { CartDependencies } from './cart.dependencies';
import { OrderDependencies } from './order.dependencies';
import { MongoWishlistRepository } from '../../infrastructure/repositories/mongo/mongo-wishlist.repository';
import { UserDependencies } from './user.depednencies';
import { NewProductNotification } from '../../infrastructure/srevices/notif-new-product';
import { CloudImageService } from '../../infrastructure/srevices/cloud-image.service';


export const setupDependencies = () => {

    // Repositories
    const userRepository = new MongoUserRepository();
    const prodcutRepository = new MongoProductRepository();
    const categoryRepository = new MongoCategoryRepository();
    const wishlistRepository = new MongoWishlistRepository();
    const cartRepository = new CartRepository();
    const orderRepository = new OrderRepository();
    // const userRepository = new PostgresUserRepository();
    // const prodcutRepository = new PostgresProductRepository();
    // const categoryRepository = new PostgresCategoryRepository();
    // const wishlistRepository = new PostgresWishlistRepository();


    // Services
    const tokenService = new JwtTokenService();
    const uuidGeneratorService = new UuidGeneratorService();
    const otpStringGenerator = new OTPGeneratorService();
    const encryptionService = new BcryptPasswordHasher(CONFIG.SALT_ROUNDS_BCRYPT);
    const emailService = new NodemailerGmailService(CONFIG.GMAIL_USER!, CONFIG.GMAIL_PASS!);
    const newProductNotification = new NewProductNotification();
    const uploudImageService = new CloudImageService();

    //Controllers

    // 1- Auth
    const authController = AuthDependencies({
        tokenService: tokenService,
        userRepository: userRepository,
        encryptionService: encryptionService,
        emailService: emailService,
        otpGeneratorService: otpStringGenerator,
        uuidGeneratorService: uuidGeneratorService,
    });

    //2- Product
    const productController = ProductDependencies({
        productRepository: prodcutRepository,
        uuidGeneratorService: uuidGeneratorService,
        newProductNotification: newProductNotification,
        uploudImageService: uploudImageService
    });

    //3- Category
    const categoryController = CategoryDependencies({
        uuidGeneratorService: uuidGeneratorService,
        categoryRepository: categoryRepository,
        uploudImageService: uploudImageService
    });

    //3- Wishlist
    const wishlistController = WishlistDependencies({
        wishlistRepository: wishlistRepository
    });

    //4- User
    const userController = UserDependencies({
        userRepository: userRepository,
    });

    return {
        tokenService,
        userRepository,
        authController,
        productController,
        categoryController,
        wishlistController,
        userController
    };
};