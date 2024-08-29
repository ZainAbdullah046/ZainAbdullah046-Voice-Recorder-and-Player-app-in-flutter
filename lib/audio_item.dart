import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioItem extends StatefulWidget {
  const AudioItem({super.key, required this.item});
  final SongModel item;

  @override
  State<AudioItem> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AudioItem> {
  final AudioPlayer _player = AudioPlayer();
  bool _isplay = true;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (_isplay) {
          _player.setAudioSource(AudioSource.file(widget.item.data));
          _player.play();
        } else {
          _player.stop();
        }
        setState(() {
          _isplay = !_isplay;
        });
      },
      child: ListTile(
        title: Text(widget.item.title),
        subtitle: Text(widget.item.artist ?? "No artist"),
        trailing: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 42, 147, 233),
                Color.fromARGB(255, 204, 51, 102)
              ],
              begin: FractionalOffset(0.0, 0.1),
              end: FractionalOffset(0.0, 0.1),
              stops: [0.0, 0.1],
              tileMode: TileMode.clamp,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(10),
          child: _isplay
              ? const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                )
              : const Icon(
                  Icons.pause,
                  color: Colors.white,
                ),
        ),
        leading:
            QueryArtworkWidget(id: widget.item.id, type: ArtworkType.AUDIO),
      ),
    );
  }
}
