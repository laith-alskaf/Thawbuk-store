import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/wishlist_entity.dart';
import '../../../domain/usecases/wishlist/get_wishlist_usecase.dart';
import '../../../domain/usecases/wishlist/toggle_wishlist_usecase.dart';
import '../../../domain/usecases/wishlist/clear_wishlist_usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../core/events/app_events.dart';

// Events
abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class GetWishlistEvent extends WishlistEvent {}

class ToggleWishlistEvent extends WishlistEvent {
  final String productId;

  const ToggleWishlistEvent(this.productId);

  @override
  List<Object> get props => [productId];
}

class ClearWishlistEvent extends WishlistEvent {}

// States
abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final WishlistEntity wishlist;

  const WishlistLoaded(this.wishlist);

  @override
  List<Object?> get props => [wishlist];
}

class WishlistError extends WishlistState {
  final String message;

  const WishlistError(this.message);

  @override
  List<Object?> get props => [message];
}

class WishlistItemToggled extends WishlistState {
  final String productId;
  final bool isAdded;
  final WishlistEntity? wishlist;

  const WishlistItemToggled({
    required this.productId,
    required this.isAdded,
    this.wishlist,
  });

  @override
  List<Object?> get props => [productId, isAdded, wishlist];
}

class WishlistCleared extends WishlistState {}

// BLoC
class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final GetWishlistUseCase getWishlistUseCase;
  final ToggleWishlistUseCase toggleWishlistUseCase;
  final ClearWishlistUseCase clearWishlistUseCase;
  
  late StreamSubscription _eventSubscription;

  WishlistBloc({
    required this.getWishlistUseCase,
    required this.toggleWishlistUseCase,
    required this.clearWishlistUseCase,
  }) : super(WishlistInitial()) {
    on<GetWishlistEvent>(_onGetWishlist);
    on<ToggleWishlistEvent>(_onToggleWishlist);
    on<ClearWishlistEvent>(_onClearWishlist);
    
    // الاستماع لأحداث التنظيف
    _eventSubscription = EventBus.events.listen((event) {
      if (event is ClearWishlistEvent || event is AppLogoutEvent) {
        add(ClearWishlistEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _eventSubscription.cancel();
    return super.close();
  }

  Future<void> _onGetWishlist(
    GetWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading());

    final result = await getWishlistUseCase(NoParams());

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحميل المفضلة';
        if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(WishlistError(message));
      },
      (wishlist) => emit(WishlistLoaded(wishlist)),
    );
  }

  Future<void> _onToggleWishlist(
    ToggleWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    final result = await toggleWishlistUseCase(
      ToggleWishlistParams(productId: event.productId),
    );

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحديث المفضلة';
        if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(WishlistError(message));
      },
      (result) {
        final isAdded = result['added'] == true;
        emit(WishlistItemToggled(
          productId: event.productId,
          isAdded: isAdded,
        ));
        
        // Refresh wishlist after toggle
        add(GetWishlistEvent());
      },
    );
  }

  Future<void> _onClearWishlist(
    ClearWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    final result = await clearWishlistUseCase(NoParams());

    result.fold(
      (failure) {
        String message = 'حدث خطأ أثناء مسح المفضلة';
        if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        }
        emit(WishlistError(message));
      },
      (_) => emit(WishlistCleared()),
    );
  }
}