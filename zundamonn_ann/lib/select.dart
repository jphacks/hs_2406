import 'dart:convert';
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
  List<List<int>> _audioDataList = [];

  Future<String?> _fetchScript(String category) async {
    final url = Uri.parse('https://generateradio-xjbotcni5q-an.a.run.app');
    final body = jsonEncode({
      'category': [category] // 引数を使用してカテゴリを設定
    });
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        String? script = jsonResponse['script'] as String?;

        // スクリプトの最初の30文字を返す
        // TODO: 文字制限の対処方法を考える
        return script;
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Future<List<List<int>>> _callApi(String text) async {
    final maxTextLength = 300; // APIに渡すテキストの最大長さ
    _audioDataList.clear();
    await dotenv.load(fileName: '.env');
    final String apiKey = dotenv.env['VOICEVOX_API_KEY']!;

    // テキストを分割して順にリクエストを送信
    for (int i = 0; i < text.length; i += maxTextLength) {
      final part = text.substring(
        i,
        (i + maxTextLength) > text.length ? text.length : (i + maxTextLength),
      );
      final requestUrl = Uri.https(
        'deprecatedapis.tts.quest',
        '/v2/voicevox/audio/',
        {
          'key': apiKey,
          'speaker': '0',
          'pitch': '0',
          'intonationScale': '1',
          'speed': '1',
          'text': part,
        },
      ).toString();
      print('Request URL: $requestUrl');
      try {
        final response = await http.get(Uri.parse(requestUrl));
        print('Response status: ${response.statusCode}');
        print('Response headers: ${response.headers}');

        if (response.statusCode == 200) {
          // 音声データをバイト配列として取得
          _audioDataList.add(response.bodyBytes.toList());
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

    // 必ずリストを返す
    return _audioDataList;
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
                        final script = await _fetchScript(text);
                        final audioDataLst = await _callApi(script!);
                        setState(() {
                          _isLoading = false; // ローディング終了
                        });

                        if (_audioDataList != []) {
                          // 2ページ目に移動
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaybackPage(
                                audioPlayer: _audioPlayer,
                                audioDataList: audioDataLst,
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
