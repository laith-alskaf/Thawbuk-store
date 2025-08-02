import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/wishlist/get_wishlist_usecase.dart';
import '../../../domain/usecases/wishlist/toggle_wishlist_usecase.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final GetWishlistUseCase getWishlistUseCase;
  final ToggleWishlistUseCase toggleWishlistUseCase;

  WishlistBloc({
    required this.getWishlistUseCase,
    required this.toggleWishlistUseCase,
  }) : super(WishlistInitial()) {
    on<GetWishlist>(_onGetWishlist);
    on<ToggleWishlistItem>(_onToggleWishlist);
  }

  Future<void> _onGetWishlist(
    GetWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading());
    final failureOrWishlist = await getWishlistUseCase(NoParams());
    failureOrWishlist.fold(
      (failure) => emit(WishlistError(failure.message)),
      (wishlist) => emit(WishlistLoaded(wishlist)),
    );
  }

  Future<void> _onToggleWishlist(
    ToggleWishlistItem event,
    Emitter<WishlistState> emit,
  ) async {
    // We don't show a loading indicator for toggle, to make the UI feel faster.
    // The UI will update optimistically or show an error.
    final failureOrWishlist = await toggleWishlistUseCase(
      ToggleWishlistParams(productId: event.productId),
    );

    failureOrWishlist.fold(
      (failure) => emit(WishlistError(failure.message)),
      (wishlist) => emit(WishlistLoaded(wishlist)),
    );
  }
}
