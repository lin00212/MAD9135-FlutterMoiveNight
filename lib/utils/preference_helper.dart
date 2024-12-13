import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  static const String sessionIdKey = 'session_id';

  static Future<void> setSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sessionIdKey, sessionId);
  }

  static Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(sessionIdKey) ?? '';
  }

  static Future<void> clearSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionIdKey);
  }
}
