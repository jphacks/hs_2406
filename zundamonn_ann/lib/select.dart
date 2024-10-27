import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'player.dart';

class MoodSelectionPage extends StatefulWidget {
  @override
  _MoodSelectionPageState createState() => _MoodSelectionPageState();
}

class _MoodSelectionPageState extends State<MoodSelectionPage> {
  TextEditingController _textController = TextEditingController();
  String _response = "ボタンを押してAPIを呼び出してください";
  AudioPlayer _audioPlayer = AudioPlayer();
  List<List<int>> _audioDataList = []; // 音声データを保持するリスト

  Future<void> _callApi(String text) async {
    final maxTextLength = 300; // APIに渡すテキストの最大長さ
    _audioDataList.clear();

    // テキストを分割して順にリクエストを送信
    for (int i = 0; i < text.length; i += maxTextLength) {
      final part = text.substring(
          i,
          (i + maxTextLength) > text.length
              ? text.length
              : (i + maxTextLength));
      final requestUrl =
          'https://deprecatedapis.tts.quest/v2/voicevox/audio/?key=i_43z4K2Z_K_020&speaker=0&pitch=0&intonationScale=1&speed=1&text=${Uri.encodeComponent(part)}';

      try {
        final response = await http.get(Uri.parse(requestUrl));
        print('ステータスコード: ${response.statusCode}');

        if (response.statusCode == 200) {
          // 音声データをバイト配列として取得してリストに追加
          _audioDataList.add(response.bodyBytes);
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

    // 全てのリクエストが完了したら次のページへ遷移
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaybackPage(
          audioPlayer: _audioPlayer,
          audioDataList: _audioDataList,
        ),
      ),
    );
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
