import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/usecases/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import 'category_event.dart';
import 'category_state.dart';

@injectable
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase _getCategoriesUseCase;

  CategoryBloc(this._getCategoriesUseCase) : super(CategoryInitial()) {
    on<GetCategoriesEvent>(_onGetCategories);
  }

  Future<void> _onGetCategories(
    GetCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    final failureOrCategories = await _getCategoriesUseCase(NoParams());
    failureOrCategories.fold(
      (failure) {
        String message = 'حدث خطأ أثناء تحميل الفئات';
        if (failure is NetworkFailure) {
          message = 'تحقق من اتصال الإنترنت';
        } else if (failure is ServerFailure) {
          message = 'خطأ في الخادم، يرجى المحاولة لاحقاً';
        }
        emit(CategoryError(message));
      },
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }
}
