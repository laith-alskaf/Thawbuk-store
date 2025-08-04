import '../../core/errors/exceptions.dart';
import '../../core/network/http_client.dart';
import '../../domain/usecases/product/get_filtered_products_usecase.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getFilteredProducts(
      GetFilteredProductsParams params);
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<ProductModel>> getProductsByCategory(String category);
  Future<ProductModel> createProduct(Map<String, dynamic> productData);
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> productData);
  Future<void> deleteProduct(String id);
  Future<List<ProductModel>> getMyProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final HttpClient httpClient;

  ProductRemoteDataSourceImpl(this.httpClient);

  @override
  Future<List<ProductModel>> getFilteredProducts(
      GetFilteredProductsParams params) async {
               
    try {
      final queryParameters = <String, dynamic>{
        'category': params.category,
        'searchQuery': params.searchQuery,
        'sizes': params.sizes?.join(','),
        'colors': params.colors?.join(','),
        'minPrice': params.minPrice?.toString(),
        'maxPrice': params.maxPrice?.toString(),
        'sortBy': params.sortBy,
      };

      queryParameters.removeWhere((key, value) => value == null || value.isEmpty);
      print('getFilteredProducts queryParameters: $queryParameters');

      final response =
          await httpClient.get('/product/filter', queryParameters: queryParameters);
      print('getFilteredProducts response: $response');
      
      if (response['body'] != null && response['body']['data'] is List) {
        final products = (response['body']['data'] as List)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
        print('Found ${products.length} filtered products');
        return products;
      }

      throw ServerException('Invalid response format for filtered products');
    } catch (e) {
      print('Error in getFilteredProducts: ${e.toString()}');
      throw ServerException(
          'Failed to get filtered products: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await httpClient.get('/v2/product');
       print(response);
      if (response['body']['data']['products'] is List) {
        return (response['body']['data']['products'] as List)
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
      final response = await httpClient.get('/v2/product/$id');
    
      print(response);
      
      if (response['body']['data'] != null) {
        final jsonData = response['body']['data'] as Map<String, dynamic>;
      
        try {
          final product = ProductModel.fromJson(jsonData);
  
          return product;
        } catch (e) {
     
          throw ServerException('Failed to parse product: ${e.toString()}');
        }
      }
      
      throw ServerException('Invalid response format for product');
    } catch (e) {
      throw ServerException('Failed to get product: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await httpClient.get('/v2/product/search',queryParameters: {
        'title':Uri.encodeComponent(query)
      });
               print(response);
      if (response['body']['data']['products'] is List) {
        return (response['body']['data']['products'] as List)
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
      // Use filter endpoint with category parameter since byCategory endpoint is not working
      final response = await httpClient.get('/v2/product/filter', queryParameters: {'category': category});
      print('getProductsByCategory (using filter) response: $response');
      
      if (response['body'] != null && response['body']['data'] is List) {
        final allProducts = (response['body']['data'] as List);
        // Filter products by category on client side as backup
        final categoryProducts = allProducts.where((product) => 
          product['categoryId'] == category
        ).toList();
        
        final products = categoryProducts
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
        print('Found ${products.length} products for category: $category');
        return products;
      }
      
      throw ServerException('Invalid response format for category products');
    } catch (e) {
      print('Error in getProductsByCategory: ${e.toString()}');
      throw ServerException('Failed to get products by category: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await httpClient.post('/v2/user/product', body: productData);
      
      if (response['body']['data'] != null) {
        return ProductModel.fromJson(response['body']['data'] as Map<String, dynamic>);
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
      final response = await httpClient.put('/v2/user/product/$id', body: productData);
      
      if (response['body']['data'] != null) {
        return ProductModel.fromJson(response['body']['data'] as Map<String, dynamic>);
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
      await httpClient.deleteVoid('/v2/user/product/$id');
    } catch (e) {
      throw ServerException('Failed to delete product: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> getMyProducts() async {
    try {
      final response = await httpClient.get('/v2/user/product');
      if (response['body']['data']['products'] is List) {
        return (response['body']['data']['products'] as List)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Invalid response format for my products');
    } catch (e) {
      throw ServerException('Failed to get my products: ${e.toString()}');
    }
  }
}
