import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  
  static const String _tokenKey = 'authToken';
  static const String _userTypeKey = 'userType';
  static const String _userNameKey = 'userName';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> saveUserType(String userType) async {
    await _storage.write(key: _userTypeKey, value: userType);
  }

  static Future<String?> getUserType() async {
    return await _storage.read(key: _userTypeKey);
  }

  static Future<void> saveUserName(String userName) async {
    await _storage.write(key: _userNameKey, value: userName);
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
