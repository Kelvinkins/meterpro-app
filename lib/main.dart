import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/screens/auth_screen.dart';
import 'package:meterpro/services/authentication_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'screens/MainScreen.dart';
import 'package:meterpro/common/static.dart' as Static;
import 'package:firebase_auth/firebase_auth.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // iOS requires you run in release mode to test dynamic links ("flutter run --release").
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final _storage = const FlutterSecureStorage();
  AuthenticationService authenticationService = AuthenticationService();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );
    IOSOptions _getIOSOptions() => const IOSOptions();
    // final options = IOSOptions(accessibility: IOSAccessibility.first_unlock);

    AndroidOptions _getAndroidOptions() => const AndroidOptions(
          encryptedSharedPreferences: true,
        );

    Widget home() {
      analytics.logAppOpen();
      if (FirebaseAuth.instance.currentUser == null) {
        return FutureBuilder(
            builder: (context, firstSnapshot) {
              if (firstSnapshot.hasError) {
                return Scaffold(
                  body:  Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("There seem to be an error"),
                      Spinners.spinkitThreeBounceBlue
                    ],
                  )),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerFloat,
                  floatingActionButton: FloatingActionButton(
                    backgroundColor: Colors.white,
                    foregroundColor: Static.PrimaryColor,
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Icon(Icons.restart_alt),
                  ),
                );
              }
              if (firstSnapshot.hasData) {
                return const MainScreen();
              } else {
                return FutureBuilder(
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return  Scaffold(
                          body: Center(child: Spinners.spinkitFadingCircle),
                        );
                      }
                      if (snapshot.hasData &&
                          snapshot.data.toString() == "shown") {
                        return const SignInScreen();
                      } else {
                        return const SignInScreen();
                      }
                    },
                    future: _storage.read(
                        key: "introduction",
                        iOptions: _getIOSOptions(),
                        aOptions: _getAndroidOptions()));
              }
            },
            future: _storage.read(
                key: "refresh_token",
                iOptions: _getIOSOptions(),
                aOptions: _getAndroidOptions()));
      } else {
        return FutureBuilder(
            builder: (context, firstSnapshot) {
              if (firstSnapshot.hasError) {
                return Scaffold(
                  body:  Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("There seem to be an error"),
                      Spinners.spinkitFadingCircle
                    ],
                  )),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerFloat,
                  floatingActionButton: FloatingActionButton(
                    backgroundColor: Colors.white,
                    foregroundColor: Static.PrimaryColor,
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Icon(Icons.restart_alt),
                  ),
                );
              }
              if (firstSnapshot.hasData) {
                analytics.logEvent(name: "GoogleRefreshToken");
                return const MainScreen();
              } else {
                return FutureBuilder(
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data.toString() == "shown") {
                        return const SignInScreen();
                      } else {
                        return const SignInScreen();
                      }
                    },
                    future: _storage.read(
                        key: "introduction",
                        iOptions: _getIOSOptions(),
                        aOptions: _getAndroidOptions()));
              }
            },
            future: FirebaseAuth.instance.currentUser?.getIdToken(true));
      }
    }

    return MaterialApp(
      title: 'meterpro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue, primaryColor: Static.PrimaryColor),
      home: home(),
    );
  }
}
