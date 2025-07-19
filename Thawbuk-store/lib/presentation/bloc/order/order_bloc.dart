import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/order_entity.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';

// Events
abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class GetOrdersEvent extends OrderEvent {}

class GetOrderByIdEvent extends OrderEvent {
  final String orderId;

  const GetOrderByIdEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class CreateOrderEvent extends OrderEvent {
  final AddressEntity shippingAddress;
  final String? notes;

  const CreateOrderEvent({
    required this.shippingAddress,
    this.notes,
  });

  @override
  List<Object?> get props => [shippingAddress, notes];
}

class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final OrderStatus status;

  const UpdateOrderStatusEvent({
    required this.orderId,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, status];
}

class CancelOrderEvent extends OrderEvent {
  final String orderId;

  const CancelOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

// States
abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderLoaded extends OrderState {
  final OrderEntity order;

  const OrderLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderCreated extends OrderState {
  final OrderEntity order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderStatusUpdated extends OrderState {
  final OrderEntity order;

  const OrderStatusUpdated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderCancelled extends OrderState {
  final String orderId;

  const OrderCancelled(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    
    on<GetOrdersEvent>(_onGetOrders);
    on<GetOrderByIdEvent>(_onGetOrderById);
    on<CreateOrderEvent>(_onCreateOrder);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<CancelOrderEvent>(_onCancelOrder);
  }

  Future<void> _onGetOrders(
    GetOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      // TODO: Implement get orders with API
      await Future.delayed(const Duration(seconds: 1));

      // Mock orders for now
      final orders = <OrderEntity>[];
      
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(const OrderError('حدث خطأ أثناء تحميل الطلبات'));
    }
  }

  Future<void> _onGetOrderById(
    GetOrderByIdEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      // TODO: Implement get order by ID with API
      await Future.delayed(const Duration(seconds: 1));

      // Mock order
      final order = OrderEntity(
        id: event.orderId,
        userId: 'mock-user-id',
        items: [],
        totalAmount: 0,
        status: OrderStatus.pending,
        shippingAddress: const AddressEntity(
          fullName: 'Mock User',
          phone: '123456789',
          street: 'Mock Street',
          city: 'Damascus',
          state: 'Damascus',
          country: 'Syria',
        ),
        createdAt: DateTime.now(),
      );

      emit(OrderLoaded(order));
    } catch (e) {
      emit(const OrderError('حدث خطأ أثناء تحميل الطلب'));
    }
  }

  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      // TODO: Implement create order with API
      await Future.delayed(const Duration(seconds: 2));

      // Mock order creation
      final order = OrderEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'mock-user-id',
        items: [],
        totalAmount: 0,
        status: OrderStatus.pending,
        shippingAddress: event.shippingAddress,
        notes: event.notes,
        createdAt: DateTime.now(),
      );

      emit(OrderCreated(order));
    } catch (e) {
      emit(const OrderError('حدث خطأ أثناء إنشاء الطلب'));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      // TODO: Implement update order status with API
      await Future.delayed(const Duration(seconds: 1));

      // Mock order update
      final order = OrderEntity(
        id: event.orderId,
        userId: 'mock-user-id',
        items: [],
        totalAmount: 0,
        status: event.status,
        shippingAddress: const AddressEntity(
          fullName: 'Mock User',
          phone: '123456789',
          street: 'Mock Street',
          city: 'Damascus',
          state: 'Damascus',
          country: 'Syria',
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      emit(OrderStatusUpdated(order));
    } catch (e) {
      emit(const OrderError('حدث خطأ أثناء تحديث حالة الطلب'));
    }
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      // TODO: Implement cancel order with API
      await Future.delayed(const Duration(seconds: 1));

      emit(OrderCancelled(event.orderId));
      
      // Refresh orders list
      add(GetOrdersEvent());
    } catch (e) {
      emit(const OrderError('حدث خطأ أثناء إلغاء الطلب'));
    }
  }
}