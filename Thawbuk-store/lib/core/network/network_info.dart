abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // في التطبيق الحقيقي يمكن استخدام connectivity_plus package
    // لكن للتبسيط سنعتبر أن الاتصال متاح دائماً
    return true;
  }
}