import 'package:chatgptclone/ServerController/Chat_Server_Controller.dart';
import 'package:chatgptclone/Page/MainPage/main_page_appbar.dart';
import 'package:chatgptclone/Page/MainPage/main_page_body.dart';
import 'package:chatgptclone/Page/MainPage/main_page_drawer.dart';
import 'package:chatgptclone/Util/MovePage/reflect.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  static final ROUTH = pageName<MainPage>();

  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final FocusNode _bodyFocusNode = FocusNode();
  double bottomPadding = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bodyFocusNode.addListener(_handleFocusChange);
    });
  }

  @override
  void dispose() {
    _bodyFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleFocusChange() {
    // FocusNode 상태 변화 시 필요한 동작 처리
    double newPadding = _bodyFocusNode.hasFocus ? 10 : 30;
    if (bottomPadding != newPadding) {
      bottomPadding = newPadding;
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MainPageAppBar(
        title: 'ChatGPT',
        bodyFocusNode: _bodyFocusNode,
      ),
      drawer: MainPageDrawer(
        bodyFocusNode: _bodyFocusNode,
      ),
      body: MainPageBody(
        bodyFocusNode: _bodyFocusNode,
        bottomPadding: bottomPadding,
      ),
    );
  }
}
