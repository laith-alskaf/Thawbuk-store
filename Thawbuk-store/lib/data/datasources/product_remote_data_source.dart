import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<ProductModel>> getProductsByCategory(String category);
  Future<ProductModel> createProduct(Map<String, dynamic> productData);
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> productData);
  Future<void> deleteProduct(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await apiClient.getProducts();
      return response;
    } catch (e) {
      throw ServerException('Failed to get products: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await apiClient.getProductById(id);
      return response;
    } catch (e) {
      throw ServerException('Failed to get product: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await apiClient.searchProducts(query);
      return response;
    } catch (e) {
      throw ServerException('Failed to search products: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final response = await apiClient.getProductsByCategory(category);
      return response;
    } catch (e) {
      throw ServerException('Failed to get products by category: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await apiClient.createProduct(productData);
      return response;
    } catch (e) {
      throw ServerException('Failed to create product: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> productData) async {
    try {
      final response = await apiClient.updateProduct(id, productData);
      return response;
    } catch (e) {
      throw ServerException('Failed to update product: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await apiClient.deleteProduct(id);
    } catch (e) {
      throw ServerException('Failed to delete product: ${e.toString()}');
    }
  }
}