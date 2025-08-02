import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/http_client.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../services/fcm_service.dart';

// Data Sources
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../data/datasources/category_remote_data_source.dart';
import '../../data/datasources/user_remote_data_source.dart';
import '../../data/datasources/user_local_data_source.dart';
import '../../data/datasources/store_remote_data_source.dart';
import '../../data/datasources/wishlist_remote_data_source.dart';

// Repositories
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/store_repository_impl.dart';
import '../../data/repositories/wishlist_repository_impl.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/store_repository.dart';
import '../../domain/repositories/wishlist_repository.dart';

// Use Cases
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/verify_email_usecase.dart';
import '../../domain/usecases/auth/resend_verification_usecase.dart';
import '../../domain/usecases/product/get_products_usecase.dart';
import '../../domain/usecases/product/get_product_by_id_usecase.dart';
import '../../domain/usecases/product/search_products_usecase.dart';
import '../../domain/usecases/product/get_products_by_category_usecase.dart';
import '../../domain/usecases/product/get_filtered_products_usecase.dart';
import '../../domain/usecases/product/create_product_usecase.dart';
import '../../domain/usecases/product/update_product_usecase.dart';
import '../../domain/usecases/product/delete_product_usecase.dart';
import '../../domain/usecases/product/get_my_products_usecase.dart';
import '../../domain/usecases/category/get_categories_usecase.dart';
import '../../domain/usecases/store/get_store_profile_usecase.dart';
import '../../domain/usecases/store/get_store_products_usecase.dart';
import '../../domain/usecases/wishlist/get_wishlist_usecase.dart';
import '../../domain/usecases/wishlist/toggle_wishlist_usecase.dart';
import '../../domain/usecases/user/get_user_profile_usecase.dart';
import '../../domain/usecases/user/update_user_profile_usecase.dart';

// Blocs
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/product/product_bloc.dart';
import '../../presentation/bloc/category/category_bloc.dart';
import '../../presentation/bloc/theme/theme_cubit.dart';
import '../../presentation/bloc/store/store_bloc.dart';
import '../../presentation/bloc/wishlist/wishlist_bloc.dart';
import '../../presentation/bloc/user/user_bloc.dart';

// Navigation
import '../../presentation/navigation/app_router.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  // Core
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  
  // Services
  getIt.registerLazySingleton(() => FCMService());
  
  // HTTP Client setup
  getIt.registerLazySingleton(() => HttpClient(getIt<SharedPreferences>()));
  getIt.registerLazySingleton(() => ApiClient());

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
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<StoreRemoteDataSource>(
    () => StoreRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<WishlistRemoteDataSource>(
    () => WishlistRemoteDataSourceImpl(getIt()),
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
      productRemoteDataSource: getIt(),
      categoryRemoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
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
  getIt.registerLazySingleton<StoreRepository>(
    () => StoreRepositoryImpl(
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
  getIt.registerLazySingleton<WishlistRepository>(
    () => WishlistRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => VerifyEmailUseCase(getIt()));
  getIt.registerLazySingleton(() => ResendVerificationUseCase(getIt()));
  getIt.registerLazySingleton(() => GetProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetProductByIdUseCase(getIt()));
  getIt.registerLazySingleton(() => SearchProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetProductsByCategoryUseCase(getIt()));
  getIt.registerLazySingleton(() => GetFilteredProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateProductUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProductUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteProductUseCase(getIt()));
  getIt.registerLazySingleton(() => GetMyProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCategoriesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetStoreProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => GetStoreProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetWishlistUseCase(getIt()));
  getIt.registerLazySingleton(() => ToggleWishlistUseCase(getIt()));
  getIt.registerLazySingleton(() => GetUserProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateUserProfileUseCase(getIt()));

  // Blocs
  getIt.registerFactory(() => AuthBloc(
    loginUseCase: getIt(),
    registerUseCase: getIt(),
    logoutUseCase: getIt(),
    authRepository: getIt(),
    userRepository: getIt(),
    fcmService: getIt(),
    verifyEmailUseCase: getIt(),
    resendVerificationUseCase: getIt(),
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
  
  getIt.registerFactory(() => CategoryBloc(getIt()));
  
  getIt.registerFactory(() => StoreBloc(
    getStoreProfileUseCase: getIt(),
    getStoreProductsUseCase: getIt(),
  ));
  
  getIt.registerFactory(() => WishlistBloc(
    getWishlistUseCase: getIt(),
    toggleWishlistUseCase: getIt(),
  ));

  getIt.registerFactory(() => UserBloc(
    getUserProfileUseCase: getIt(),
    updateUserProfileUseCase: getIt(),
  ));

  getIt.registerLazySingleton(() => ThemeCubit());

  // Navigation
  getIt.registerLazySingleton(() => AppRouter());
}
