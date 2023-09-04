import 'dart:async';

import 'package:audio_restart/feature_player/player_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  static const routeName = '/splashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minDuration = Duration(seconds: 1);
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dismissTimer = Timer(
        _minDuration,
        () {
          Navigator.of(context).pushReplacementNamed(
            PlayerScreen.routeName,
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Colors.white54,
        body: Center(
          child: Text(
            'Splash Screen',
            style: TextStyle(color: Colors.deepPurple, fontSize: 42),
          ),
        ),
      );

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }
}
