import { AUTH } from "./messages/auth-messages";
import { PRODUCT } from "./messages/product-messages";
import { CATEGORY } from "./messages/category_messages";
import { USER } from "./messages/user-messages";
import { WISHLIST } from "./messages/wishlist.messages";


export const StatusCodes = {
    // رموز النجاح (2xx)
    OK: 200,                   // طلب ناجح
    CREATED: 201,              // تم إنشاء مورد جديد
    NO_CONTENT: 204,           // طلب ناجح بدون محتوى للإرجاع

    // رموز أخطاء العميل (4xx)
    BAD_REQUEST: 400,          // طلب غير صالح
    UNAUTHORIZED: 401,         // غير مصرح (تحتاج إلى مصادقة)
    FORBIDDEN: 403,            // محظور (ليس لديك صلاحية)
    NOT_FOUND: 404,            // المورد غير موجود
    CONFLICT: 409,             // تعارض (مثل تكرار البيانات)
    UNPROCESSABLE_ENTITY: 422, // بيانات غير صالحة للمعالجة

    // رموز أخطاء الخادم (5xx)
    INTERNAL_SERVER_ERROR: 500, // خطأ داخلي في الخادم
    SERVICE_UNAVAILABLE: 503    // الخدمة غير متوفرة
};


export const Messages = {
    AUTH,
    USER,
    PRODUCT,
    CATEGORY,
    WISHLIST,
    GENERAL: {
        INVALID_PARAMETERS: "بيانات الإدخال غير صالحة",
        INVALID_PARAMETERS_EN: "Invalid input parameters",

        INTERNAL_ERROR: "حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقاً.",
        INTERNAL_ERROR_EN: "An unexpected error occurred. Please try again later.",

        INVALID_REQUEST: "طلب غير صالح. يرجى التحقق من البيانات المدخلة.",
        INVALID_REQUEST_EN: "Invalid request. Please check your input data.",

        SUCCESS: "تمت العملية بنجاح.",
        SUCCESS_EN: "Operation completed successfully.",

        FORBIDDEN: "غير مسموح لك بالوصول إلى هذا المورد.",
        FORBIDDEN_EN: "You are not allowed to access this resource."
    }
};

export const UserRoles = {
    SUPER_ADMIN: 'superAdmin',
    ADMIN: 'admin',
    CUSTOMER: 'customer'
};


export const AllowedFileTypes = {
    IMAGES: ['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
    DOCUMENTS: ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
};


export const Limits = {
    MAX_FILE_SIZE: 5 * 1024 * 1024,
    MAX_PRODUCTS_PER_PAGE: 50,
    DEFAULT_PAGE_SIZE: 10,
    PASSWORD_MIN_LENGTH: 6
};