import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as httpo;
import 'package:http/io_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../common/base_addresses.dart';
import '../common/global.dart';
import '../screens/auth_screen.dart';

class AuthenticationService with ChangeNotifier {
  PublishSubject loading = PublishSubject();
  final _storage = const FlutterSecureStorage();

  IOSOptions _getIOSOptions() => const IOSOptions();

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  Future<dynamic> login(dynamic data) async {
    try {
      String body = jsonEncode(data);
      Map<String, String> headers = {
        "Content-type": "application/json",
      };
      var url = Uri.https(
          BaseAddress.BASE_ADDRESS_PRODUCTION, '/api/passports/Login');
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final response = await http.post(url, headers: headers, body: body);
      var resJson = json.decode(response.body);

      return resJson;
    } catch (err) {
      return null;
    }
  }
  Future<dynamic> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User registered: ${userCredential.user!.email}');
      return userCredential;
    } catch (e) {
      print('Failed to register user: $e');
      return null;
    }
  }

// Function to login with email and password
  Future<dynamic> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User logged in: ${userCredential.user!.email}');
 return userCredential;
     } catch (e) {
      print('Failed to login: $e');
      return null;
    }
  }
  Future<void> logout(BuildContext context) async {
    var auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      await auth.signOut();
    }
  }

  Future<dynamic> refreshToken(dynamic data) async {
    try {
      String body = jsonEncode(data);
      Map<String, String> headers = {
        "Content-type": "application/json",
      };
      var url = Uri.https(
          BaseAddress.BASE_ADDRESS_PRODUCTION, '/api/passports/RefreshToken');
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final response = await http.post(url, headers: headers, body: body);
      var resJson = json.decode(response.body);

      return resJson;
    } catch (err) {
      return null;
    }
  }

  Future<dynamic> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return {'email':email};
    } catch (e) {
      print('Failed to login: $e');
      return null;
    }
  }

  Future<dynamic> resendActivationLink() async {
    try {
      var user=FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      return user;
    } catch (e) {
      print('Failed to login: $e');
      return null;
    }
  }

  Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
        } else if (e.code == 'invalid-credential') {
          // handle the error here
        }
      } catch (e) {
        // handle the error here
      }
    }

    return user;
  }

  Future<dynamic> googleRegister(dynamic data) async {
    try {
      String body = jsonEncode(data);
      Map<String, String> headers = {
        "Content-type": "application/json",
      };
      var url = Uri.https(
          BaseAddress.BASE_ADDRESS_PRODUCTION, '/api/passports/GoogleSignIn');
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final response = await http.post(url, headers: headers, body: body);
      var resJson = json.decode(response.body);

      return resJson;
    } catch (err) {
      return null;
    }
  }
}
