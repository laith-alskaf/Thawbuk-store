import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../network/http_client.dart';
import '../network/network_info.dart';

// Data Sources
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../data/datasources/category_remote_data_source.dart';
import '../../data/datasources/cart_remote_data_source.dart';
import '../../data/datasources/cart_local_data_source.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../../data/datasources/user_remote_data_source.dart';
import '../../data/datasources/user_local_data_source.dart';

// Repositories
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/user_repository.dart';

// Use Cases
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/verify_email_usecase.dart';
import '../../domain/usecases/product/get_products_usecase.dart';
import '../../domain/usecases/product/get_product_by_id_usecase.dart';
import '../../domain/usecases/product/search_products_usecase.dart';
import '../../domain/usecases/product/get_products_by_category_usecase.dart';
import '../../domain/usecases/product/get_filtered_products_usecase.dart';
import '../../domain/usecases/product/create_product_usecase.dart';
import '../../domain/usecases/product/update_product_usecase.dart';
import '../../domain/usecases/product/delete_product_usecase.dart';
import '../../domain/usecases/product/get_my_products_usecase.dart';
import '../../domain/usecases/cart/add_to_cart_usecase.dart';
import '../../domain/usecases/cart/get_cart_usecase.dart';
import '../../domain/usecases/cart/update_cart_usecase.dart';
import '../../domain/usecases/cart/remove_from_cart_usecase.dart';
import '../../domain/usecases/cart/clear_cart_usecase.dart';
import '../../domain/usecases/order/get_orders_usecase.dart';
import '../../domain/usecases/order/create_order_usecase.dart';
import '../../domain/usecases/category/get_categories_usecase.dart';

// Blocs
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/product/product_bloc.dart';
import '../../presentation/bloc/cart/cart_bloc.dart';
import '../../presentation/bloc/order/order_bloc.dart';
import '../../presentation/bloc/category/category_bloc.dart';
import '../../presentation/bloc/theme/theme_cubit.dart';

// Navigation
import '../../presentation/navigation/app_router.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  // Core
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  
  // HTTP Client setup
  getIt.registerLazySingleton(() => HttpClient(getIt<SharedPreferences>()));

  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => VerifyEmailUseCase(getIt()));
  getIt.registerLazySingleton(() => GetProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetProductByIdUseCase(getIt()));
  getIt.registerLazySingleton(() => SearchProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetProductsByCategoryUseCase(getIt()));
  getIt.registerLazySingleton(() => GetFilteredProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateProductUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProductUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteProductUseCase(getIt()));
  getIt.registerLazySingleton(() => GetMyProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => AddToCartUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCartUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateCartUseCase(getIt()));
  getIt.registerLazySingleton(() => RemoveFromCartUseCase(getIt()));
  getIt.registerLazySingleton(() => ClearCartUseCase(getIt()));
  getIt.registerLazySingleton(() => GetOrdersUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateOrderUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCategoriesUseCase(getIt()));

  // Blocs
  getIt.registerFactory(() => AuthBloc(
    loginUseCase: getIt(),
    registerUseCase: getIt(),
    logoutUseCase: getIt(),
    authRepository: getIt(),
    verifyEmailUseCase: getIt(),
  ));
  
  getIt.registerFactory(() => ProductBloc(
    getProductsUseCase: getIt(),
    getMyProductsUseCase: getIt(),
    getProductByIdUseCase: getIt(),
    searchProductsUseCase: getIt(),
    getProductsByCategoryUseCase: getIt(),
    getFilteredProductsUseCase: getIt(),
    createProductUseCase: getIt(),
    updateProductUseCase: getIt(),
    deleteProductUseCase: getIt(),
  ));
  
  getIt.registerFactory(() => CartBloc(
    addToCartUseCase: getIt(),
    getCartUseCase: getIt(),
    updateCartUseCase: getIt(),
    removeFromCartUseCase: getIt(),
    clearCartUseCase: getIt(),
  ));
  
  getIt.registerFactory(() => OrderBloc(
    getOrdersUseCase: getIt(),
    createOrderUseCase: getIt(),
  ));

  getIt.registerFactory(() => CategoryBloc(getIt()));
  
  getIt.registerLazySingleton(() => ThemeCubit());

  // Navigation
  getIt.registerLazySingleton(() => AppRouter());
}
