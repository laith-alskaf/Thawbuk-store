export const  PRODUCT = {
    CREATE_SUCCESS: "تم إنشاء المنتج بنجاح.",
    CREATE_SUCCESS_EN: "Product created successfully.",

    UPDATE_SUCCESS: "تم تحديث المنتج بنجاح.",
    UPDATE_SUCCESS_EN: "Product updated successfully.",

    DELETE_SUCCESS: "تم حذف المنتج بنجاح.",
    DELETE_SUCCESS_EN: "Product deleted successfully.",

    GET_SUCCESS: "تم الحصول على المنتج بنجاح.",
    GET_SUCCESS_EN: "Product retrieved successfully.",

    GET_ALL_SUCCESS: "تم الحصول على جميع المنتجات بنجاح.",
    GET_ALL_SUCCESS_EN: "All products retrieved successfully.",

    NOT_FOUND: "المنتج غير موجود.",
    NOT_FOUND_EN: "Product not found.",

    NOT_FOUND_PRODUCTS: "لم يتم العثور على منتجات.",
    NOT_FOUND_PRODUCTS_EN: "No products found.",

    NOT_FOUND_OPERATION: "المنتج غير موجود أو غير قابل للتحديث أو الحذف.",
    NOT_FOUND_OPERATION_EN: "The product does not exist or cannot be updated/deleted.",

    NO_RESULTS: "لم يتم العثور على نتائج مطابقة.",
    NO_RESULTS_EN: "No matching results found.",
    VALIDATION: {
        PRODUCT_VALIDATION: {
            TITLE_REQUIRED: "عنوان المنتج مطلوب",
            TITLE_REQUIRED_EN: "Product title is required",

            STOCK_INVALID: "كمية المخزون يجب أن تكون رقماً",
            STOCK_INVALID_EN: "Stock quantity must be a number",

            DESCRIPTION_REQUIRED: "وصف المنتج مطلوب",
            DESCRIPTION_REQUIRED_EN: "Product description is required",

            PRICE_REQUIRED: "سعر المنتج مطلوب",
            PRICE_REQUIRED_EN: "Product price is required",

            PRICE_INVALID: "السعر يجب أن يكون رقماً",
            PRICE_INVALID_EN: "Price must be a number",

            CATEGORY_REQUIRED: "معرف الفئة مطلوب",
            CATEGORY_REQUIRED_EN: "Category ID is required",

            IMAGE_URI_INVALID: "يجب أن يكون رابط الصورة صالحاً",
            IMAGE_URI_INVALID_EN: "Image URL must be valid"
        },

        PAGINATION_VALIDATION: {
            PAGE_INVALID: "رقم الصفحة يجب أن يكون رقماً",
            PAGE_INVALID_EN: "Page number must be a number",

            PAGE_MIN: "رقم الصفحة يجب أن يكون أكبر من أو يساوي 1",
            PAGE_MIN_EN: "Page number must be at least 1",

            LIMIT_INVALID: "حد العناصر يجب أن يكون رقماً",
            LIMIT_INVALID_EN: "Limit must be a number",

            LIMIT_MIN: "حد العناصر يجب أن يكون أكبر من أو يساوي 1",
            LIMIT_MIN_EN: "Limit must be at least 1"
        },

        SEARCH_VALIDATION: {
            CATEGORY_NOT_FOUND: "الفئة غير موجودة",
            CATEGORY_NOT_FOUND_EN: "Category not found",

            USER_NOT_FOUND: "المستخدم غير موجود",
            USER_NOT_FOUND_EN: "User not found",

            TITLE_INVALID: "عنوان المنتج يجب أن يكون نصاً",
            TITLE_INVALID_EN: "Product title must be a string",

            CATEGORY_ID_INVALID: "معرف الفئة يجب أن يكون نصاً",
            CATEGORY_ID_INVALID_EN: "Category ID must be a string",

            CREATOR_ID_INVALID: "معرف المنشئ يجب أن يكون نصاً",
            CREATOR_ID_INVALID_EN: "Creator ID must be a string"
        },

        GENERAL_VALIDATION: {
            PRODUCT_ID_REQUIRED: "معرف المنتج مطلوب",
            PRODUCT_ID_REQUIRED_EN: "Product ID is required",

            PRODUCT_DATA_REQUIRED: "بيانات المنتج مطلوبة",
            PRODUCT_DATA_REQUIRED_EN: "Product data is required",

            ID_INVALID: "المعرف يجب أن يكون نصاً",
            ID_INVALID_EN: "ID must be a string"
        }
    },
};