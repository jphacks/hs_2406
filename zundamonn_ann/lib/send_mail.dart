import 'dart:convert';
import 'package:flutter/material.dart';

class SendMailPage extends StatefulWidget {
  @override
  _SendMailPageState createState() => _SendMailPageState();
}

class _SendMailPageState extends State<SendMailPage> {
  final TextEditingController _radioNameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  void _sendMail() {
    String radioName = _radioNameController.text;
    String message = _messageController.text;

    // JSON形式でデバッグ出力
    Map<String, String> mailData = {
      'radio_name': radioName,
      'message': message,
    };

    print(jsonEncode(mailData)); // JSON形式で出力

    // ここでメール送信の処理を追加できます
    // 例えば、APIを呼び出すなど
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('メールが送信されました')),
    );

    // フォームをリセット
    _radioNameController.clear();
    _messageController.clear();
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
              onPressed: _sendMail,
              child: Text('送信'),
            ),
          ],
        ),
      ),
    );
  }
}
