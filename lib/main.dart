import 'dart:typed_data';

import 'package:audio_query_sample/playsong.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

// Global instance of OnAudioQuery
final OnAudioQuery audioQuery = OnAudioQuery();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initAudioQuery();
  }

  Future<void> _initAudioQuery() async {
    // Set logging if needed
    LogConfig logConfig = LogConfig(logType: LogType.DEBUG);
    audioQuery.setLogConfig(logConfig);

    // Continuously request permission until granted
    while (!hasPermission) {
      hasPermission = await audioQuery.checkAndRequest();
      if (!hasPermission) {
        // Show a message or notification to the user
        _showPermissionDeniedDialog();
      } else {
        // Update UI if permission is granted
        setState(() {});
      }
    }
  }

  // Method to show permission denied message
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Denied"),
        content: const Text(
            "This app requires permission to access your audio library."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initAudioQuery(); // Try again
            },
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("OnAudioQuery Example"),
        ),
        body:
            hasPermission ? const SongListScreen() : noAccessToLibraryWidget(),
      ),
    );
  }

  Widget noAccessToLibraryWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Application doesn't have access to the library"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _initAudioQuery(),
            child: const Text("Request Permission"),
          ),
        ],
      ),
    );
  }
}

class SongListScreen extends StatelessWidget {
  const SongListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SongModel>>(
      future: audioQuery.querySongs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading songs'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No songs found'));
        }

        final allSongs = snapshot.data!; // songs without any filetering
        //!songs are filererd below logic select only mp3 files , exculded short audio and opus extentios files.
        final songs = allSongs.where((song) {
          final isWhatsAppFile = song.data.contains("WhatsApp") ||
              song.displayName.startsWith("PTT");
          // final isShortDuration =
          //     song.duration != null && song.duration! <= 30000;
          final isOpusFile = song.fileExtension == "opus";
          return !isWhatsAppFile &&
              !isOpusFile; //isShortDuration &&  if need add short duration filter
        }).toList();

        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];

            return GestureDetector(
              onDoubleTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => PlaySong(songs: songs, index: index)));
              },
              child: ListTile(
                trailing: QueryArtworkWidget(
                  //? image meta data associated with audio file shows here
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  artworkFit: BoxFit.cover,
                  artworkBorder: BorderRadius.circular(10),
                  artworkWidth: 50,
                  artworkHeight: 50,
                  nullArtworkWidget: Icon(
                    Icons.music_note,
                    size: 50,
                  ),
                ),
                // trailing: Container(
                //   height: 50,
                //   width: 50,
                //   decoration:3wsz3wsz3456789 const BoxDecoration(color: Colors.red),
                // ),
                title: Text(song.title),
                subtitle: Text(song.artist ?? 'Unknown Artist'),
              ),
            );
          },
        );
      },
    );
  }
  //==================
}

// Future<Uint8List?> fetchArtworkBytes(SongModel song) async {
//   try {
//     final artwork = await song.artwork?.getOrElse(() => null);
//     if (artwork != null) {
//       return await artwork.getBytes();
//     }
//   } catch (error) {
//     print('Error fetching artwork: $error');
//   }
//   return null;
// }
