import '../../core/errors/exceptions.dart';
import '../../core/network/http_client.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> getCategoryById(String id);
  Future<CategoryModel> createCategory(Map<String, dynamic> categoryData);
  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> categoryData);
  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final HttpClient httpClient;

  CategoryRemoteDataSourceImpl(this.httpClient);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await httpClient.get('/category');
      
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is List) {
        return response
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      throw ServerException('Invalid response format for categories');
    } catch (e) {
      throw ServerException('Failed to get categories: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final response = await httpClient.get('/category/$id');
      
      if (response['data'] != null) {
        return CategoryModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return CategoryModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to get category: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await httpClient.post('/user/category', body: categoryData);
      
      if (response['data'] != null) {
        return CategoryModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return CategoryModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to create category: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> categoryData) async {
    try {
      final response = await httpClient.put('/user/category/$id', body: categoryData);
      
      if (response['data'] != null) {
        return CategoryModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return CategoryModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to update category: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await httpClient.delete('/user/category/$id');
    } catch (e) {
      throw ServerException('Failed to delete category: ${e.toString()}');
    }
  }
}