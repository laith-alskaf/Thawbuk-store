// import '../../data/models/user_model.dart';
// import '../../data/models/product_model.dart';
// import '../../data/models/category_model.dart';
// import '../../data/models/cart_model.dart';
// import '../../data/models/order_model.dart';
//
// part 'api_client.g.dart';
//
// @RestApi()
// abstract class ApiClient {
//   factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;
//
//   // Auth endpoints
//   @POST('/auth/register')
//   Future<UserModel> register(@Body() Map<String, dynamic> userData);
//
//   @POST('/auth/login')
//   Future<UserModel> login(@Body() Map<String, dynamic> credentials);
//
//   @POST('/auth/logout')
//   Future<void> logout();
//
//   @GET('/user/me')
//   Future<UserModel> getCurrentUser();
//
//   // Product endpoints
//   @GET('/product')
//   Future<List<ProductModel>> getProducts();
//
//   @GET('/product/{id}')
//   Future<ProductModel> getProductById(@Path() String id);
//
//   @POST('/user/product')
//   Future<ProductModel> createProduct(@Body() Map<String, dynamic> productData);
//
//   @PUT('/user/product/{id}')
//   Future<ProductModel> updateProduct(
//     @Path() String id,
//     @Body() Map<String, dynamic> productData,
//   );
//
//   @DELETE('/user/product/{id}')
//   Future<void> deleteProduct(@Path() String id);
//
//   @GET('/product/search')
//   Future<List<ProductModel>> searchProducts(@Query('q') String query);
//
//   @GET('/product/byCategory')
//   Future<List<ProductModel>> getProductsByCategory(@Query('category') String category);
//
//   // Category endpoints
//   @GET('/category')
//   Future<List<CategoryModel>> getCategories();
//
//   @GET('/category/{id}')
//   Future<CategoryModel> getCategoryById(@Path() String id);
//
//   @POST('/user/category')
//   Future<CategoryModel> createCategory(@Body() Map<String, dynamic> categoryData);
//
//   @PUT('/user/category/{id}')
//   Future<CategoryModel> updateCategory(
//     @Path() String id,
//     @Body() Map<String, dynamic> categoryData,
//   );
//
//   @DELETE('/user/category/{id}')
//   Future<void> deleteCategory(@Path() String id);
//
//   // Cart endpoints
//   @GET('/user/cart')
//   Future<CartModel> getCart();
//
//   @POST('/user/cart/add')
//   Future<CartModel> addToCart(@Body() Map<String, dynamic> cartData);
//
//   @PUT('/user/cart/update')
//   Future<CartModel> updateCartItem(@Body() Map<String, dynamic> updateData);
//
//   @DELETE('/user/cart/remove/{productId}')
//   Future<CartModel> removeFromCart(@Path() String productId);
//
//   @DELETE('/user/cart/clear')
//   Future<void> clearCart();
//
//   // Order endpoints
//   @GET('/user/order')
//   Future<List<OrderModel>> getOrders();
//
//   @GET('/user/order/{id}')
//   Future<OrderModel> getOrderById(@Path() String id);
//
//   @POST('/user/order')
//   Future<OrderModel> createOrder(@Body() Map<String, dynamic> orderData);
//
//   @PUT('/user/order/{id}/status')
//   Future<OrderModel> updateOrderStatus(
//     @Path() String id,
//     @Body() Map<String, dynamic> statusData,
//   );
//
//   @DELETE('/user/order/{id}')
//   Future<void> cancelOrder(@Path() String id);
//
//   // Wishlist endpoints
//   @GET('/user/wishlist')
//   Future<List<ProductModel>> getWishlist();
//
//   @POST('/user/wishlist')
//   Future<void> addToWishlist(@Body() Map<String, dynamic> wishlistData);
//
//   @DELETE('/user/wishlist/{productId}')
//   Future<void> removeFromWishlist(@Path() String productId);
// }