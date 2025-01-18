import 'package:flutter/material.dart';

extension StateExtension<W extends StatefulWidget> on State<W> {

  void navigatorTo(String to) {
    if(!mounted) {
      return;
    }

    final navigator = Navigator.of(context);

    navigator.pushNamed(to);
  }
}