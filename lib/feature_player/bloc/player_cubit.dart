import 'package:audio_restart/feature_audio/app_audio_handler.dart';
import 'package:audio_restart/feature_player/bloc/player_state.dart';
import 'package:audio_restart/feature_player/model/song.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:async';

import 'package:audio_service/audio_service.dart';

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit({required AppAudioHandler audioHandler})
      : super(const PlayerState()) {
    _audioHandler = audioHandler;
    _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);

    _listenToPlaybackState();
  }

  late final AppAudioHandler _audioHandler;

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;

      final stopState = state.copyWith(isPlaying: false);

      final newState = switch (playbackState.processingState) {
        AudioProcessingState.completed => stopState,
        AudioProcessingState.idle => state,
        AudioProcessingState.loading => state,
        AudioProcessingState.buffering => state,
        AudioProcessingState.ready => state.copyWith(
            isPlaying: isPlaying,
            currentIndex: playbackState.queueIndex,
          ),
        AudioProcessingState.error => stopState,
      };

      if (newState != state) emit(newState);
    });
  }

  void onPlayerButtonTap(List<Song> songs) {
    if (!state.isOff) {
      state.isPlaying ? pause() : _play();
    } else {
      _startPlay(songs);
    }
  }

  Future<void> _startPlay(List<Song> songs) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final mediaItems = songs.map(
      (song) {
        final stream = song.audioTrack;
        return MediaItem(
          id: stream ?? '',
          title: song.title,
          displayTitle: song.title,
          displaySubtitle: song.author,
          extras: {'url': stream},
        );
      },
    ).toList(growable: true);

    unawaited(_audioHandler.loadEmptyPlaylist());
    await _audioHandler.addQueueItems(mediaItems);

    unawaited(_audioHandler.play());

    emit(state.copyWith(isOff: false, isPlaying: true));
  }

  void _play() {
    _audioHandler.play();
    emit(state.copyWith(isPlaying: true));
  }

  Future<void> pause() async {
    unawaited(_audioHandler.pause());
    emit(state.copyWith(isPlaying: false));
  }

  void stop() {
    _audioHandler.stop();
    emit(
      state.copyWith(
        isPlaying: false,
        isOff: true,
      ),
    );
  }

  void onPrevious() {
    _audioHandler.skipToPrevious();
  }

  void onNext() {
    _audioHandler.skipToNext();
  }

  void playSong(int index) {
    _audioHandler.skipToQueueItem(index);
    _play();
  }

  Future<void> clearCache() async => _audioHandler.clearAllCache();
}
