import 'package:chatgptclone/Page/APIPage/api_key_register_page.dart';
import 'package:chatgptclone/Page/MainPage/main_page.dart';
import 'package:chatgptclone/ServerController/Chat_Server_Controller.dart';
import 'package:chatgptclone/Service/InitializeService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  print("[main.dart] 애플리케이션 실행을 시작합니다.");
  WidgetsFlutterBinding.ensureInitialized();

  // 세로 방향 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ChatServerController(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final InitializeService _initializeService = InitializeService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeService.fetchInitialData(),
      builder: (context, snapshot) {
        // UserInfo를 가져오는 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            color: Colors.white,
            home: Center(child: CircularProgressIndicator()),
          );
        }
        // UserInfo를 모두 가져온 후
        if (snapshot.connectionState == ConnectionState.done) {
          print("[main.dart] User 정보 존재 유뮤: ${_initializeService.existingUserData}");
          return MaterialApp(
            title: 'ChatGPT Clone',
            // home: (_initializeDataload.existingUserData!) ? const MainPage() : const APIKeyRegisterPage(),
            home: (_initializeService.existingUserData)
            ? (() {
              print("[main.dart] User 정보가 존재하므로 MainPage로 이동합니다.");
              return const MainPage();
            })()
            : (() {
              print("[main.dart] User 정보가 존재하지 않으므로 APIKey 등록 페이지로 이동합니다.");
              return const APIKeyRegisterPage();
            })(),
            routes: {
              MainPage.ROUTH: (context) => const MainPage(),
              APIKeyRegisterPage.ROUTH: (context) => const APIKeyRegisterPage(),
            },
          );
        } else {
          return MaterialApp(
            home: Center(child: Text("${snapshot.error}")),
          );
        }
      },
    );
  }
}
