import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppAudioCache extends CacheManager with ImageCacheManager {
  AppAudioCache() : super(Config(key));
  static const key = 'custom_cache';

  Future<void> clearCache() async {
    await emptyCache();
  }

  Future<void> disposeCache() async {
    await dispose();
  }
}
