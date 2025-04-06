import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:html' as html;

class TeacherScreen extends StatefulWidget {
  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  String outputText = "";
  bool isLoading = false;
  String selectedLevel = 'Easy';
  String extractedText = "";
  String feedback = "";
  bool loadingCheck = false;
  TextEditingController answerController = TextEditingController();

  void pickAndProcessPdf(String action) async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput..accept = '.pdf';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      setState(() => isLoading = true);

      if (action == "summarize") {
        ApiService.summarizePdf(file).then((res) {
          setState(() {
            outputText = "📚 Summary:\n\n$res";
            isLoading = false;
          });
        }).catchError((e) {
          setState(() {
            outputText = "Error: $e";
            isLoading = false;
          });
        });
      } else if (action == "assignments") {
        ApiService.generateAssignments(file, selectedLevel).then((res) {
          setState(() {
            outputText = "📝 Assignments ($selectedLevel):\n\n$res";
            isLoading = false;
          });
        }).catchError((e) {
          setState(() {
            outputText = "Error: $e";
            isLoading = false;
          });
        });
      }
    });
  }

  void checkAssignment() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      setState(() => loadingCheck = true);

      ApiService.checkHandwrittenAssignment(file, answerController.text)
          .then((res) {
        setState(() {
          extractedText = res['extracted_text'];
          feedback = res['feedback'];
          loadingCheck = false;
        });
      }).catchError((e) {
        setState(() {
          feedback = "Error: $e";
          loadingCheck = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Teacher Options")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // PDF Summarization section
              ElevatedButton.icon(
                icon: Icon(Icons.summarize),
                label: Text("Upload PDF and Summarize"),
                onPressed: () => pickAndProcessPdf("summarize"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent),
              ),
              SizedBox(height: 15),

              // Assignment Generation section
              DropdownButton<String>(
                value: selectedLevel,
                items: ['Easy', 'Medium', 'Hard'].map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedLevel = value!);
                },
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.assignment),
                label: Text("Upload PDF and Generate Assignments"),
                onPressed: () => pickAndProcessPdf("assignments"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),

              SizedBox(height: 20),

              if (isLoading) Center(child: CircularProgressIndicator()),
              if (outputText.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    outputText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),

              Divider(height: 40),

              // Handwritten Assignment Check section
              TextField(
                controller: answerController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Correct Answer (for handwritten assignment)",
                ),
              ),
              SizedBox(height: 10),

              ElevatedButton.icon(
                icon: Icon(Icons.upload_file),
                label: Text("Upload Handwritten Answer Sheet"),
                onPressed: checkAssignment,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              SizedBox(height: 20),

              if (loadingCheck) Center(child: CircularProgressIndicator()),
              if (extractedText.isNotEmpty) ...[
                Text("✍️ Extracted Text:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(extractedText, style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 20),
              ],
              if (feedback.isNotEmpty) ...[
                Text("✅ Feedback:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(feedback, style: TextStyle(fontSize: 16)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
