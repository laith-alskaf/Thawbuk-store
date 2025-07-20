export const excludedPathsForAuth = [
    // Auth Routes
    "/api/auth/register",
    "/api/auth/login", 
    "/api/auth/verify-email",
    "/api/auth/forgot-password",
    "/api/auth/change-password",

    // Category Routes
    "/api/category",
    "/api/category/",
    /^\/api\/category\/[^/]+$/,

    // Product Routes  
    "/api/product",
    "/api/product/",
    /^\/api\/product\/[^/]+$/,
    /^\/api\/product\/byCategory\/[^/]+$/,
    /^\/api\/product\/search.*$/,

];