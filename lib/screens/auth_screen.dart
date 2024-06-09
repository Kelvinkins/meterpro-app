import 'package:meterpro/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../common/global.dart';
import 'MainScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meterpro/common/static.dart' as Static;
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreen createState() => _SignInScreen();
}

class _SignInScreen extends State<SignInScreen> {
  Duration get loginTime => const Duration(milliseconds: 2250);
  final _storage = const FlutterSecureStorage();
  TextEditingController txtFirstName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  TextEditingController txtPhoneNumber = TextEditingController();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
AuthenticationService authenticationService=AuthenticationService();
  @override
  void initState() {
    super.initState();
  }

  final AuthenticationService _authenticationService = AuthenticationService();

  IOSOptions _getIOSOptions() => const IOSOptions();

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  Future<String?> login(LoginData data) async {
    return _authenticationService.signInWithEmailAndPassword(data.name.toString(),data.password.toString()).then((dynamic result) async {
      if (result == null) {
        return 'Error signing in, please check your network';
      }

      analytics.logLogin(loginMethod: "EmailAndPassword");
      return null;
    });
  }

  Future<String?> register(SignupData data) async {
    return _authenticationService.registerWithEmailAndPassword(data.name.toString(),data.password.toString()).then((dynamic result) async {
      if (result == null) {
        return "Error signing up, please try again";
      }
      analytics.logSignUp(signUpMethod: "EmailAndPassword");
      var user= await authenticationService.resendActivationLink();
      if(user!=null){
        final snackBar = SnackBar(
          backgroundColor:   Colors.green,
          content: const Text("A verification link has been sent to your email"),
          action: SnackBarAction(
            textColor: Colors.white,
            label: 'Dismiss',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBar);
      }
      return null;
    });
  }

  Future<String?> googleSignIn() async {
    Global.user = null;
    Global.refreshToken = "";
    Global.user = [];
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (err) {}
    var model;
    try {} catch (err) {
      dynamic message = "Error has occured";
      return message;
    }
    return _authenticationService
        .signInWithGoogle(context: context)
        .then((User? result) async {
      if (result == null) {
        return "Error signing up, please try again";
      }

      model = {
        "userID": "TestID",
        "displayName": "Test User",
        "phoneNumber": "08051155488",
        "email": result.email,
        "platform": "meterproApp",
        "fcmToken": fcmToken,
        "isPremiumUser": true
      };
      try {
        Global.user = model;
        // await _authenticationService.googleRegister(model);
        Global.user["idToken"] = await result.getIdToken(true);

        // if (Global.user["isPremiumUser"] == null) {
        //   Global.user["isPremiumUser"] = false;
        // }
      } catch (err) {
        return err.toString();
      }
      analytics.logSignUp(signUpMethod: "Google SignIn/SignUp");
      return null;
    });
  }

  Future<String?> _recoverPassword(String? email) {

    return _authenticationService
        .resetPassword(email.toString())
        .then((dynamic result) async {
      if (result == null) {
        return "Error, please try again";
      }
      analytics.logEvent(name: "PasswordReset");
      return null;
    });
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    if (assetName.contains("json")) {
      return Lottie.asset('assets/$assetName', width: width);
    } else {
      return Image.asset('assets/$assetName', width: width);
    }
  }

  @override
  Widget build(BuildContext context) {
    ProgressDialog pr = ProgressDialog(context: context);

    return Scaffold(
      // appBar: AppBar(
      //   // centerTitle: true,
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   leading: _buildImage("logo.png", 30),
      // ),
      body: FlutterLogin(
        footer: "meterpromax, Alright reserved",
        userType: LoginUserType.email,
        title: 'MeterPromax',
        userValidator: (value) {
          return FlutterLogin.defaultEmailValidator(value!.trim());
        },

        loginProviders: <LoginProvider>[
          LoginProvider(
            button: Buttons.google,
            icon: FontAwesomeIcons.google,
            animated: true,
            label: 'Google',
            callback: () async {
              return googleSignIn();
            },
          ),
          // LoginProvider(
          //   icon: FontAwesomeIcons.facebookF,
          //   label: 'Facebook',
          //   callback: () async {
          //     debugPrint('start facebook sign in');
          //     await Future.delayed(loginTime);
          //     debugPrint('stop facebook sign in');
          //     return null;
          //   },
          // ),
        ],

        theme: LoginTheme(
            bodyStyle: TextStyle(color: Static.PrimaryColor),
            primaryColor: Colors.white70,
            buttonTheme: const LoginButtonTheme(
                backgroundColor: Static.PrimaryColor,
                highlightColor: Colors.white70),
            footerTextStyle: const TextStyle(color: Colors.grey),
            cardTheme: const CardTheme(color: Colors.white70, elevation: 0),
            textFieldStyle: const TextStyle(color: Static.PrimaryColor),
            errorColor: Colors.red,
            accentColor: Colors.white70,
            titleStyle: const TextStyle(
                color: Static.PrimaryColor,
                fontSize: 30,
                fontWeight: FontWeight.bold),
            switchAuthTextColor: Static.PrimaryColor,
            buttonStyle: const TextStyle(color: Colors.white)),
        // additionalSignupFields: [
        //   const UserFormField(
        //       keyName: 'full_name',
        //       displayName: 'Full Name',
        //       icon: Icon(FontAwesomeIcons.userLarge)),
        //   UserFormField(
        //     keyName: 'phone_number',
        //     displayName: 'Phone Number',
        //     userType: LoginUserType.phone,
        //     fieldValidator: (value) {
        //       var phoneRegExp = RegExp(
        //           '^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}\$');
        //       if (value != null &&
        //           value.length < 7 &&
        //           !phoneRegExp.hasMatch(value)) {
        //         return "This isn't a valid phone number";
        //       }
        //       return null;
        //     },
        //   ),
        // ],

        messages: LoginMessages(
            userHint: 'Email',
            passwordHint: 'Password',
            confirmPasswordHint: 'Confirm',
            loginButton: 'LOGIN',
            signupButton: 'REGISTER',
            forgotPasswordButton: 'Forgot password?',
            recoverPasswordButton: 'RECOVER',
            goBackButton: 'GO BACK',
            confirmPasswordError: 'Mismatched password!',
            recoverPasswordDescription:
                'meterpro will send a password recovery link to this email address',
            recoverPasswordSuccess:
                "Please check your emaail and follow the instructions there in"),
        // logoTag: "logo",
        // logo: const AssetImage('assets/logo_desc.jpeg'),
        onLogin: login,
        onSignup: register,
        onSubmitAnimationCompleted: () async {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ));
        },
        onRecoverPassword: (_recoverPassword),
      ),
    );
  }
}
