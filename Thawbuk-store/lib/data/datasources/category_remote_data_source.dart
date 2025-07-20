import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> getCategoryById(String id);
  Future<CategoryModel> createCategory(Map<String, dynamic> categoryData);
  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> categoryData);
  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient apiClient;

  CategoryRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiClient.getCategories();
      return response;
    } catch (e) {
      throw ServerException('Failed to get categories: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final response = await apiClient.getCategoryById(id);
      return response;
    } catch (e) {
      throw ServerException('Failed to get category: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await apiClient.createCategory(categoryData);
      return response;
    } catch (e) {
      throw ServerException('Failed to create category: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> categoryData) async {
    try {
      final response = await apiClient.updateCategory(id, categoryData);
      return response;
    } catch (e) {
      throw ServerException('Failed to update category: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await apiClient.deleteCategory(id);
    } catch (e) {
      throw ServerException('Failed to delete category: ${e.toString()}');
    }
  }
}