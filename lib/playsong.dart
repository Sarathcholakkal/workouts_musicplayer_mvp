import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaySong extends StatefulWidget {
  final List<SongModel> songs;
  final int index;

  PlaySong({super.key, required this.songs, required this.index});
  // final songModelList;
  // int idx;
  // PlaySong({super.key, required this.songModelList, required this.idx});

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

  // Future<void> _playSong(SongModel song) async {
  //   try {
  //     await player.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
  //     player.play();
  //   } catch (e) {
  //     print("Error playing song: $e");
  //   }
  // }

  //=============================
  Future<void> _playSongs(List<SongModel> songs) async {
    try {
      // Create a list of AudioSource from the songs list
      final playlist = ConcatenatingAudioSource(
        children: songs.map((song) {
          return AudioSource.uri(Uri.parse(song.uri!));
        }).toList(),
      );

      // Set the audio source to the playlist
      await player.setAudioSource(playlist);

      // Start playing
      player.play();
    } catch (e) {
      print("Error playing songs: $e");
    }
  }

  //==================
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  @override
  void initState() {
    _playSongs(widget.songs);
    // player.setUrl(
    //     "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Sevish_-__nbsp_.mp3");
    player.positionStream.listen((p) {
      setState(() {
        position = p;
      });
    });

    player.durationStream.listen((d) {
      setState(() {
        duration = d!;
      });
    });

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          position = Duration.zero;
        });
        player.pause();
        player.seek(position);
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
            Text(formatDuration(position)),
            Slider(
                min: 0.0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: handleSeek),
            Text(formatDuration(duration)),
            IconButton(
              onPressed: hadlePlayPause,
              icon: Icon(player.playing ? Icons.pause : Icons.play_arrow),
            )
          ],
        ),
      ),
    );
  }
}
