import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

abstract class AbstractAPIKeyManager {
  Future<void> saveUserInfo({
    required String userName,
    required String apiKey,
  });

  Future<void> loadUserInfo();

  Future<void> readUserInfo();

  Future<void> deleteUserInfo();
}

class SecureStorageController extends AbstractAPIKeyManager {
  // [싱글톤 생성]
  static final SecureStorageController _instance = SecureStorageController._internal();
  factory SecureStorageController() => _instance;
  final FlutterSecureStorage _flutterSecureStorage;
  SecureStorageController._internal() : _flutterSecureStorage = FlutterSecureStorage(aOptions: _getAndroidOptions());
  static AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );

  // [변수 선언]
  String? _userID;
  String? _userName;
  String? _apiKey;

  // [Getter 선언]
  String? get userID => _userID;
  String? get userName => _userName;
  String? get apiKey => _apiKey;

  // [Secure Storage에 User정보 저장하기]
  @override
  Future<void> saveUserInfo({
    required String userName,
    required String apiKey,
  }) async {
    String userID = const Uuid().v4();
    print("[uuid] : $userID");
    final userInfo = jsonEncode({
      "user_id": userID,
      'username': userName,
      'api_key': apiKey,
    });
    await _flutterSecureStorage.write(key: 'userInfo', value: userInfo);
    await loadUserInfo();
  }

  // [Secure Storage에 User정보 로드하기]
  @override
  Future<void> loadUserInfo() async {
    print("[Secure_Storage_Controller] SecureStorage 데이터 로드를 시작합니다.");
    final userInfo = await _flutterSecureStorage.read(key: 'userInfo');

    if (userInfo == null) {
      print("[Secure_Storage_Controller] userInfo 데이터가 없습니다.");
      return;
    }

    final decodeUserInfo = jsonDecode(userInfo) as Map<String, dynamic>;
    _userID = decodeUserInfo['user_id'] as String;
    _userName = decodeUserInfo['username'] as String;
    _apiKey = decodeUserInfo['api_key'] as String;
    print("[Secure_Stroage_Controller.dart] SecureStorage 데이터 로드가 완료되었습니다.");
  }

  @override
  Future<String?> readUserInfo() async {
    await loadUserInfo();
    return ("[User] $userName + [apiKey] $apiKey}");
  }

  @override
  Future<void> deleteUserInfo() async {
    await _flutterSecureStorage.deleteAll();
  }
}