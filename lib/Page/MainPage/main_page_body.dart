import 'package:chatgptclone/ServerController/Chat_Server_Controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPageBody extends StatefulWidget {
  final FocusNode bodyFocusNode;
  final double bottomPadding;

  const MainPageBody(
      {super.key, required this.bodyFocusNode, required this.bottomPadding});

  @override
  State<MainPageBody> createState() => _MainPageBodyState();
}

class _MainPageBodyState extends State<MainPageBody> {
  final TextEditingController _messageController = TextEditingController();
  final ChatServerController _chatServerController = ChatServerController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final chatServerController = Provider.of<ChatServerController>(context);
    final selectedChatIndex = _chatServerController.selectedChatRoomIndex;
    final selectedChat = selectedChatIndex != null
        ? _chatServerController.chatRoomData[selectedChatIndex]
        : null;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          Expanded(
            child: selectedChat == null
                ? const Center(child: Text('채팅을 선택하거나 새 메시지를 입력하세요.'))
                : chatServerController.chatMessageData.isEmpty
                    ? const Center(child: Text('채팅을 선택하거나 새 메시지를 입력하세요.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _chatServerController.chatMessageData.length,
                        itemBuilder: (context, index) {
                          final message =
                              _chatServerController.chatMessageData[index];
                          return _chatBubble(
                            isUser: message['senderType'] == "User",
                            message: message['content'],
                          );
                        },
                      ),
          ),
          AnimatedPadding(
            padding: EdgeInsets.only(bottom: widget.bottomPadding),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: _inputField(context: context),
          ),
        ],
      ),
    );
  }

  Widget _chatBubble({
    required bool isUser,
    required String message,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 12 : 0),
            topRight: Radius.circular(isUser ? 0 : 12),
            bottomLeft: const Radius.circular(12),
            bottomRight: const Radius.circular(12),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: isUser ? Colors.black87 : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required BuildContext context,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: widget.bodyFocusNode,
              decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, size: 20),
                    onPressed: () {
                      final content = _messageController.text.trim();
                      if (content.isNotEmpty) {
                        _chatServerController.sendMessage(content: content);
                        _messageController.clear();
                      }
                    },
                  ),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
