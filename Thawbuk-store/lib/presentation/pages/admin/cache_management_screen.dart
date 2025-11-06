import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer';

import '../../../core/cache/smart_cache_manager.dart';
import '../../../core/cache/cache_initialization_service.dart';
import '../../../core/cache/role_based_cache_strategy.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../domain/entities/user_entity.dart';
import '../../widgets/loading_indicator.dart';

/// شاشة إدارة التخزين المؤقت (للمطورين والإدارة)
class CacheManagementScreen extends StatefulWidget {
  const CacheManagementScreen({super.key});

  @override
  State<CacheManagementScreen> createState() => _CacheManagementScreenState();
}

class _CacheManagementScreenState extends State<CacheManagementScreen>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  Map<String, dynamic>? _cacheStats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCacheStatistics();
  }

  Future<void> _loadCacheStatistics() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final smartCacheManager = getIt<SmartCacheManager>();
      final stats = await smartCacheManager.getCacheStatistics();
      
      final appInitService = getIt<CacheInitializationService>();
      final systemStats = await appInitService.getSystemStatistics();

      setState(() {
        _cacheStats = {
          'cache': stats,
          'system': systemStats,
          'timestamp': DateTime.now(),
        };
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل إحصائيات التخزين المؤقت: $e';
        _isLoading = false;
      });
      log('❌ Error loading cache statistics: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('غير متاح')),
        body: const Center(
          child: Text('هذه الشاشة متاحة فقط في وضع التطوير'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التخزين المؤقت'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCacheStatistics,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('مسح جميع البيانات'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'reset_system',
                child: ListTile(
                  leading: Icon(Icons.restart_alt),
                  title: Text('إعادة تعيين النظام'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'debug_info',
                child: ListTile(
                  leading: Icon(Icons.bug_report),
                  title: Text('معلومات التشخيص'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'نظرة عامة', icon: Icon(Icons.dashboard)),
            Tab(text: 'الإحصائيات', icon: Icon(Icons.analytics)),
            Tab(text: 'الاستراتيجيات', icon: Icon(Icons.settings)),
            Tab(text: 'الأدوات', icon: Icon(Icons.build)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildStatisticsTab(),
                    _buildStrategiesTab(),
                    _buildToolsTab(),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCacheStatistics,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final cacheStats = _cacheStats?['cache'] as Map<String, dynamic>?;
    final systemStats = _cacheStats?['system'] as Map<String, dynamic>?;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          'حالة النظام',
          [
            _buildInfoRow('مهيأ', systemStats?['isInitialized']?.toString() ?? 'غير معروف'),
            _buildInfoRow('المستخدم الحالي', cacheStats?['userId'] ?? 'غير محدد'),
            _buildInfoRow('الدور', cacheStats?['role'] ?? 'غير محدد'),
            _buildInfoRow('متصل بالإنترنت', cacheStats?['isOnline']?.toString() ?? 'غير معروف'),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildInfoCard(
          'أنواع البيانات المسموحة',
          (cacheStats?['allowedDataTypes'] as List<dynamic>?)
              ?.map((type) => _buildChip(type.toString()))
              .toList() ?? [const Text('لا توجد بيانات')],
        ),
        
        const SizedBox(height: 16),
        
        _buildInfoCard(
          'معلومات التخزين المؤقت',
          [
            _buildInfoRow('وقت آخر تحديث', _formatTimestamp(_cacheStats?['timestamp'])),
            _buildInfoRow('إصدار التطبيق', systemStats?['version'] ?? 'غير محدد'),
            _buildInfoRow('نشاط نظام التخزين', systemStats?['cacheSystemActive']?.toString() ?? 'غير معروف'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard('المنتجات', Icons.inventory, Colors.blue),
        _buildStatCard('الفئات', Icons.category, Colors.green),
        _buildStatCard('السلة', Icons.shopping_cart, Colors.orange),
        _buildStatCard('المفضلة', Icons.favorite, Colors.red),
        _buildStatCard('الطلبات', Icons.receipt, Colors.purple),
        _buildStatCard('المستخدمين', Icons.people, Colors.teal),
      ],
    );
  }

  Widget _buildStrategiesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStrategyCard('العملاء', UserRole.customer),
        _buildStrategyCard('الإدارة', UserRole.admin),
        _buildStrategyCard('المدير العام', UserRole.superAdmin),
        _buildStrategyCard('الزوار', null),
      ],
    );
  }

  Widget _buildToolsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildToolCard(
          'مسح البيانات المنتهية الصلاحية',
          'حذف البيانات القديمة لتوفير مساحة',
          Icons.delete_sweep,
          () => _cleanExpiredData(),
        ),
        
        _buildToolCard(
          'تحسين التخزين المؤقت',
          'إعادة تنظيم وضغط البيانات المخزنة',
          Icons.tune,
          () => _optimizeCache(),
        ),
        
        _buildToolCard(
          'تصدير إحصائيات',
          'حفظ تقرير مفصل عن حالة التخزين المؤقت',
          Icons.file_download,
          () => _exportStatistics(),
        ),
        
        _buildToolCard(
          'اختبار الشبكة',
          'فحص اتصال الشبكة وسرعة الاستجابة',
          Icons.network_check,
          () => _testNetwork(),
        ),
        
        _buildToolCard(
          'محاكاة وضع عدم الاتصال',
          'اختبار وظائف التطبيق بدون إنترنت',
          Icons.wifi_off,
          () => _simulateOfflineMode(),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  Widget _buildStatCard(String title, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: const Text('قريباً - إحصائيات مفصلة'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO: عرض إحصائيات مفصلة
        },
      ),
    );
  }

  Widget _buildStrategyCard(String title, UserRole? role) {
    final strategies = RoleBasedCacheStrategy.getAllStrategiesForRole(role);
    final cacheLimit = RoleBasedCacheStrategy.getCacheLimitForRole(role);
    
    return Card(
      child: ExpansionTile(
        title: Text(title),
        subtitle: Text('${strategies.length} استراتيجية'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حدود التخزين:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _buildInfoRow('أقصى عدد عناصر', '${cacheLimit.maxItems}'),
                _buildInfoRow('أقصى حجم', '${cacheLimit.maxSizeInMB} MB'),
                _buildInfoRow('أقصى عمر', '${cacheLimit.maxAgeInDays} يوم'),
                
                const SizedBox(height: 16),
                
                Text(
                  'الاستراتيجيات:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...strategies.entries.map((entry) => 
                  _buildInfoRow(entry.key, entry.value.policy.toString().split('.').last)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.play_arrow),
        onTap: onTap,
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'غير محدد';
    if (timestamp is DateTime) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_all':
        _showClearAllDialog();
        break;
      case 'reset_system':
        _showResetSystemDialog();
        break;
      case 'debug_info':
        _showDebugInfo();
        break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح جميع البيانات'),
        content: const Text('هذا سيحذف جميع البيانات المخزنة محلياً. هل أنت متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllCache();
            },
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _showResetSystemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين النظام'),
        content: const Text('هذا سيعيد تشغيل نظام التخزين المؤقت بالكامل. المتابعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetSystem();
            },
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }

  void _showDebugInfo() {
    final appInitService = getIt<CacheInitializationService>();
    appInitService.debugPrintCacheInfo();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم طباعة معلومات التشخيص في وحدة التحكم')),
    );
  }

  Future<void> _clearAllCache() async {
    try {
      final smartCacheManager = getIt<SmartCacheManager>();
      await smartCacheManager.clearAllCache();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم مسح جميع البيانات بنجاح')),
      );
      
      await _loadCacheStatistics();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في مسح البيانات: $e')),
      );
    }
  }

  Future<void> _resetSystem() async {
    try {
      final appInitService = getIt<CacheInitializationService>();
      await appInitService.resetSystem();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إعادة تعيين النظام بنجاح')),
      );
      
      await _loadCacheStatistics();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في إعادة تعيين النظام: $e')),
      );
    }
  }

  Future<void> _cleanExpiredData() async {
    // TODO: تنفيذ تنظيف البيانات المنتهية الصلاحية
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قريباً - تنظيف البيانات المنتهية الصلاحية')),
    );
  }

  Future<void> _optimizeCache() async {
    // TODO: تنفيذ تحسين التخزين المؤقت
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قريباً - تحسين التخزين المؤقت')),
    );
  }

  Future<void> _exportStatistics() async {
    // TODO: تنفيذ تصدير الإحصائيات
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قريباً - تصدير الإحصائيات')),
    );
  }

  Future<void> _testNetwork() async {
    // TODO: تنفيذ اختبار الشبكة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قريباً - اختبار الشبكة')),
    );
  }

  Future<void> _simulateOfflineMode() async {
    // TODO: تنفيذ محاكاة وضع عدم الاتصال
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قريباً - محاكاة وضع عدم الاتصال')),
    );
  }
}