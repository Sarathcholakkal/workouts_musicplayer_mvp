import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class NewScreen extends StatefulWidget {
  final List<SongModel> songs;

  const NewScreen({super.key, required this.songs});

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: ListView.builder(
      itemCount: widget.songs.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(widget.songs[index].title),
          subtitle: Text(widget.songs[index].artist ?? 'Unknown Artist'),
        );
      },
    ));
  }
}
