import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/order_entity.dart';
import '../../../domain/usecases/order/get_orders_usecase.dart';
import '../../../domain/usecases/order/create_order_usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';

// Events
abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class GetOrdersEvent extends OrderEvent {}

class CreateOrderEvent extends OrderEvent {
  final Map<String, dynamic> orderData;

  const CreateOrderEvent(this.orderData);

  @override
  List<Object> get props => [orderData];
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

class OrderCreated extends OrderState {
  final OrderEntity order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetOrdersUseCase getOrdersUseCase;
  final CreateOrderUseCase createOrderUseCase;

  OrderBloc({
    required this.getOrdersUseCase,
    required this.createOrderUseCase,
  }) : super(OrderInitial()) {
    
    on<GetOrdersEvent>(_onGetOrders);
    on<CreateOrderEvent>(_onCreateOrder);
  }

  Future<void> _onGetOrders(
    GetOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await getOrdersUseCase(NoParams());

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحميل الطلبات';
        if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(OrderError(message));
      },
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await createOrderUseCase(CreateOrderParams(
      orderData: event.orderData,
    ));

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء إنشاء الطلب';
        if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(OrderError(message));
      },
      (order) => emit(OrderCreated(order)),
    );
  }
}