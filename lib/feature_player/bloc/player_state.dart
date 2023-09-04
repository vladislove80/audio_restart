import 'package:equatable/equatable.dart';

class PlayerState extends Equatable {
  const PlayerState({
    this.isPlaying = false,
    this.isOff = true,
    this.currentIndex = 0,
  });

  final bool isOff;
  final bool isPlaying;
  final int currentIndex;

  @override
  List<Object?> get props => [isPlaying, isOff, currentIndex];

  PlayerState copyWith({
    bool? isPlaying,
    bool? isOff,
    int? currentIndex,
  }) =>
      PlayerState(
        isPlaying: isPlaying ?? this.isPlaying,
        isOff: isOff ?? this.isOff,
        currentIndex: currentIndex ?? this.currentIndex,
      );
}
