import 'dart:convert';
import 'package:chatgptclone/SecureStorageController/secure_storage_controller.dart';
import 'package:chatgptclone/ServerController/Initialize_Server_Contrller.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

abstract class AbstractChatRoomServerController extends ChangeNotifier {

  // [서버에서 ChatRoom Data 가져오기]
  Future<void> fetchChatRoom();

  // [서버에서 ChatMessage Data 가져오기]
  Future<void> fetchChatMessage();

  // [메시지 전송 버튼 로직]
  Future<void> sendMessage({
    required String content,
  });

  // [임시 채팅방 생성]
  Future<void> generateTempChatRoom();

  // [사용자 채팅 메시지 저장]
  Future<void> saveMessage({
    required String content,
  });

  // [AI 답변 생성 요청]
  Future<void> generateAIResponse();

  // [채팅방 제목 생성]
  Future<void> generateChatRoomName({
    required String content,
  });

  // [채팅방 마지막 업데이트시간 최신화]
  Future<void> updatedChatRoomLastUpdated();

  // [채팅방 생성 버튼] [완료]
  void generateChatRoomButton();

  // [채팅방 선택 버튼] [완료]
  void selectChatRoomButton(int index);
}

class ChatServerController extends AbstractChatRoomServerController {
  // [싱글톤 생성]
  static final ChatServerController _instance =
      ChatServerController._internal();

  ChatServerController._internal();

  factory ChatServerController() => _instance;

  // [클래스 필드 초기화]
  final SecureStorageController _secureStorageController =
      SecureStorageController();

  // [변수 생성]
  List<Map<String, dynamic>> _chatRoomData = [];
  List<Map<String, dynamic>> _chatMessageData = [];
  int? _selectedChatRoomIndex;
  String? editingRoomId;

  // [Getter]
  List<Map<String, dynamic>> get chatRoomData => _chatRoomData;

  List<Map<String, dynamic>> get chatMessageData => _chatMessageData;

  int? get selectedChatRoomIndex => _selectedChatRoomIndex;

