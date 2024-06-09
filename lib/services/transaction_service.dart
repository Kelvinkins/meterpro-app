import 'dart:convert';
import 'dart:io';
import 'package:meterpro/screens/MainScreen.dart';
import 'package:meterpro/services/authentication_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as httpo;
import 'package:http/io_client.dart';
import 'package:rxdart/rxdart.dart';

import '../common/base_addresses.dart';
import '../common/global.dart';
import '../screens/auth_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class TransactoinService with ChangeNotifier {
  PublishSubject loading = PublishSubject();

  AuthenticationService authenticationService = AuthenticationService();

  Future<void> revalidateToken(BuildContext context) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    var data = {
      "grant_type": "refresh_token",
      "refresh_token": Global.refreshToken,
      "platform": "meterproApp",
      "fcmToken": fcmToken
    };
    Global.user = await authenticationService.refreshToken(data);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const MainScreen(),
    ));
  }

  Future<dynamic> getStatistics(BuildContext context, DateTime dateTime) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      // var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
      //     '/api/Statistics/Dashboard', {"dateTime": "2023-04-20"});

      var url = Uri.https(
          BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Statistics/Dashboard',
          {"dateTime": "${dateTime.year}-${dateTime.month}-${dateTime.day}"});

      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        authenticationService.logout(context);
      }
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      return null;
    }
  }

  Future<List<dynamic>> getMeters(BuildContext context, String owner) async {
    loading.add(true);
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Meters/GetMyMeters', {"owner": owner});

      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      loading.add(false);
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      loading.add(false);
      return [];
    }
  }

  Future<List<dynamic>> getMetersByGroupID(
      BuildContext context, String groupID) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Meters/GetMetersByGroupID', {"groupID": groupID});

      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      return [];
    }
  }

  Future<List<dynamic>> getGroups(BuildContext context, String admin) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Groups/GetMeterGroupsByAdmin', {"admin": admin});

      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      return [];
    }
  }

  Future<List<dynamic>> subscriptionStatistics(
      BuildContext context, String owner) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Subscriptions/SubscriptionStatistics', {"owner": owner});

      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      return [];
    }
  }

  Future<dynamic> getBalanceData(BuildContext context, String meterSn) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Subscriptions/GetBalanceData', {"meterSn": meterSn});

      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      return null;
    }
  } Future<dynamic> getSessionStatistics(BuildContext context, String meterSn) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Reports/GetSessionStatistics', {"meterSn": meterSn});

      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      return null;
    }
  }

  Future<dynamic> getAggregateBalanceData(
      BuildContext context, String owner) async {
    loading.add(true);
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Subscriptions/GetAggregateBalance', {"owner": owner});

      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      loading.add(false);
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      loading.add(false);
      return null;
    }
  }

  Future<dynamic> getAITip(BuildContext context) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION, '/api/bot/tip');

      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      return null;
    }
  }



  Future<List<dynamic>> getCategories(BuildContext context) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(
          BaseAddress.BASE_ADDRESS_PRODUCTION, '/api/Categories/List');
      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      return [];
    }
  }

  Future<List<dynamic>> getSubscriptionHistory(
      BuildContext context, String meterSn) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Subscriptions/SubscriptionHistory', {'meterSn': meterSn});
      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      return [];
    }
  }

  Future<List<dynamic>> GetSubscriptionRequestByGroupAdmin(
      BuildContext context, String groupID) async {
    loading.add(true);
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(
          BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Subscriptions/GetSubscriptionRequestByGroupAdmin',
          {'groupID': groupID});
      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      loading.add(false);
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      loading.add(false);

      return [];
    }
  }

  Future<List<dynamic>> getVendingHistoryByMeterSn(
      BuildContext context, String meterSn) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Vendings/GetVendingHistoryByMeterSn', {'meterSn': meterSn});
      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      return [];
    }
  }

  Future<List<dynamic>> getVendingHistoryByGroup(
      BuildContext context, String groupID) async {
    loading.add(true);
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Vendings/GetVendingHistoryByGroupID', {'groupID': groupID});
      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      loading.add(false);
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      loading.add(false);
      return [];
    }
  }

  Future<List<dynamic>> getMyNotifications(
      BuildContext context, String userId) async {
    loading.add(true);

    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Notifications/GetMyNotifications', {'userId': userId});
      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      loading.add(false);

      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      loading.add(false);

      return [];
    }
  }
 Future<List<dynamic>> getLast7DaysUsage(
      BuildContext context, int days,String email) async {
    loading.add(true);

    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Reports/UtilityExxpensesByOwner', {'lastNumberDays': days.toString(),"owner":email});
      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      loading.add(false);

      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      loading.add(false);

      return [];
    }
  }

  Future<dynamic> opened(BuildContext context, String aiTipID) async {
    try {
      Map<String, String> headers = {
        "Content-type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/bot/OpenedAsync', {"aiTipID": aiTipID});

      final response = await httpo.get(url, headers: headers);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      return resJson;
    } catch (err) {
      return null;
    }
  }

  Future<dynamic> uploadAsync(BuildContext context, dynamic data) async {
    loading.add(true);
    try {
      String body = jsonEncode(data);
      Map<String, String> headers = {
        "Content-type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer  ${Global.user["idToken"]}'
      };
      var url = Uri.https(
          BaseAddress.BASE_ADDRESS_PRODUCTION, '/api/Processors/upload');
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      loading.add(false);

      return resJson;
    } catch (err) {
      loading.add(false);

      return null;
    }
  }

  Future<dynamic> postMeterCommand(BuildContext context, dynamic data) async {
    loading.add(true);
    try {
      String body = jsonEncode(data);
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer  ${Global.user["idToken"]}'
      };
      var url = Uri.https(
          BaseAddress.BASE_ADDRESS_PRODUCTION, '/api/Commands/FireV2');
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      loading.add(false);

      return resJson;
    } catch (err) {
      loading.add(false);

      return null;
    }
  }

  Future<dynamic> activateSubscriptionRequest(
      BuildContext context, dynamic data) async {
    loading.add(true);
    try {
      String body = jsonEncode(data);
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer  ${Global.user["idToken"]}'
      };
      var url = Uri.https(
          BaseAddress.BASE_ADDRESS_PRODUCTION, '/api/Subscriptions/Approve');
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      loading.add(false);

      return resJson;
    } catch (err) {
      loading.add(false);

      return null;
    }
  }

  Future<dynamic> initiateSubscriptionRequest(
      BuildContext context, dynamic data) async {
    loading.add(true);
    try {
      String body = jsonEncode(data);
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer  ${Global.user["idToken"]}'
      };
      var url = Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION,
          '/api/Subscriptions/initiateSubscription');
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      loading.add(false);

      return resJson;
    } catch (err) {
      loading.add(false);

      return null;
    }
  }

  Future<dynamic> claimMeter(BuildContext context, dynamic data) async {
    loading.add(true);
    try {
      String body = jsonEncode(data);
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer  ${Global.user["idToken"]}'
      };
      var url = Uri.https(
          BaseAddress.BASE_ADDRESS_PRODUCTION, '/api/Meters/ClaimOwnership');
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      loading.add(false);

      return resJson;
    } catch (err) {
      loading.add(false);

      return null;
    }
  }

  Future<dynamic> updateDeviceID(BuildContext context, dynamic data) async {
    loading.add(true);
    try {
      String body = jsonEncode(data);
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer  ${Global.user["idToken"]}'
      };
      var url = Uri.https(
          BaseAddress.BASE_ADDRESS_PRODUCTION, '/api/Meters/UpdateDeviceID');
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      loading.add(false);

      return resJson;
    } catch (err) {
      loading.add(false);

      return null;
    }
  }

  Future<dynamic> addMeterToGroup(BuildContext context, dynamic data) async {
    loading.add(true);
    try {
      String body = jsonEncode(data);
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer  ${Global.user["idToken"]}'
      };
      var url = Uri.https(
          BaseAddress.BASE_ADDRESS_PRODUCTION, '/api/Meters/AddToGroup');
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      loading.add(false);

      return resJson;
    } catch (err) {
      loading.add(false);

      return null;
    }
  }

  Future<dynamic> createGroup(BuildContext context, dynamic data) async {
    loading.add(true);
    try {
      String body = jsonEncode(data);
      Map<String, String> headers = {
        "Content-type": "application/json",
        // HttpHeaders.authorizationHeader: 'Bearer  ${Global.user["idToken"]}'
      };
      var url =
          Uri.https(BaseAddress.BASE_ADDRESS_PRODUCTION, '/api/Groups/Add');
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 401) {
        await revalidateToken(context);
      }
      var resJson = json.decode(response.body);
      loading.add(false);

      return resJson;
    } catch (err) {
      loading.add(false);

      return null;
    }
  }
}
