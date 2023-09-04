import 'package:audio_restart/feature_audio/app_audio_cache.dart';
import 'package:audio_restart/feature_audio/app_audio_handler.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await sl.reset();
  try {
    sl.registerSingleton(AppAudioCache());
    if (!sl.isRegistered<AppAudioHandler>()) {
      try {
        sl.registerSingleton<AppAudioHandler>(
          await initAudioService(audioCache: sl()),
        );
      } catch (e) {
        print(e);
      }
    }
  } catch (e) {
    print(e);
  }
  await sl.allReady();
}
