import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as httpo;
import 'package:http/io_client.dart';
import 'package:rxdart/rxdart.dart';

import '../common/base_addresses.dart';
import '../common/global.dart';
import '../screens/auth_screen.dart';
import 'package:flutter/material.dart';

class NotificationService with ChangeNotifier {
  PublishSubject loading = PublishSubject();

  Future<List<dynamic>> getNotifications(BuildContext context) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/notifications/GetMyNotifications');

      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ));
      }
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      return [];
    }
  }

  Future<dynamic> opened(BuildContext context, String notificationID) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/notifications/OpenedAsync', {"notificationID": notificationID});

      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ));
      }
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      return null;
    }
  }
}
