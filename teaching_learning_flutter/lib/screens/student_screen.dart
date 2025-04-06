import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  String inputText = "";
  String translatedText = "";
  bool loadingTranslation = false;
  String targetLanguage = 'Hindi';

  void translate() {
    setState(() => loadingTranslation = true);
    ApiService.translateText(inputText, targetLanguage).then((res) {
      setState(() {
        translatedText = res;
        loadingTranslation = false;
      });
    }).catchError((e) {
      setState(() {
        translatedText = "Error: $e";
        loadingTranslation = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Options")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter text to translate",
              ),
              onChanged: (val) => inputText = val,
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: targetLanguage,
              items: ['Hindi', 'French', 'German', 'Japanese', 'Korean']
                  .map((lang) {
                return DropdownMenuItem(value: lang, child: Text(lang));
              }).toList(),
              onChanged: (value) {
                setState(() => targetLanguage = value!);
              },
            ),
            ElevatedButton(
              onPressed: translate,
              child: Text("Translate"),
            ),
            SizedBox(height: 20),
            if (loadingTranslation) CircularProgressIndicator(),
            if (translatedText.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(translatedText, style: TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
