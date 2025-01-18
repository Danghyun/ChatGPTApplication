import 'package:flutter/material.dart';

class MainPageAppBar extends StatefulWidget implements PreferredSizeWidget{
  final String title;
  final FocusNode bodyFocusNode;

  const MainPageAppBar({super.key, required this.title, required this.bodyFocusNode});

  @override
  State<MainPageAppBar> createState() => _MainPageAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MainPageAppBarState extends State<MainPageAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Text(widget.title),
      centerTitle: true,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              widget.bodyFocusNode.unfocus();
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
    );
  }
}
