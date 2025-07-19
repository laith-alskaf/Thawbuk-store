import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/cart.dart';
import '../../../domain/usecases/cart/add_to_cart_usecase.dart';
import '../../../domain/usecases/cart/get_cart_usecase.dart';
import '../../../core/usecases/usecase.dart';

// Events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartEvent extends CartEvent {}

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
  final String? selectedSize;
  final String? selectedColor;

  const UpdateCartItemEvent({
    required this.productId,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
  });

  @override
  List<Object?> get props => [productId, quantity, selectedSize, selectedColor];
}

class RemoveFromCartEvent extends CartEvent {
  final String productId;

  const RemoveFromCartEvent({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class ClearCartEvent extends CartEvent {}

// States
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitialState extends CartState {}

class CartLoadingState extends CartState {}

class CartLoadedState extends CartState {
  final Cart cart;

  const CartLoadedState({required this.cart});

  @override
  List<Object?> get props => [cart];
}

class CartErrorState extends CartState {
  final String message;

  const CartErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class CartUpdatedState extends CartState {
  final String message;

  const CartUpdatedState({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  final AddToCartUseCase addToCartUseCase;
  final GetCartUseCase getCartUseCase;

  CartBloc({
    required this.addToCartUseCase,
    required this.getCartUseCase,
  }) : super(CartInitialState()) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartItemEvent>(_onUpdateCartItem);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onLoadCart(
    LoadCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoadingState());

    final result = await getCartUseCase(NoParams());

    result.fold(
      (failure) => emit(CartErrorState(message: failure.message)),
      (cart) => emit(CartLoadedState(cart: cart)),
    );
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final result = await addToCartUseCase(AddToCartParams(
      productId: event.productId,
      quantity: event.quantity,
      selectedSize: event.selectedSize,
      selectedColor: event.selectedColor,
    ));

    result.fold(
      (failure) => emit(CartErrorState(message: failure.message)),
      (cart) {
        emit(CartUpdatedState(message: 'تم إضافة المنتج إلى السلة'));
        emit(CartLoadedState(cart: cart));
      },
    );
  }

  Future<void> _onUpdateCartItem(
    UpdateCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    // سيتم تطبيقه لاحقاً مع إنشاء UpdateCartUseCase
    emit(CartUpdatedState(message: 'تم تحديث المنتج في السلة'));
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    // سيتم تطبيقه لاحقاً مع إنشاء RemoveFromCartUseCase
    emit(CartUpdatedState(message: 'تم حذف المنتج من السلة'));
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    // سيتم تطبيقه لاحقاً مع إنشاء ClearCartUseCase
    emit(CartUpdatedState(message: 'تم مسح السلة'));
  }
}