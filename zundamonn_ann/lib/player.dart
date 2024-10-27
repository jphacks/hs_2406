import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';

class PlaybackPage extends StatefulWidget {
  final List<int> audioData = [];
  AudioPlayer audioPlayer = AudioPlayer();
  List<List<int>> audioDataList = [];

  PlaybackPage({required this.audioPlayer, required this.audioDataList});

  @override
  _PlaybackPageState createState() => _PlaybackPageState();
}

class _PlaybackPageState extends State<PlaybackPage> {
  bool isPlaying = false; // 再生中かどうかを管理するフラグ
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
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
      isPlaying = true;
    });
    widget.audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _currentIndex++;
        if (_currentIndex < widget.audioDataList.length) {
          _playNextAudio(); // 次の音声を再生
        } else {
          setState(() {
            isPlaying = false; // 再生フラグをリセット
          });
        }
      }
    });
  }

  void _togglePlayback() {
    if (isPlaying) {
      widget.audioPlayer.pause();
    } else {
      widget.audioPlayer.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  void dispose() {
    widget.audioPlayer.dispose(); // AudioPlayerの解放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('音声再生'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // 上寄せ
          children: [
            Container(
              height: 500, // 画像の高さを固定
              child: Image.asset(
                'assets/images/zundamon.jpg', // 画像のパス
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 10), // 画像とボタンの間のスペースを小さくする
            ElevatedButton(
              onPressed: _playNextAudio, // 再生ボタン
              child: Text('再生'),
            ),
            SizedBox(height: 5), // ボタン間のスペース
            ElevatedButton(
              onPressed: () {
                widget.audioPlayer.stop(); // 停止ボタン
                setState(() {
                  isPlaying = false; // 再生フラグをリセット
                });
              },
              child: Text('停止'),
            ),
          ],
        ),
      ),
    );
  }
}
