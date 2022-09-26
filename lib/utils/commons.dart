import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const storage = FlutterSecureStorage();
  static String? accessToken;
  static String? refreshToken;
  static DateTime? expireAt;

  static Future<void> loadToken() async {
    accessToken = await storage.read(key: 'accessToken');
    refreshToken = await storage.read(key: 'refreshToken');
    final a = await storage.read(key: 'expireAt');
    expireAt = DateTime.tryParse(a ?? '1970-01-01');
  }

  static Future<void> saveToken(
    String? accessToken,
    String? refreshToken,
    DateTime? expireAt,
  ) async {
    await storage.write(key: 'expireAt', value: expireAt.toString());
    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'refreshToken', value: refreshToken);
    SecureStore.accessToken = accessToken;
    SecureStore.refreshToken = refreshToken;
    SecureStore.expireAt = expireAt;
  }
}
