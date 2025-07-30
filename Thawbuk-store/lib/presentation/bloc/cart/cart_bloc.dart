import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/cart_entity.dart';
import '../../../domain/usecases/cart/get_cart_usecase.dart';
import '../../../domain/usecases/cart/add_to_cart_usecase.dart';
import '../../../domain/usecases/cart/update_cart_usecase.dart';
import '../../../domain/usecases/cart/remove_from_cart_usecase.dart';
import '../../../domain/usecases/cart/clear_cart_usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../core/events/app_events.dart';

// Events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class GetCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final String productId;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;

  const AddToCartEvent({
    required this.productId,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
  });

  @override
  List<Object?> get props => [productId, quantity, selectedSize, selectedColor];
}

class UpdateCartItemEvent extends CartEvent {
  final String productId;
  final int quantity;

  const UpdateCartItemEvent({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object> get props => [productId, quantity];
}

class RemoveFromCartEvent extends CartEvent {
  final String productId;

  const RemoveFromCartEvent(this.productId);

  @override
  List<Object> get props => [productId];
}

class ClearCartEvent extends CartEvent {}

// States
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final CartEntity cart;

  const CartLoaded(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

class CartItemAdded extends CartState {
  final CartEntity cart;

  const CartItemAdded(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartItemUpdated extends CartState {
  final CartEntity cart;

  const CartItemUpdated(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartItemRemoved extends CartState {
  final CartEntity cart;

  const CartItemRemoved(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartCleared extends CartState {}

// BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final UpdateCartUseCase updateCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final ClearCartUseCase clearCartUseCase;
  
  late StreamSubscription _eventSubscription;

  CartBloc({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.updateCartUseCase,
    required this.removeFromCartUseCase,
    required this.clearCartUseCase,
  }) : super(CartInitial()) {
    on<GetCartEvent>(_onGetCart);
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartItemEvent>(_onUpdateCartItem);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ClearCartEvent>(_onClearCart);
    
    // الاستماع لأحداث التنظيف
    _eventSubscription = EventBus.events.listen((event) {
      if (event is ClearCartEvent || event is AppLogoutEvent) {
        add(ClearCartEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _eventSubscription.cancel();
    return super.close();
  }

  Future<void> _onGetCart(
    GetCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final result = await getCartUseCase(NoParams());

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحميل السلة';
        if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(CartError(message));
      },
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final result = await addToCartUseCase(AddToCartParams(
      productId: event.productId,
      quantity: event.quantity,
      size: event.selectedSize,
      color: event.selectedColor,
    ));

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء إضافة المنتج للسلة';
        if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(CartError(message));
      },
      (cart) => emit(CartItemAdded(cart)),
    );
  }

  Future<void> _onUpdateCartItem(
    UpdateCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final result = await updateCartUseCase(UpdateCartParams(
      productId: event.productId,
      quantity: event.quantity,
    ));

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحديث السلة';
        if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(CartError(message));
      },
      (cart) => emit(CartItemUpdated(cart)),
    );
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final result = await removeFromCartUseCase(RemoveFromCartParams(
      productId: event.productId,
    ));

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء حذف المنتج من السلة';
        if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(CartError(message));
      },
      (cart) => emit(CartItemRemoved(cart)),
    );
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final result = await clearCartUseCase(NoParams());

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء مسح السلة';
        if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(CartError(message));
      },
      (_) => emit(CartCleared()),
    );
  }
}
