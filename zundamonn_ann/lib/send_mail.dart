import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'player.dart';

class SendMailPage extends StatefulWidget {
  @override
  _SendMailPageState createState() => _SendMailPageState();
}

class _SendMailPageState extends State<SendMailPage> {
  final TextEditingController _radioNameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _response = "";
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;
  List<List<int>> _audioDataList = [];

  Future<void> _sendMail() async {
    String radioName = _radioNameController.text;
    String message = _messageController.text;

    // JSON形式でデバッグ出力
    Map<String, String> mailData = {
      'radio_name': radioName,
      'message': message,
    };

    print(jsonEncode(mailData)); // JSON形式で出力

    setState(() {
      _isLoading = true; // ローディング状態に設定
      _response = ""; // 以前のレスポンスをクリア
    });

    final script = await _callApi(mailData);
    if (script != null) {
      final audioDataLst = await callVoiceApi(script);
      setState(() {
        _isLoading = false; // ローディング状態を解除
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaybackPage(
            audioPlayer: _audioPlayer,
            audioDataList: audioDataLst,
          ),
        ),
      );
    } else {
      setState(() {
        _response = "データの取得に失敗しました"; // エラーメッセージを設定
        _isLoading = false; // ローディング状態を解除
      });
    }

    // フォームをリセット
    _radioNameController.clear();
    _messageController.clear();
  }

  Future<String?> _callApi(Map<String, String> mailData) async {
    final url = Uri.parse('https://generateanswer-xjbotcni5q-an.a.run.app');
    final body = jsonEncode(
        {'radioname': mailData['radio_name'], 'text': mailData['message']});
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      print(response.body);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['script'] as String?;
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Future<List<List<int>>> callVoiceApi(String text) async {
    final maxTextLength = 300;
    _audioDataList.clear();
    await dotenv.load(fileName: '.env');

    final String? apiKey = dotenv.env['VOICEVOX_API_KEY'];
    if (apiKey == null) {
      print("Error: VOICEVOX_API_KEY is not set");
      setState(() {
        _response = "エラー: APIキーが設定されていません";
      });
      return [];
    }

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

      try {
        final response = await http.get(Uri.parse(requestUrl));
        if (response.statusCode == 200) {
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
    return _audioDataList;
  }

  @override
  void dispose() {
    _radioNameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('メールを送る'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _radioNameController,
              decoration: InputDecoration(
                labelText: 'ラジオネーム',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'お便り',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendMail, // ローディング中はボタン無効化
              child: _isLoading ? CircularProgressIndicator() : Text('送信'),
            ),
            SizedBox(height: 16.0),
            if (_response.isNotEmpty) Text(_response), // エラーメッセージ表示
          ],
        ),
      ),
    );
  }
}
