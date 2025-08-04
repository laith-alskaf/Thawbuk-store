import { Request, Response, NextFunction } from 'express';
import { ForbiddenError, UnauthorizedError } from '../../application/errors/application-error';
import { Messages } from '../config/constant';

// تعريف الأدوار المتاحة في النظام
export enum UserRole {
    ADMIN = 'admin',
    CUSTOMER = 'customer'
}

// تعريف الصلاحيات المختلفة
export enum Permission {
    // Product permissions
    CREATE_PRODUCT = 'create_product',
    UPDATE_PRODUCT = 'update_product',
    DELETE_PRODUCT = 'delete_product',
    VIEW_ALL_PRODUCTS = 'view_all_products',
    MANAGE_OWN_PRODUCTS = 'manage_own_products',
    
    // Category permissions
    CREATE_CATEGORY = 'create_category',
    UPDATE_CATEGORY = 'update_category',
    DELETE_CATEGORY = 'delete_category',
    
    // User permissions
    VIEW_USERS = 'view_users',
    MANAGE_USERS = 'manage_users',
    
    // Order permissions
    VIEW_ALL_ORDERS = 'view_all_orders',
    MANAGE_ORDERS = 'manage_orders'
}

// تعريف الصلاحيات لكل دور
const ROLE_PERMISSIONS: Record<UserRole, Permission[]> = {
    [UserRole.ADMIN]: [
        Permission.CREATE_PRODUCT,
        Permission.UPDATE_PRODUCT,
        Permission.DELETE_PRODUCT,
        Permission.VIEW_ALL_PRODUCTS,
        Permission.MANAGE_OWN_PRODUCTS,
        Permission.CREATE_CATEGORY,
        Permission.UPDATE_CATEGORY,
        Permission.DELETE_CATEGORY,
        Permission.VIEW_USERS,
        Permission.MANAGE_USERS,
        Permission.VIEW_ALL_ORDERS,
        Permission.MANAGE_ORDERS
    ],
    [UserRole.CUSTOMER]: [
        Permission.MANAGE_OWN_PRODUCTS // العملاء يمكنهم إدارة منتجاتهم فقط (إذا كانوا بائعين)
    ]
};

/**
 * Middleware للتحقق من وجود دور معين
 * @param allowedRoles - الأدوار المسموح لها بالوصول
 */
export const requireRole = (allowedRoles: UserRole[]) => {
    return (req: Request, res: Response, next: NextFunction): void => {
        try {
            // التحقق من وجود المستخدم (يجب أن يكون auth middleware قد تم تشغيله أولاً)
            if (!req.user) {
                throw new UnauthorizedError(Messages.AUTH.AUTHENTICATION_REQUIRED);
            }

            const userRole = req.user.role as UserRole;
            
            // التحقق من وجود الدور
            if (!userRole) {
                throw new ForbiddenError(Messages.AUTH.ROLE_NOT_ASSIGNED);
            }

            // التحقق من أن الدور مسموح
            if (!allowedRoles.includes(userRole)) {
                throw new ForbiddenError(Messages.AUTH.INSUFFICIENT_PERMISSIONS);
            }

            next();
        } catch (error) {
            next(error);
        }
    };
};

/**
 * Middleware للتحقق من وجود صلاحية معينة
 * @param requiredPermission - الصلاحية المطلوبة
 */
export const requirePermission = (requiredPermission: Permission) => {
    return (req: Request, res: Response, next: NextFunction): void => {
        try {
            // التحقق من وجود المستخدم
            if (!req.user) {
                throw new UnauthorizedError(Messages.AUTH.AUTHENTICATION_REQUIRED);
            }

            const userRole = req.user.role as UserRole;
            
            // التحقق من وجود الدور
            if (!userRole) {
                throw new ForbiddenError(Messages.AUTH.ROLE_NOT_ASSIGNED);
            }

            // الحصول على صلاحيات الدور
            const rolePermissions = ROLE_PERMISSIONS[userRole];
            
            // التحقق من وجود الصلاحية
            if (!rolePermissions.includes(requiredPermission)) {
                throw new ForbiddenError(Messages.AUTH.INSUFFICIENT_PERMISSIONS);
            }

            next();
        } catch (error) {
            next(error);
        }
    };
};

/**
 * Middleware للتحقق من أن المستخدم هو صاحب المورد أو لديه صلاحية إدارية
 * @param resourceOwnerField - اسم الحقل الذي يحتوي على معرف صاحب المورد
 */
export const requireOwnershipOrAdmin = (resourceOwnerField: string = 'createdBy') => {
    return (req: Request, res: Response, next: NextFunction): void => {
        try {
            // التحقق من وجود المستخدم
            if (!req.user) {
                throw new UnauthorizedError(Messages.AUTH.AUTHENTICATION_REQUIRED);
            }

            const userId = req.user.id;
            const userRole = req.user.role as UserRole;
            
            // إذا كان المستخدم أدمن، السماح بالوصول
            if (userRole === UserRole.ADMIN) {
                return next();
            }

            // التحقق من الملكية - سيتم التحقق في resource-ownership middleware
            // هذا middleware يعمل مع resource-ownership middleware
            next();
        } catch (error) {
            next(error);
        }
    };
};

/**
 * Helper function للتحقق من صلاحية المستخدم
 * @param userRole - دور المستخدم
 * @param requiredPermission - الصلاحية المطلوبة
 */
export const hasPermission = (userRole: UserRole, requiredPermission: Permission): boolean => {
    const rolePermissions = ROLE_PERMISSIONS[userRole];
    return rolePermissions.includes(requiredPermission);
};

/**
 * Helper function للحصول على جميع صلاحيات دور معين
 * @param userRole - دور المستخدم
 */
export const getRolePermissions = (userRole: UserRole): Permission[] => {
    return ROLE_PERMISSIONS[userRole] || [];
};

/**
 * Middleware للتحقق من أن المستخدم أدمن فقط
 */
export const requireAdmin = requireRole([UserRole.ADMIN]);

/**
 * Middleware للتحقق من أن المستخدم عميل أو أدمن
 */
export const requireCustomerOrAdmin = requireRole([UserRole.CUSTOMER, UserRole.ADMIN]);

/**
 * Middleware للتحقق من صلاحيات المنتجات
 */
export const ProductPermissions = {
    create: requirePermission(Permission.CREATE_PRODUCT),
    update: requirePermission(Permission.UPDATE_PRODUCT),
    delete: requirePermission(Permission.DELETE_PRODUCT),
    viewAll: requirePermission(Permission.VIEW_ALL_PRODUCTS),
    manageOwn: requirePermission(Permission.MANAGE_OWN_PRODUCTS)
};

/**
 * Middleware للتحقق من صلاحيات الفئات
 */
export const CategoryPermissions = {
    create: requirePermission(Permission.CREATE_CATEGORY),
    update: requirePermission(Permission.UPDATE_CATEGORY),
    delete: requirePermission(Permission.DELETE_CATEGORY)
};
