import 'dart:convert';
import 'package:http/http.dart' as http;

import 'Initialize_Server_Contrller.dart';

abstract class AbstractUserController {
  Future<void> saveUserInfo({
    required String userID,
    required String userName,
    required String apiKey,
  });

  Future<void> deleteUserInfo({
    required String userName,
    required String apiKey,
  });
}

class UserServerController extends AbstractUserController {
  // API 키 등록
  @override
  Future<void> saveUserInfo({
    required String userID,
    required String userName,
    required String apiKey,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/User/register");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "userID" : userID,
          "username": userName,
          "apiKey": apiKey,
        }),
      );
    } catch (e) {
      print("[User_Server_Controller.dart] [saveUserInfo] 오류가 발생했습니다. $e}");
    }
  }

  // API 키 삭제
  @override
  Future<void> deleteUserInfo({
    required String userName,
    required String apiKey,
  }) async {
    try {

      final url = Uri.parse("$baseUrl/User/delete");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "username": userName,
          "apiKey": apiKey,
        }),
      );

    } catch (e) {

    }
  }


}
