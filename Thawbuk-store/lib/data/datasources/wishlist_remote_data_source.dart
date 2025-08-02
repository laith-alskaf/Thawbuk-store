import '../../core/errors/exceptions.dart';
import '../../core/network/http_client.dart';
import '../models/wishlist_model.dart';

abstract class WishlistRemoteDataSource {
  Future<WishlistModel> getWishlist();
  Future<WishlistModel> toggleWishlist(String productId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final HttpClient httpClient;

  WishlistRemoteDataSourceImpl(this.httpClient);

  @override
  Future<WishlistModel> getWishlist() async {
    try {
      final response = await httpClient.get('/user/wishlist');
      // The backend returns { "products": [...] }
      if (response['body'] != null && response['body']['products'] is List) {
        return WishlistModel.fromJson(response['body']);
      }
      // Handle cases where the wishlist is empty or not found
      if (response['body'] == null || response['body']['products'] == null) {
        return const WishlistModel(products: []);
      }
      throw ServerException('Invalid response format for wishlist');
    } catch (e) {
      throw ServerException('Failed to get wishlist: ${e.toString()}');
    }
  }

  @override
  Future<WishlistModel> toggleWishlist(String productId) async {
    try {
      // First, call the toggle endpoint. We don't need its response.
      await httpClient.post(
        '/user/wishlist/toggle',
        body: {'productId': productId},
      );
      // After a successful toggle, refetch the entire wishlist to get the updated state.
      return await getWishlist();
    } catch (e) {
      throw ServerException('Failed to toggle wishlist: ${e.toString()}');
    }
  }
}
