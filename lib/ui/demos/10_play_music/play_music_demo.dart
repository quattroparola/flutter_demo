import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayMusicDemo extends StatefulWidget {
  const PlayMusicDemo({super.key});

  @override
  State<PlayMusicDemo> createState() => _PlayMusicDemoState();
}

class _PlayMusicDemoState extends State<PlayMusicDemo> {
  final _player = AudioPlayer();
  final _tracks = const [
    _Track(
      title: 'Ambient Synthwave',
      artist: 'Local Asset',
      assetPath: 'assets/audio/ambient_synthwave.mp3',
    ),
    _Track(
      title: 'Aristocratic BM-Winterlight',
      artist: 'Local Asset',
      assetPath: 'assets/audio/aristocratic_bm_winterlight.mp3',
    ),
  ];

  int _currentIndex = 0;
  bool _isLoadingTrack = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _loadTrack(0, autoplay: false);
  }

  Future<void> _loadTrack(int index, {required bool autoplay}) async {
    setState(() {
      _isLoadingTrack = true;
      _errorText = null;
      _currentIndex = index;
    });

    try {
      await _player.setAsset(_tracks[index].assetPath);

      if (autoplay) {
        await _player.play();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorText = 'Failed to load audio: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTrack = false;
        });
      }
    }
  }

  Future<void> _selectTrack(int index) async {
    final shouldAutoplay = _player.playing;
    await _loadTrack(index, autoplay: shouldAutoplay);
  }

  Future<void> _playPrevious() async {
    if (_tracks.isEmpty) {
      return;
    }

    final previousIndex = (_currentIndex - 1 + _tracks.length) % _tracks.length;
    await _loadTrack(previousIndex, autoplay: true);
  }

  Future<void> _playNext() async {
    if (_tracks.isEmpty) {
      return;
    }

    final nextIndex = (_currentIndex + 1) % _tracks.length;
    await _loadTrack(nextIndex, autoplay: true);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = _tracks[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Play Music')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.album_rounded,
                      size: 96,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentTrack.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentTrack.artist,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    _ProgressSection(player: _player),
                    if (_errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 12),
                    StreamBuilder<PlayerState>(
                      stream: _player.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final isPlaying = playerState?.playing ?? false;
                        final isCompleted =
                            playerState?.processingState ==
                            ProcessingState.completed;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _isLoadingTrack ? null : _playPrevious,
                              icon: const Icon(Icons.skip_previous_rounded),
                              iconSize: 36,
                            ),
                            IconButton.filled(
                              onPressed: _isLoadingTrack
                                  ? null
                                  : () async {
                                      if (isCompleted) {
                                        await _player.seek(Duration.zero);
                                        await _player.play();
                                      } else if (isPlaying) {
                                        await _player.pause();
                                      } else {
                                        await _player.play();
                                      }
                                    },
                              icon: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              iconSize: 36,
                            ),
                            IconButton(
                              onPressed: _isLoadingTrack ? null : _playNext,
                              icon: const Icon(Icons.skip_next_rounded),
                              iconSize: 36,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Playlist',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _tracks.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final track = _tracks[index];
                  final isSelected = index == _currentIndex;

                  return ListTile(
                    selected: isSelected,
                    leading: Icon(
                      isSelected ? Icons.graphic_eq : Icons.music_note,
                    ),
                    title: Text(track.title),
                    subtitle: Text(track.artist),
                    trailing: Text('${index + 1}'),
                    onTap: () => _selectTrack(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.player});

  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: player.durationStream,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final cappedPosition = position > duration ? duration : position;
            final maxSeconds = duration.inMilliseconds > 0
                ? duration.inMilliseconds / 1000
                : 1.0;
            final currentSeconds = cappedPosition.inMilliseconds > 0
                ? cappedPosition.inMilliseconds / 1000
                : 0.0;

            return Column(
              children: [
                Slider(
                  value: currentSeconds.clamp(0.0, maxSeconds),
                  max: maxSeconds,
                  onChanged: duration == Duration.zero
                      ? null
                      : (value) async {
                          await player.seek(
                            Duration(milliseconds: (value * 1000).round()),
                          );
                        },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(cappedPosition)),
                    Text(_formatDuration(duration)),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }
}

class _Track {
  const _Track({
    required this.title,
    required this.artist,
    required this.assetPath,
  });

  final String title;
  final String artist;
  final String assetPath;
}
