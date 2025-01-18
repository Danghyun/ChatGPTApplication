import 'package:chatgptclone/SecureStorageController/secure_storage_controller.dart';
import 'package:chatgptclone/Page/MainPage/main_page.dart';
import 'package:chatgptclone/ServerController/User_Server_Controller.dart';
import 'package:chatgptclone/Util/MovePage/reflect.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class APIKeyRegisterPage extends StatefulWidget {
  static final ROUTH = pageName<APIKeyRegisterPage>();

  const APIKeyRegisterPage({super.key});

  @override
  State<APIKeyRegisterPage> createState() => _APIKeyRegisterPageState();
}

class _APIKeyRegisterPageState extends State<APIKeyRegisterPage> {
  final SecureStorageController _secureStorageController = SecureStorageController();
  final UserServerController _userController = UserServerController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Enter API Key and UserName"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 텍스트
            const Text(
              'Please enter your API Key and UserName:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),

            // UserName 입력 필드
            const SizedBox(height: 16),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: "User Name",
                border: OutlineInputBorder()
              ),
            ),

            // API Key 입력 필드
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
            ),

            // 등록버튼
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final userName = _userNameController.text.trim();
                final apiKey = _apiKeyController.text.trim();
                if (apiKey.isNotEmpty) {
                  // API 키를 Storage에 저장
                  await _secureStorageController.saveUserInfo(
                    userName: userName,
                    apiKey: apiKey,
                  );
                  // 서버에 API 키를 저장
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    final userID = _secureStorageController.userID;
                    await _userController.saveUserInfo(
                      userID: userID!,
                      userName: userName,
                      apiKey: apiKey,
                    );
                  });
                  // 메인 페이지로 이동.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        MainPage.ROUTH,
                        (route) => false,
                      );
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('API Key cannot be empty!'),
                    ),
                  );
                }
              },
              child: const Text('Save API Key'),
            ),
          ],
        ),
      ),

    );
  }
}
