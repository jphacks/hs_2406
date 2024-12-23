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
  String _response = "";
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;
  List<List<int>> _audioDataList = [];
  List<String> selectedCategories = []; // 選択されたカテゴリを保持
  final TextEditingController _customCategoryController =
      TextEditingController();

  final List<String> categories = [
    "お笑い",
    "集中",
    "冒険",
    "楽しい",
    "ロマンチック",
    "感謝",
    "刺激",
    "穏やか",
    "平和",
    "おしゃれ",
    "わくわく"
  ];

  Future<String?> _fetchScript(List<String> categories) async {
    final url = Uri.parse('https://generateradio-xjbotcni5q-an.a.run.app');
    final body = jsonEncode({'category': categories});
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
        String _response = "エラー: APIキーが設定されていません";
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

  void _toggleCategorySelection(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category); // 選択解除
      } else {
        selectedCategories.add(category); // 選択
      }
    });
  }

  void _addCustomCategory() {
    final customCategory = _customCategoryController.text.trim();
    if (customCategory.isNotEmpty &&
        !selectedCategories.contains(customCategory)) {
      setState(() {
        selectedCategories.add(customCategory); // 自由記入欄のカテゴリを追加
        _customCategoryController.clear(); // 入力欄をクリア
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _customCategoryController.dispose();
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
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: categories.map((category) {
                final isSelected = selectedCategories.contains(category);
                return ElevatedButton(
                  onPressed: () => _toggleCategorySelection(category),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20, vertical: 4), // 縦幅を小さくする
                    shape: StadiumBorder(),
                    elevation: 8,
                    backgroundColor:
                        isSelected ? Colors.blueAccent : Colors.grey.shade300,
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _customCategoryController,
              decoration: InputDecoration(
                labelText: '自由記入カテゴリ',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addCustomCategory,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedCategories.isEmpty || _isLoading
                  ? null
                  : () async {
                      setState(() {
                        _isLoading = true;
                        _response = "読み込み中...";
                      });

                      final script = await _fetchScript(selectedCategories);
                      if (script != null) {
                        final audioDataLst = await callVoiceApi(script);
                        setState(() {
                          _isLoading = false;
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
                          _response = "データの取得に失敗しました";
                          _isLoading = false;
                        });
                      }
                    },
              child: Text("ラジオを生成"),
            ),
            SizedBox(height: 20),
            if (_isLoading) CircularProgressIndicator() else Text(_response),
            SizedBox(height: 20),
            // 選択されたカテゴリの一覧を表示
            if (selectedCategories.isNotEmpty) ...[
              Text(
                "選択されたカテゴリ:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8.0,
                children: selectedCategories.map((category) {
                  return Chip(
                    label: Text(category),
                    deleteIcon: Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        selectedCategories.remove(category);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
