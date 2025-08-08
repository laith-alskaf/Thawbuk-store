export const excludedPathsForAuth = [
    // Auth Routes
    "/api/auth/register",
    "/api/auth/login",
    "/api/auth/verify-email",
    "/api/auth/forgot-password",
    "/api/auth/change-password",
    '/api/auth/verify',
    '/api/auth/resend-verification',
    // Category Routes
    "/api/category",
    "/api/category/",
    /^\/api\/category\/[^/]+$/,

    // Product Routes  
    "/api/v2/product",
    "/api/v2/product/",
    /^\/api\/v2\/product\/[^/]+$/,
    /^\/api\/v2\/product\/byCategory\/[^/]+$/,
    /^\/api\/v2\/product\/search.*$/,

];