  // [서버에서 ChatRoom Data 가져오기]
  @override
  Future<void> fetchChatRoom() async {
    print("[ChatServerController] 서버에 채팅방 데이터를 요청합니다.");
    final url = Uri.parse("$baseUrl/ChatRoom/fetchChatRoom");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "userId": _secureStorageController.userID,
      }),
    );

    if (response.statusCode == 200) {
      print("[ChatServerController] 서버에 채팅방 데이터 요청을 성공적으로 받았습니다.");
      List<dynamic> jsonData = jsonDecode(response.body);
      _chatRoomData =
          jsonData.map((chatRoom) => chatRoom as Map<String, dynamic>).toList();
      print("[ChatServerController] _chatRoom 데이터");
      print(chatRoomData);
      notifyListeners();
    } else {
      throw Exception("Failed to load chat Room");
    }
  }

  // [서버에서 ChatMessage Data 가져오기]
  @override
  Future<void> fetchChatMessage() async {
    if (_selectedChatRoomIndex == null) {
      print("[ChatServerController] 선택된 채팅방이 없습니다.");
      return;
    }
    final selectedRoomId = _chatRoomData[_selectedChatRoomIndex!]["room_id"] as String;
    print("[ChatServerController] 서버에 메시지 데이터를 요청합니다.");
    print("[ChatServerController] selectedRoomID : $selectedRoomId");

    final url = Uri.parse("$baseUrl/ChatMessage/fetchChatMessage");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "roomId": selectedRoomId,
        }),
      );
      if (response.statusCode == 200) {
        print("[ChatRoomService] 서버에 채팅방 데이터 요청을 성공적으로 받았습니다.");
        List<dynamic> jsonData = jsonDecode(response.body);
        _chatMessageData = jsonData
            .map((chatMessage) => chatMessage as Map<String, dynamic>)
            .toList();
        print("[ChatServerController] _chatMessage 데이터");
        print(chatMessageData);
        notifyListeners();
      } else {
        print("[ChatServerController] Error: ${response.statusCode}");
        print("[ChatServerController] 이유 : ${response.body}");
      }
    } catch (e) {
      print("[ChatServerController] 메시지 목록 조회 중 오류가 발생했습니다.");
      print("[ChatServerController] 오류가 발생했습니다. $e");
    }
  }
  
  // [메시지 전송 버튼 로직]
  @override
  Future<void> sendMessage({
    required String content,
  }) async {
    print("[ChatServerController] 메시지 전송 버튼을 눌렀습니다.");
    if (_selectedChatRoomIndex == null) {
      print("[ChatServerController] 선택된 채팅방이 없으므로 임시 채팅방을 생성합니다.");
      await generateTempChatRoom();
      print("[ChatServerController] 임시 채팅방 생성을 완료하였습니다.");
      print("[ChatServerController] 사용자 메시지를 데이터베이스에 저장합니다.");
      await saveMessage(content: content);
      print("[ChatServerController] 사용자 메시지를 데이터베이스에 저장하였습니다.");
      print("[ChatServerController] AI에게 답변 생성을 요청합니다.");
      await generateAIResponse();
      print("[ChatServerController] AI 답변 생성이 완료되었습니다.");
      print("[ChatServerController] 채팅방 제목 생성을 요청합니다.");
      await generateChatRoomName(content: content);
      print("[ChatServerController] 채팅방 제목 생성을 완료하였습니다.");
    } else if (_selectedChatRoomIndex != null ){
      print("[ChatServerController] 선택된 채팅방이 존재하므로 임시 채팅방 생성은 건너뜁니다.]");
      await saveMessage(content: content);
      print("[ChatServerController] 사용자 메시지를 데이터베이스에 저장하였습니다.");
      print("[ChatServerController] AI에게 답변 생성을 요청합니다.");
      await generateAIResponse();
      print("[ChatServerController] AI 답변 생성이 완료되었습니다.");
      print("[ChatServerController] 채팅방의 LastUpdated를 최신화 합니다.");
      await updatedChatRoomLastUpdated();
      print("[ChatServerController] 채팅방의 LastUpdated를 최신화 하였습니다.");
    }
  }
  
  // [임시 채팅방 생성]
  @override
  Future<void> generateTempChatRoom() async {
    final url = Uri.parse("$baseUrl/ChatRoom/GenerateTempChatRoom");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "userID": _secureStorageController.userID,
      })
    );
    if (response.statusCode == 200) {
      await fetchChatRoom();
      _selectedChatRoomIndex = 0;
      print(_chatRoomData[_selectedChatRoomIndex!]["room_id"] as String);
      notifyListeners();
    }
  }
  
  // [사용자 채팅 메시지 저장]
  @override
  Future<void> saveMessage({
    required String content,
  }) async {
    final selectedRoomID = _chatRoomData[_selectedChatRoomIndex!]["room_id"] as String;
    final url = Uri.parse("$baseUrl/ChatMessage/SaveMessage");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "roomID": selectedRoomID,
        "content": content,
      }),
    );
    if (response.statusCode == 200) {
      await fetchChatMessage();
      notifyListeners();
    }
  }

  // [AI 답변 생성 요청]
  @override
  Future<void> generateAIResponse() async {
    final selectedRoomID = _chatRoomData[_selectedChatRoomIndex!]["room_id"] as String;
    final url = Uri.parse("$baseUrl/ChatMessage/GenerateAIResponse");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "userID": _secureStorageController.userID,
        "roomID": selectedRoomID,
      }),
    );
    if (response.statusCode == 200) {
      await fetchChatMessage();
      notifyListeners();
    }
  }

  // [채팅방 제목 생성]
  @override
  Future<void> generateChatRoomName({
    required String content,
  }) async {
    final selectedRoomID = _chatRoomData[_selectedChatRoomIndex!]["room_id"] as String;
    print("[RoomID 값 확인] $selectedRoomID");
    final url = Uri.parse("$baseUrl/ChatRoom/GenerateChatRoomName");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "userID": _secureStorageController.userID,
        "roomID": selectedRoomID,
        "content": content,
      }),
    );
    if (response.statusCode == 200) {
      await fetchChatRoom();
      notifyListeners();
    }
  }

  // [채팅방 마지막 업데이트시간 최신화]
  @override
  Future<void> updatedChatRoomLastUpdated() async {
    final selectedRoomID = _chatRoomData[_selectedChatRoomIndex!]["room_id"] as String;
    final url = Uri.parse("$baseUrl/ChatRoom/UpdateChatRoomLastUpdated");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "roomID": selectedRoomID,
      }),
    );
    if (response.statusCode == 200) {
      await fetchChatRoom();
      _selectedChatRoomIndex = 0;
      notifyListeners();
    }
  }

  // [채팅메시지 데이터 & 채팅방 데이터 삭제]
  Future<void> deleteChatMessageAndChatRoom({
    required String roomID,
  }) async {
    print("[ChatServerController] 채팅메시지와 채팅방 데이터를 삭제합니다.");
    await deleteChatMessage(roomID: roomID);
    print("[ChatServerController] 채팅메시지를 삭제하였습니다.");
    await deleteChatRoom(roomID: roomID);
    print("[ChatServerController] 채팅방을 삭제하였습니다.");

  }
  
  // [채팅메시지 데이터 삭제]
  Future<void> deleteChatMessage({
    required String roomID,
  }) async {
    final url = Uri.parse("$baseUrl/ChatMessage/DeleteChatMessage");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "roomID": roomID,
      }),
    );
    if (response.statusCode == 200) {
      await fetchChatMessage();
      notifyListeners();
    }
  }

  // [채팅방 데이터 삭제]
  Future<void> deleteChatRoom({
    required String roomID,
  }) async {
    final url = Uri.parse("$baseUrl/ChatRoom/DeleteChatRoom");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "roomID": roomID,
      }),
    );
    if (response.statusCode == 200) {
      await fetchChatRoom();
      _selectedChatRoomIndex = null;
      notifyListeners();
    }
  }

  // 채팅방 이름 변경
  Future<void> renameChatRoom({
    required String roomID,
    required String rename,
  }) async {
    final url = Uri.parse("$baseUrl/ChatRoom/RenameChatRoom");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "roomID": roomID,
        "rename": rename,
      }),
    );
    if (response.statusCode == 200) {
      await fetchChatRoom();
      notifyListeners();
    }
  }

  // [채팅방 생성 버튼] [완료]
  @override
  void generateChatRoomButton() {
    _selectedChatRoomIndex = null;
    notifyListeners();
  }

  // [채팅방 선택 버튼] [완료]
  @override
  void selectChatRoomButton(int index) {
    if (_selectedChatRoomIndex != index) {
      _selectedChatRoomIndex = index;
      print("ChatServerController] _selectedChatRoomIndex : $_selectedChatRoomIndex");
    }
    fetchChatMessage();
    notifyListeners();
  }

  // 이름 변경 시작
  void startEditing(String roomID) {
    editingRoomId = roomID;
    notifyListeners();
  }

  void stopEditing() {
    editingRoomId = null;
    notifyListeners();
  }
}
