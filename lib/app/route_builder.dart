import 'package:audio_restart/app/audio_app.dart';
import 'package:audio_restart/feature_player/player_screen.dart';
import 'package:audio_restart/feature_splash/splash_screen.dart';
import 'package:flutter/material.dart';

class RouteBuilder {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AudioApp.routeName:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
          settings: settings,
        );
      case PlayerScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const PlayerScreen(),
          fullscreenDialog: true,
        );
      default:
        return null;
    }
  }
}
