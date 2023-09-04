import 'package:audio_restart/app/audio_app.dart';
import 'package:audio_restart/widget/restart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audio_restart/injection_container.dart' as di;

Future<void> runAudioApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _initServices();

  runApp(
    const RestartWidget(
      onRestart: _initServices,
      child: AudioApp(),
    ),
  );
}

Future<void> _initServices() async {
  print('RestartWidget _initServices()');
  await di.init();
}
