import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'player.dart';

class MoodSelectionPage extends StatefulWidget {
  @override
  _MoodSelectionPageState createState() => _MoodSelectionPageState();
}

class _MoodSelectionPageState extends State<MoodSelectionPage> {
  TextEditingController _textController = TextEditingController();
  String _response = "ボタンを押してAPIを呼び出してください";
  AudioPlayer _audioPlayer = AudioPlayer();
  List<int>? _audioData; // 音声データを保持
  bool _isLoading = false; // ローディング状態を管理

  Future<List<int>?> _callApi(String text) async {
    await dotenv.load(fileName: '.env');
    final String apiKey = dotenv.env['VOICEVOX_API_KEY']!;
    final requestUrl = Uri.https(
      'deprecatedapis.tts.quest',
      '/v2/voicevox/audio/',
      {
        'key': apiKey,
        'speaker': '0',
        'pitch': '0',
        'intonationScale': '1',
        'speed': '1',
        'text': text,
      },
    ).toString();
    print('Request URL: $requestUrl');

    try {
      final response = await http.get(Uri.parse(requestUrl));
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        // 音声データをバイト配列として取得
        return response.bodyBytes;
      } else {
        setState(() {
          _response = "データの読み込みに失敗しました: ${response.statusCode}";
        });
        return null;
      }
    } catch (e) {
      setState(() {
        _response = "エラー: $e";
      });
      return null;
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
        title: Text('聴きたいラジオのテーマを選択 💭'),
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
              onPressed: _isLoading
                  ? null // ローディング中はボタンを無効にする
                  : () async {
                      String text = _textController.text;
                      if (text.isNotEmpty && _isLoading == false) {
                        setState(() {
                          _isLoading = true; // ローディング開始
                          _response = "読み込み中..."; // ローディングメッセージを表示
                        });

                        // 音声データを取得
                        final audioData = await _callApi(text);
                        setState(() {
                          _isLoading = false; // ローディング終了
                        });

                        if (audioData != null) {
                          // 2ページ目に移動
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaybackPage(
                                audioPlayer: _audioPlayer,
                                audioData: audioData,
                              ),
                            ),
                          ).then((_) {
                            // 戻ったときに状態をリセット
                            _response = "ボタンを押してAPIを呼び出してください";
                            _isLoading = false;
                          });
                        }
                      } else {
                        setState(() {
                          _response = "テキストを入力してください"; // 入力がない場合のメッセージ
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: TextStyle(fontSize: 20),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white, // インジケーターの色
                    )
                  : Text('ラジオを生成'),
            ),
            SizedBox(height: 20),
            Text(_response), // レスポンスメッセージ
          ],
        ),
      ),
    );
  }
}
