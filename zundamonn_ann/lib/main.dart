import 'package:flutter/material.dart';
import 'dart:convert'; // JSON処理用
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart'; // just_audioをインポート

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Selector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MoodSelectionPage(),
    );
  }
}

class MoodSelectionPage extends StatefulWidget {
  @override
  _MoodSelectionPageState createState() => _MoodSelectionPageState();
}

class _MoodSelectionPageState extends State<MoodSelectionPage> {
  TextEditingController _textController = TextEditingController();
  String _response = "ボタンを押してAPIを呼び出してください";
  AudioPlayer _audioPlayer = AudioPlayer();
  List<int>? _audioData; // 音声データを保持

  Future<void> _callApi(String text) async {
    final requestUrl =
        'https://deprecatedapis.tts.quest/v2/voicevox/audio/?key=i_43z4K2Z_K_020&speaker=0&pitch=0&intonationScale=1&speed=1&text=${Uri.encodeComponent(text)}';

    try {
      final response = await http.get(Uri.parse(requestUrl));
      print('ステータスコード: ${response.statusCode}');

      if (response.statusCode == 200) {
        // 音声データをバイト配列として取得
        _audioData = response.bodyBytes;

        // 2ページ目に移動
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaybackPage(
              audioPlayer: _audioPlayer,
              audioData: _audioData!,
            ),
          ),
        );
      } else {
        setState(() {
          _response = "データの読み込みに失敗しました: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "エラー: $e";
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('気分を選択'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: '言ってほしい言葉を入力してください',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                String text = _textController.text;
                if (text.isNotEmpty) {
                  _callApi(text); // 音声データを取得し、ページ遷移
                } else {
                  setState(() {
                    _response = "テキストを入力してください";
                  });
                }
              },
              child: Text('音声を生成'),
            ),
            SizedBox(height: 20),
            Text(_response),
          ],
        ),
      ),
    );
  }
}

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                'assets/images/zundamon.jpg', // 画像のパス
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _playAudio, // 再生ボタン
              child: Text('再生'),
            ),
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
