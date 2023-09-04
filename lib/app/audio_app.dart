import 'package:audio_restart/app/route_builder.dart';
import 'package:audio_restart/feature_audio/app_audio_handler.dart';
import 'package:audio_restart/feature_player/bloc/player_cubit.dart';
import 'package:audio_restart/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AudioApp extends StatefulWidget {
  const AudioApp({
    super.key,
  });

  static const routeName = '/';

  @override
  State<AudioApp> createState() => _AudioAppState();
}

class _AudioAppState extends State<AudioApp> {
  late final RouteBuilder _routeBuilder;

  @override
  void initState() {
    super.initState();
    _routeBuilder = RouteBuilder();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<PlayerCubit>(
        create: (context) => PlayerCubit(audioHandler: sl<AppAudioHandler>()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateRoute: _routeBuilder.onGenerateRoute,
        ),
      );
}
