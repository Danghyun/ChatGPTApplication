import 'package:chatgptclone/SecureStorageController/secure_storage_controller.dart';
import 'package:chatgptclone/Page/APIPage/api_key_register_page.dart';
import 'package:chatgptclone/ServerController/Chat_Server_Controller.dart';
import 'package:chatgptclone/ServerController/User_Server_Controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPageDrawer extends StatefulWidget {
  final FocusNode bodyFocusNode;

  const MainPageDrawer({super.key, required this.bodyFocusNode});

  @override
  State<MainPageDrawer> createState() => _MainPageDrawerState();
}

class _MainPageDrawerState extends State<MainPageDrawer> {
  final SecureStorageController _secureStorageController =
  SecureStorageController();
  final ChatServerController _chatServerController = ChatServerController();
  final UserServerController _userServerController = UserServerController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.bodyFocusNode.unfocus();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isFocused ? screenWidth : 320,
      child: Drawer(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //검색창
              _searchBar(
                context: context,
              ),

              // 구분선
              const Divider(color: Colors.grey, thickness: 0.3),

              // "채팅" 문구
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text("채팅"),
              ),

              // 채팅 내역
              _chatHistory(
                context: context,
              ),

              // 사용자 프로필
              _userProfile(
                name: _secureStorageController.userName!,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 검색창
  Widget _searchBar({
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Row(
        children: [
          // 검색창
          Expanded(
            child: SizedBox(
              height: 35,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey[300],
                  hintText: '검색',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                onTap: () {},
              ),
            ),
          ),
          // 취소 버튼
          if (_isFocused)
            TextButton(
              onPressed: () {
                _focusNode.unfocus();
              },
              child: const Text(
                "취소",
              ),
            ),

          // 새로운 글 작성 버튼
          Padding(
            padding: const EdgeInsets.only(left: 0),
            child: IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {
                // TODO [새로운 채팅방 생성]
                _chatServerController.generateChatRoomButton();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 채팅 기록
  Widget _chatHistory({
    required BuildContext context,
  }) {
    final chatController = Provider.of<ChatServerController>(context);
    if (_chatServerController.chatRoomData.isEmpty) {
      return const Expanded(child: Center(child: Text("값이 비어있습니다.")));
    }
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _chatServerController.chatRoomData.length,
        itemBuilder: (context, index) {
          final room = _chatServerController.chatRoomData[index];
          final isSelected = _chatServerController.selectedChatRoomIndex == index;
          final isEditing = _chatServerController.editingRoomId == room['room_id'];

          if (isEditing) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                autofocus: true,
                controller: TextEditingController(text: room['room_name']),
                decoration: const InputDecoration(
                  hintText: "채팅방 이름 입력",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (newName) async {
                  await _chatServerController.renameChatRoom(
                    roomID: room['room_id'],
                    rename: newName,
                  );
                  _chatServerController.stopEditing();
                },
                onEditingComplete: () {
                  _chatServerController.stopEditing();
                },
              ),
            );
          }
          return ListTile(
            style: ListTileStyle.drawer,
            contentPadding: const EdgeInsets.only(left: 10),
            title: Text(_chatServerController.chatRoomData[index]['room_name'] ?? ""),
            selected: isSelected,
            selectedTileColor: Colors.grey.withOpacity(0.1),
            // 한번 클릭하였을 때
            onTap: () {
              _chatServerController.selectChatRoomButton(index);
              Navigator.pop(context);
            },
            // 꾹 눌렀을 때
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return _buildBottomSheet(
                    context: context,
                    index: index,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ChatHistory 꾹 눌렀을 때 뜨는 Sheet
  Widget _buildBottomSheet({
    required BuildContext context,
    required int index,
  }) {
    final roomID = _chatServerController.chatRoomData[index]['room_id'];
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("이름 바꾸기"),
            onTap: () {
              // 채팅방 이름 변경 InputField
              Navigator.pop(context);
              _chatServerController.startEditing(roomID);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("삭제"),
            onTap: () async {
              // 채팅메시지와 채팅방 삭제
              await _chatServerController.deleteChatMessageAndChatRoom(roomID: roomID);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _userProfile({
    required String name,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text("API 키 삭제"),
                      onTap: () async {
                        //TODO [서버에서 User 정보 삭제]
                        await _userServerController.deleteUserInfo(
                          userName: _secureStorageController.userName!,
                          apiKey: _secureStorageController.apiKey!,
                        );
                        //TODO []
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          await _secureStorageController.deleteUserInfo();
                        });
                        WidgetsBinding.instance.addPostFrameCallback(
                              (_) {
                            if (mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                APIKeyRegisterPage.ROUTH,
                                    (route) => false,
                              );
                            }
                          },
                        );
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 30))
                  ],
                );
              },
            );
          },
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: const TextStyle(color: Colors.black),
                  )
                ],
              ),
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 20)),
      ],
    );
  }
}