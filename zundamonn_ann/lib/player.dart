import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlaybackPage extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final List<int> audioData; // 音声データを受け取る

  PlaybackPage({required this.audioPlayer, required this.audioData});

  @override
  _PlaybackPageState createState() => _PlaybackPageState();
}

class _PlaybackPageState extends State<PlaybackPage> {
  bool isPlaying = false; // 再生中かどうかを管理するフラグ

  Future<void> _playAudio() async {
    if (!isPlaying) {
      await widget.audioPlayer.setAudioSource(AudioSource.uri(
        Uri.dataFromBytes(widget.audioData, mimeType: 'audio/x-wav'),
      ));
      await widget.audioPlayer.play();
      setState(() {
        isPlaying = true; // 再生中に設定
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        setState(() {
          isPlaying = true;
        });
      } else {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.audioPlayer.dispose(); // AudioPlayerの解放
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
              height: 600, // 画像の高さを固定
              child: Image.asset(
                'assets/images/zundamon.jpg', // 画像のパス
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 10), // 画像とボタンの間のスペースを小さくする
            ElevatedButton(
              onPressed: _playAudio, // 再生ボタン
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
