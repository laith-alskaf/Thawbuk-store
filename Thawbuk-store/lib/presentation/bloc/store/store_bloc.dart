import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/store_profile_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/store/get_store_profile_usecase.dart';
import '../../../domain/usecases/store/get_store_products_usecase.dart';
import '../../../core/errors/failures.dart';

// Events
abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object?> get props => [];
}

class LoadStoreProfile extends StoreEvent {
  final String storeId;

  const LoadStoreProfile(this.storeId);

  @override
  List<Object> get props => [storeId];
}

class LoadStoreProducts extends StoreEvent {
  final String storeId;
  final int page;
  final String? category;

  const LoadStoreProducts(
    this.storeId, {
    this.page = 1,
    this.category,
  });

  @override
  List<Object?> get props => [storeId, page, category];
}

class RefreshStore extends StoreEvent {
  final String storeId;

  const RefreshStore(this.storeId);

  @override
  List<Object> get props => [storeId];
}

// States
abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];
}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class StoreProfileLoaded extends StoreState {
  final StoreProfileEntity profile;

  const StoreProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

class StoreProductsLoaded extends StoreState {
  final StoreProfileEntity profile;
  final List<ProductEntity> products;
  final bool hasReachedMax;
  final int currentPage;

  const StoreProductsLoaded({
    required this.profile,
    required this.products,
    required this.hasReachedMax,
    required this.currentPage,
  });

  StoreProductsLoaded copyWith({
    StoreProfileEntity? profile,
    List<ProductEntity>? products,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return StoreProductsLoaded(
      profile: profile ?? this.profile,
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [profile, products, hasReachedMax, currentPage];
}

class StoreError extends StoreState {
  final String message;

  const StoreError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final GetStoreProfileUseCase getStoreProfileUseCase;
  final GetStoreProductsUseCase getStoreProductsUseCase;

  StoreBloc({
    required this.getStoreProfileUseCase,
    required this.getStoreProductsUseCase,
  }) : super(StoreInitial()) {
    on<LoadStoreProfile>(_onLoadStoreProfile);
    on<LoadStoreProducts>(_onLoadStoreProducts);
    on<RefreshStore>(_onRefreshStore);
  }

  Future<void> _onLoadStoreProfile(
    LoadStoreProfile event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreLoading());

    final result = await getStoreProfileUseCase(
      GetStoreProfileParams(storeId: event.storeId),
    );

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحميل بيانات المتجر';
        if (failure is ServerFailure) {
          message = failure.message;
        } else if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(StoreError(message));
      },
      (profile) => emit(StoreProfileLoaded(profile)),
    );
  }

  Future<void> _onLoadStoreProducts(
    LoadStoreProducts event,
    Emitter<StoreState> emit,
  ) async {
    if (state is StoreProfileLoaded) {
      final currentState = state as StoreProfileLoaded;
      
      final result = await getStoreProductsUseCase(
        GetStoreProductsParams(
          storeId: event.storeId,
          page: event.page,
          category: event.category,
        ),
      );

      result.fold(
        (failure) {
          String message = 'حدث خطأ أثناء تحميل منتجات المتجر';
          if (failure is ServerFailure) {
            message = failure.message;
          } else if (failure is NetworkFailure) {
            message = 'تحقق من اتصال الإنترنت';
          }
          emit(StoreError(message));
        },
        (products) {
          emit(StoreProductsLoaded(
            profile: currentState.profile,
            products: products,
            hasReachedMax: products.length < 20,
            currentPage: event.page,
          ));
        },
      );
    } else {
      // Load profile first, then products
      add(LoadStoreProfile(event.storeId));
    }
  }

  Future<void> _onRefreshStore(
    RefreshStore event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreLoading());
    add(LoadStoreProfile(event.storeId));
  }
}