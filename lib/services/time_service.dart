import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TimeService {
  static Duration _offset = Duration.zero;
  static bool _isSynced = false;

  /// Syncs local time with real network time.
  /// Measures the offset between local device time and network time,
  /// storing it so subsequent calls to [now] are local and instant.
  static Future<void> syncTime() async {
    try {
      final response = await http.head(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 3));
      final dateStr = response.headers['date'];
      if (dateStr != null) {
        final networkTime = HttpDate.parse(dateStr);
        final deviceTime = DateTime.now();
        _offset = networkTime.difference(deviceTime);
        _isSynced = true;
        debugPrint("Time synced successfully! Offset: $_offset");
      }
    } catch (e) {
      debugPrint("Failed to sync network time: $e");
    }
  }

  /// Returns the network-synchronized current DateTime.
  static DateTime now() {
    return DateTime.now().add(_offset);
  }

  /// Returns true if the time offset has been synchronized from the network.
  static bool get isSynced => _isSynced;
}
