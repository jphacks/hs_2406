import 'package:flutter/material.dart';
import 'select.dart'; // select.dartをインポート
import 'send_mail.dart'; // send_mail.dartをインポート

class ListenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('選択してください'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // select.dartに遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MoodSelectionPage(),
                  ),
                );
              },
              child: Text('ラジオを聴く'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // send_mail.dartに遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SendMailPage(),
                  ),
                );
              },
              child: Text('メールを送る'),
            ),
          ],
        ),
      ),
    );
  }
}
