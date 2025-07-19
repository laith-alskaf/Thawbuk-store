import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';

import '../constants/app_constants.dart';
import '../../data/models/user_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/order_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: AppConstants.baseUrl)
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Auth
  @POST(ApiEndpoints.login)
  Future<ApiResponse<Map<String, dynamic>>> login(
    @Body() Map<String, dynamic> loginData,
  );

  @POST(ApiEndpoints.register)
  Future<ApiResponse<void>> register(
    @Body() Map<String, dynamic> registerData,
  );

  @POST(ApiEndpoints.logout)
  Future<ApiResponse<void>> logout();

  @POST(ApiEndpoints.forgotPassword)
  Future<ApiResponse<void>> forgotPassword(
    @Body() Map<String, String> data,
  );

  @POST(ApiEndpoints.verifyEmail)
  Future<ApiResponse<void>> verifyEmail(
    @Body() Map<String, String> data,
  );

  // User
  @GET(ApiEndpoints.userProfile)
  Future<ApiResponse<UserModel>> getUserProfile();

  @PUT(ApiEndpoints.updateProfile)
  Future<ApiResponse<UserModel>> updateUserProfile(
    @Body() Map<String, dynamic> updateData,
  );

  // Products
  @GET(ApiEndpoints.products)
  Future<ApiResponse<ProductsResponse>> getProducts(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET('${ApiEndpoints.products}/{id}')
  Future<ApiResponse<ProductModel>> getProductById(
    @Path('id') String productId,
  );

  @GET('${ApiEndpoints.productsByCategory}/{categoryId}')
  Future<ApiResponse<List<ProductModel>>> getProductsByCategory(
    @Path('categoryId') String categoryId,
  );

  @GET(ApiEndpoints.searchProducts)
  Future<ApiResponse<ProductsResponse>> searchProducts(
    @Query('title') String query,
    @Query('categoryId') String? categoryId,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  // Categories
  @GET(ApiEndpoints.categories)
  Future<ApiResponse<List<CategoryModel>>> getCategories();

  // Cart
  @GET(ApiEndpoints.cart)
  Future<ApiResponse<CartModel>> getCart();

  @POST(ApiEndpoints.addToCart)
  Future<ApiResponse<CartModel>> addToCart(
    @Body() Map<String, dynamic> cartItem,
  );

  @PUT(ApiEndpoints.updateCart)
  Future<ApiResponse<CartModel>> updateCartItem(
    @Body() Map<String, dynamic> cartItem,
  );

  @DELETE('${ApiEndpoints.removeFromCart}/{productId}')
  Future<ApiResponse<CartModel>> removeFromCart(
    @Path('productId') String productId,
  );

  @DELETE(ApiEndpoints.clearCart)
  Future<ApiResponse<void>> clearCart();

  // Orders
  @GET(ApiEndpoints.orders)
  Future<ApiResponse<OrdersResponse>> getUserOrders(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @POST(ApiEndpoints.createOrder)
  Future<ApiResponse<OrderModel>> createOrder(
    @Body() Map<String, dynamic> orderData,
  );

  @GET('${ApiEndpoints.orders}/{orderId}')
  Future<ApiResponse<OrderModel>> getOrderById(
    @Path('orderId') String orderId,
  );
}

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? body;

  ApiResponse({
    required this.success,
    required this.message,
    this.body,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

@JsonSerializable()
class ProductsResponse {
  final List<ProductModel> products;
  final int total;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  ProductsResponse({
    required this.products,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductsResponseToJson(this);
}

@JsonSerializable()
class OrdersResponse {
  final List<OrderModel> orders;
  final int total;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  OrdersResponse({
    required this.orders,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) =>
      _$OrdersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrdersResponseToJson(this);
}