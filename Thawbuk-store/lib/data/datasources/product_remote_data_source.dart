import '../../core/errors/exceptions.dart';
import '../../core/network/http_client.dart';
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
  final HttpClient httpClient;

  ProductRemoteDataSourceImpl(this.httpClient);

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await httpClient.get('/product');
      
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is List) {
        return response
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      throw ServerException('Invalid response format for products');
    } catch (e) {
      throw ServerException('Failed to get products: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await httpClient.get('/product/$id');
      
      if (response['data'] != null) {
        return ProductModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return ProductModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to get product: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await httpClient.get('/product/search?q=$query');
      
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is List) {
        return response
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      throw ServerException('Invalid response format for search');
    } catch (e) {
      throw ServerException('Failed to search products: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final response = await httpClient.get('/product/byCategory?category=$category');
      
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is List) {
        return response
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      throw ServerException('Invalid response format for category products');
    } catch (e) {
      throw ServerException('Failed to get products by category: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await httpClient.post('/user/product', body: productData);
      
      if (response['data'] != null) {
        return ProductModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return ProductModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to create product: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> productData) async {
    try {
      final response = await httpClient.put('/user/product/$id', body: productData);
      
      if (response['data'] != null) {
        return ProductModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return ProductModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to update product: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await httpClient.delete('/user/product/$id');
    } catch (e) {
      throw ServerException('Failed to delete product: ${e.toString()}');
    }
  }
}