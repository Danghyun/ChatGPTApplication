import 'package:chatgptclone/SecureStorageController/secure_storage_controller.dart';
import 'package:chatgptclone/ServerController/Chat_Server_Controller.dart';

abstract class AbstractInitializeService {
  // [초기 데이터 받아오기]
  Future<void> fetchInitialData();
}

class InitializeService {
  // [싱글톤 구현]
  static final InitializeService _instance = InitializeService._internal();
  InitializeService._internal();
  factory InitializeService() => _instance;
  
  // [클래스 필드 초기화]
  final SecureStorageController _secureStorageController = SecureStorageController();
  final ChatServerController _chatServerController = ChatServerController();
  
  // [변수 초기화]
  late bool existingUserData;

  // [초기 데이터 받아오기]
  Future<void> fetchInitialData() async {
    print("[InitializeService] SecureStorage 데이터 로드를 시작합니다.");
    await _secureStorageController.loadUserInfo();
    print("[InitializeService] SecureStorage 데이터 로드를 완료하였습니다.");
    print("[InitializeService] User 정보의 유무를 확인합니다.");
    if (_secureStorageController.userID != null
     && _secureStorageController.userName != null
     && _secureStorageController.apiKey != null
    ) {
      print("[InitializeService] User의 정보가 존재합니다.");
      existingUserData = true;
      print("[InitializeService] 채팅방 목록 조회를 시작합니다.");
      // [채팅방 목록 조회]
      await _chatServerController.fetchChatRoom();
      print("[InitializeService] 채팅방 목록 조회를 완료하였습니다.");
      print("[InitializeService] 메시지 목록 조회를 시작합니다.");
      await _chatServerController.fetchChatMessage();
      print("[InitializeService] 메시지 목록 조회를 완료하였습니다.");
    } else {
      print("[InitializeService] 저장된 User 정보가 없습니다.");
      existingUserData = false;
      print("[InitializeService] apiKey 등록페이지로 이동합니다.");
    }
  }
}