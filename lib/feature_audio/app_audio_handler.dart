import 'dart:async';

import 'package:audio_restart/feature_audio/app_audio_cache.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

const _notificationChannelId = 'com.audio_restart.example';
const _notificationChannelName = 'Audio App ';

Future<AppAudioHandler> initAudioService({required AppAudioCache audioCache}) =>
//after restart
//flutter: 'package:audio_service/audio_service.dart': Failed assertion: line 993 pos 12: '_cacheManager == null': is not true.
    AudioService.init(
      builder: () => AppAudioHandler(audioCache),
      config: const AudioServiceConfig(
        androidNotificationChannelId: _notificationChannelId,
        androidNotificationChannelName: _notificationChannelName,
        androidNotificationClickStartsActivity: true,
        androidShowNotificationBadge: true,
        preloadArtwork: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
      cacheManager: audioCache,
    );

class AppAudioHandler extends BaseAudioHandler {
  AppAudioHandler(this._audioCache) {
    try {
      _player = AudioPlayer();
      _initAudioSession();
      _notifyAudioHandlerAboutPlaybackEvents();
      _listenForDurationChanges();
      _listenForCurrentSongIndexChanges();
      _listenForSequenceStateChanges();
    } catch (e) {
      print(e);
    }
  }

  late final AudioPlayer _player;
  late ConcatenatingAudioSource _playlist;
  final AppAudioCache _audioCache;

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    final audioSource = mediaItems
        .map(_createAudioSource)
        .whereType<LockCachingAudioSource>()
        .toList(growable: true);
    await _playlist.addAll(audioSource);
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final audioSource = _createAudioSource(mediaItem);
    if (audioSource == null) return;
    await _playlist.add(audioSource);
    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  LockCachingAudioSource? _createAudioSource(MediaItem mediaItem) {
    final extra = mediaItem.extras?['url'];
    final uri = extra != null && extra is String ? extra : null;
    return uri == null
        ? null
        : LockCachingAudioSource(
            Uri.parse(uri),
            tag: mediaItem,
          );
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    await _playlist.removeAt(index);
    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  @override
  Future<void> onNotificationDeleted() {
    print('onNotificationDeleted');

    return super.onNotificationDeleted();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  bool get hasNext => _player.hasNext;

  bool get hasPrevious => _player.hasPrevious;

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        await _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      await super.stop();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  Future<void> loadEmptyPlaylist() async {
    _playlist = ConcatenatingAudioSource(
      children: [],
      useLazyPreparation: false,
    );
    await _player.setAudioSource(_playlist);
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((playbackEvent) {
      final playing = _player.playing;
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.playPause,
            MediaAction.skipToNext,
            MediaAction.skipToPrevious,
          },
          androidCompactActionIndices: const [0, 1, 3],
          processingState: const {
                ProcessingState.idle: AudioProcessingState.idle,
                ProcessingState.loading: AudioProcessingState.loading,
                ProcessingState.buffering: AudioProcessingState.buffering,
                ProcessingState.ready: AudioProcessingState.ready,
                ProcessingState.completed: AudioProcessingState.completed,
              }[_player.processingState] ??
              AudioProcessingState.idle,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: playbackEvent.currentIndex,
        ),
      );
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      final index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty || index >= newQueue.length) return;
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty || index >= playlist.length) return;
      mediaItem.add(playlist[index]);
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence
          .map((source) {
            final tag = source.tag;
            return tag == null ? null : tag as MediaItem;
          })
          .whereType<MediaItem>()
          .toList(growable: false);
      queue.add(items);
    });
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            print('duck');
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            print('unknown');
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            print('duck');

            break;
          case AudioInterruptionType.pause:
            print('pause');

          case AudioInterruptionType.unknown:
            print('unknown');

            break;
        }
      }
    });
  }

  Future<void> clearAllCache() async {
    try {
      await _audioCache.clearCache();
      await _audioCache.disposeCache();
      print('Audio cache is clear');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
