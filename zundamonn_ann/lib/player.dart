import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert'; // base64Encode を使用するために追加

class PlaybackPage extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final List<List<int>> audioDataList;

  PlaybackPage({required this.audioPlayer, required this.audioDataList});

  @override
  _PlaybackPageState createState() => _PlaybackPageState();
}

class _PlaybackPageState extends State<PlaybackPage> {
  int _currentIndex = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _playNextAudio(); // 初回の音声を再生
  }

  // 次の音声を再生するメソッド
  Future<void> _playNextAudio() async {
    if (_currentIndex >= widget.audioDataList.length) return; // 全て再生終了

    // バイトデータを base64 エンコードして AudioSource にセット
    final audioSource = AudioSource.uri(
      Uri.parse(
          'data:audio/mp3;base64,${base64Encode(widget.audioDataList[_currentIndex])}'),
    );

    await widget.audioPlayer.setAudioSource(audioSource);
    await widget.audioPlayer.play();
    setState(() {
      _isPlaying = true;
    });

    // 再生終了時に次の音声を再生
    widget.audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _currentIndex++;
        if (_currentIndex < widget.audioDataList.length) {
          _playNextAudio(); // 次の音声を再生
        }
      }
    });
  }

  // 再生/一時停止の切り替え
  void _togglePlayback() {
    if (_isPlaying) {
      widget.audioPlayer.pause();
    } else {
      widget.audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    widget.audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('再生ページ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ずんだもんの画像を表示
            Image.asset(
              'assets/images/zundamon.jpg', // 画像のパスを指定
              height: 200,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _togglePlayback,
              child: Text(_isPlaying ? '停止' : '再生'),
            ),
          ],
        ),
      ),
    );
  }
}
