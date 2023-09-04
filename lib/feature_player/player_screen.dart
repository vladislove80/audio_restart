import 'package:audio_restart/feature_player/bloc/player_cubit.dart';
import 'package:audio_restart/feature_player/bloc/player_state.dart';
import 'package:audio_restart/feature_player/model/stub.dart';
import 'package:audio_restart/widget/restart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({
    super.key,
  });

  static const routeName = '/playerScreen';

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Audio'),
        ),
        body: BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, playerState) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.skip_previous,
                          size: 36,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () {
                            BlocProvider.of<PlayerCubit>(context)
                                .onPlayerButtonTap(stubSongs);
                          },
                          child: Icon(
                            playerState.isPlaying
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.skip_next,
                          size: 36,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      BlocProvider.of<PlayerCubit>(context).clearCache();
                      RestartWidget.restartApp(context);
                    },
                    child: const Text('Restart App'),
                  )
                ],
              ),
            );
          },
        ),
      );
}
