import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AppConfig {
  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

  static String? _runtimeApiKey;

  static Future<String> getActiveApiKey() async {
    if (openAiApiKey.isNotEmpty && openAiApiKey != 'YOUR_API_KEY_HERE') {
      return openAiApiKey;
    }
    if (_runtimeApiKey != null && _runtimeApiKey!.isNotEmpty) {
      return _runtimeApiKey!;
    }
    // Load from local file
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/openai_key.txt');
      if (await file.exists()) {
        final savedKey = (await file.readAsString()).trim();
        if (savedKey.isNotEmpty) {
          _runtimeApiKey = savedKey;
          return savedKey;
        }
      }
    } catch (e) {
      debugPrint("Failed to load local API Key: $e");
    }
    return '';
  }

  static Future<void> saveApiKey(String key) async {
    _runtimeApiKey = key;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/openai_key.txt');
      await file.writeAsString(key);
    } catch (e) {
      debugPrint("Failed to save local API Key: $e");
    }
  }
}
