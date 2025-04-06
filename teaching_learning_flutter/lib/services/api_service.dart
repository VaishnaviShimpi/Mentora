import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:async';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8000";

  // Helper function to read file as bytes
  static Future<Uint8List> _readFileBytes(html.File file) {
    final completer = Completer<Uint8List>();
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((event) {
      completer.complete(reader.result as Uint8List);
    });
    reader.onError.listen((event) {
      completer.completeError("Error reading file");
    });
    return completer.future;
  }

  // Existing summarizePdf method (already working)
  static Future<String> summarizePdf(html.File file) async {
    final fileBytes = await _readFileBytes(file);
    var request =
        http.MultipartRequest("POST", Uri.parse("$baseUrl/summarize_pdf"));
    request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: file.name));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["summary"];
    } else {
      throw Exception("Error summarizing file");
    }
  }

  // Add method for Assignment Generation
  static Future<String> generateAssignments(
      html.File file, String level) async {
    final fileBytes = await _readFileBytes(file);
    var request = http.MultipartRequest(
        "POST", Uri.parse("$baseUrl/generate_assignments"));
    request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: file.name));
    request.fields['level'] = level;

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["assignments"];
    } else {
      throw Exception("Error generating assignments");
    }
  }

  // Method for Translation
  static Future<String> translateText(
      String text, String targetLanguage) async {
    var response = await http.post(
      Uri.parse("$baseUrl/translate_text"),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: {
        "text": text,
        "target_language": targetLanguage,
      },
    );

    if (response.statusCode == 200) {
      final utf8Decoded = utf8.decode(response.bodyBytes);
      return jsonDecode(utf8Decoded)["translated_text"];
    } else {
      throw Exception("Translation failed");
    }
  }

  static Future<Map<String, dynamic>> checkHandwrittenAssignment(
      html.File imageFile, String correctAnswer) async {
    final fileBytes = await _readFileBytes(imageFile);
    var request = http.MultipartRequest(
        "POST", Uri.parse("$baseUrl/check_handwritten_assignment"));

    request.files.add(http.MultipartFile.fromBytes('image', fileBytes,
        filename: imageFile.name));
    request.fields['correct_answer'] = correctAnswer;

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final utf8Decoded = utf8.decode(response.bodyBytes);
      return jsonDecode(utf8Decoded);
    } else {
      throw Exception("Error checking handwritten assignment");
    }
  }
}
