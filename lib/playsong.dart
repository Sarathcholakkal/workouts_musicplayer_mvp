import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
// ! (Red)**Use for warnings or important notes.
// *(Green)** Use for highlighting information.
// ? (Purple)** Use for questions or clarifications.
//(Grey)** Normal comments without specific styling.

class PlaySong extends StatefulWidget {
  final List<SongModel> songs;
  final int index;

  PlaySong({super.key, required this.songs, required this.index});
  @override
  State<PlaySong> createState() => _HomeState();
}

class _HomeState extends State<PlaySong> {
  final player = AudioPlayer();

  //==================

  //=================
  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  //======================
  void hadlePlayPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }
  //=============

  void handleSeek(double value) {
    player.seek(Duration(seconds: value.toInt()));
  }

  //====================

  //=============================
  Future<void> _playSongs(List<SongModel> songs) async {
    try {
      // Create a list of AudioSource from the songs list
      final playlist = ConcatenatingAudioSource(
        children: songs.map((song) {
          return AudioSource.uri(
            Uri.parse(song.uri!),
          );
        }).toList(),
      );

      // Set the audio source to the playlist
      await player.setAudioSource(playlist, initialIndex: widget.index);

      // Start playing
      player.play();
    } catch (e) {
      print("Error playing songs: $e");
    }
  }

  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> duration = ValueNotifier(Duration.zero);
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);

  @override
  void initState() {
    _playSongs(widget.songs);
    player.positionStream.listen((p) {
      position.value = p;
    });

    player.durationStream.listen((d) {
      duration.value = d!;
    });

    player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        position.value = Duration.zero;
        player.pause();
        player.seek(position.value);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder<Duration>(
              valueListenable: position,
              builder: (context, value, child) {
                return Text(formatDuration(value));
              },
            ),
            ValueListenableBuilder<Duration>(
              valueListenable: duration,
              builder: (context, totalDuration, child) {
                return ValueListenableBuilder<Duration>(
                  valueListenable: position,
                  builder: (context, currentPosition, child) {
                    return Slider(
                      min: 0.0,
                      max: totalDuration.inSeconds.toDouble(),
                      value: currentPosition.inSeconds
                          .clamp(0, totalDuration.inSeconds)
                          .toDouble(),
                      onChanged: handleSeek,
                    );
                  },
                );
              },
            ),
            ValueListenableBuilder<Duration>(
              valueListenable: duration,
              builder: (context, value, child) {
                return Text(formatDuration(value));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: () {
                      player.seekToPrevious();
                    },
                    icon: const Icon(Icons.skip_previous)),
                ValueListenableBuilder<bool>(
                  valueListenable: isPlaying,
                  builder: (context, playing, child) {
                    return IconButton(
                      onPressed: hadlePlayPause,
                      icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                    );
                  },
                ),
                IconButton(
                    onPressed: () {
                      player.seekToNext();
                    },
                    icon: const Icon(Icons.skip_next)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
