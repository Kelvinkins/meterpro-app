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

class ReportService with ChangeNotifier {
  PublishSubject loading = PublishSubject();

  Future<List<dynamic>> transactionQuery(
      BuildContext context, String keyword) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/transactions/transactionQuery', {"keyword": keyword});

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

  Future<List<dynamic>> transactionSummaryGroupedByCategory(
      BuildContext context, DateTime? dateTime) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Statistics/GroupByCategory');

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

  Future<List<dynamic>> transactionSummaryGroupedByMonth(
      BuildContext context, int? year) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Statistics/GroupByMonth', {"year": year.toString()});

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

  Future<List<dynamic>> transactionSummaryGroupedByPlatform(
      BuildContext context) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Statistics/GroupByPlatform');

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

  Future<List<dynamic>> transactionSummaryGroupedByTransactionType(
      BuildContext context) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Statistics/GroupByTransactionType');

      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ));
      }
      var resJson = json.decode(response.body);
      print(resJson);
      return resJson;
    } catch (err) {
      return [];
    }
  }
}
