import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  GoRouter? _router;

  void initialize(GoRouter router) {
    _router = router;
    _initDeepLinks();
  }

  void _initDeepLinks() {
    // Handle app launch from deep link
    _handleInitialLink();
    
    // Handle deep links when app is already running
    _handleIncomingLinks();
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialAppLink();
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get initial link: $e');
      }
    }
  }

  void _handleIncomingLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        if (kDebugMode) {
          print('Deep link error: $err');
        }
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    if (kDebugMode) {
      print('Received deep link: $uri');
    }

    try {
      // Handle different deep link schemes
      if (uri.scheme == 'thawbukstore') {
        _handleCustomSchemeLink(uri);
      } else if (uri.scheme == 'https' && uri.host == 'thawbuk-store.vercel.app') {
        _handleHttpsLink(uri);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling deep link: $e');
      }
    }
  }

  void _handleCustomSchemeLink(Uri uri) {
    switch (uri.host) {
      case 'login':
        _router?.go('/login');
        break;
      case 'verify':
        final token = uri.queryParameters['token'];
        final email = uri.queryParameters['email'];
        if (token != null && email != null) {
          _router?.go('/verify-email?token=$token&email=${Uri.encodeComponent(email)}');
        } else {
          _router?.go('/verify-email');
        }
        break;
      case 'home':
        _router?.go('/');
        break;
      case 'product':
        final productId = uri.queryParameters['id'];
        if (productId != null) {
          _router?.go('/product/$productId');
        }
        break;
      default:
        _router?.go('/');
        break;
    }
  }

  void _handleHttpsLink(Uri uri) {
    if (uri.path.startsWith('/api/auth/verify')) {
      final token = uri.queryParameters['token'];
      final email = uri.queryParameters['email'];
      
      if (token != null && email != null) {
        // Navigate to verification page with auto-verification
        _router?.go('/verify-email?token=$token&email=${Uri.encodeComponent(email)}&auto=true');
      } else {
        _router?.go('/verify-email');
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  // Helper methods for generating deep links
  static String generateVerificationLink(String token, String email) {
    return 'thawbukstore://verify?token=$token&email=${Uri.encodeComponent(email)}';
  }

  static String generateLoginLink() {
    return 'thawbukstore://login';
  }

  static String generateProductLink(String productId) {
    return 'thawbukstore://product?id=$productId';
  }
}