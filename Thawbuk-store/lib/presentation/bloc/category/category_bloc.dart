import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/usecases/usecase.dart';
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
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }
}
