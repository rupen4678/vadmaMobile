// Verification Checklist:
// 1. Is the Android Emulator actually running?
// 2. Are you using Chrome (Web) instead of Android Emulator? 
//    If you are running on Chrome, '10.0.2.2' will fail! 
//    Chrome uses 'localhost' or '127.0.0.1'.
// 3. Update baseUrl dynamically based on platform or environment.

// Proposed fix for dio_client.dart:
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Use '10.0.2.2' for Android Emulator
// Use 'localhost' for Web
final baseUrl = kIsWeb ? 'http://localhost:8000/api/' : 'http://10.0.2.2:8000/api/';
