import 'package:flutter/material.dart';
import '../../../core/network/network_info.dart';
import '../../../core/di/dependency_injection.dart';
import 'network_error_widget.dart';

class NetworkAwareWidget extends StatefulWidget {
  final Widget child;
  final Widget? offlineWidget;
  final bool showOfflineMessage;

  const NetworkAwareWidget({
    Key? key,
    required this.child,
    this.offlineWidget,
    this.showOfflineMessage = true,
  }) : super(key: key);

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  final NetworkInfo _networkInfo = getIt<NetworkInfo>();
  bool _isConnected = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_isConnected && widget.showOfflineMessage) {
      return widget.offlineWidget ??
          NetworkErrorWidget(
            message: 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى',
            onRetry: _checkConnection,
          );
    }

    return widget.child;
  }
}

class NetworkAwareBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isConnected) builder;

  const NetworkAwareBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: getIt<NetworkInfo>().isConnected,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final isConnected = snapshot.data ?? false;
        return builder(context, isConnected);
      },
    );
  }
}