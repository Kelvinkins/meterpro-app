import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:meterpro/common/static.dart' as Static;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final _storage = const FlutterSecureStorage();
  IOSOptions _getIOSOptions() => IOSOptions();
  // final options = IOSOptions(accessibility: IOSAccessibility.first_unlock);

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
  void _onIntroEnd(context) {
    analytics.logTutorialComplete();

    _storage.write(
        key: "introduction",
        value: "shown",
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => SignInScreen()),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget _buildFullscreenImage() {
    return Image.asset(
      'assets/logo.png',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
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
    const bodyStyle = TextStyle(fontSize: 19.0, color: Colors.grey);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white70,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,

      globalBackgroundColor: Colors.white,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: Hero(
              tag: "logo",
              child: _buildImage('logo.png', 20),
            ),
          ),
        ),
      ),
      pages: [
        PageViewModel(
          title: "Welcome to meterpro",
          body:
              "Track your expenses with ease: Start tracking your expenses quickly and easily by uploading your bank sms alerts or manually adding transactions.",
          image: _buildImage('logo_desc.jpeg', 200),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Budget Watch",
          body:
              "Set up your budget: Set up your monthly budget and receive alerts when you are close to exceeding your limits",
          image: _buildImage('budget.json'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Categorize your expenses",
          body:
              "Categorize your expenses: Easily categorize your expenses into different categories to better understand your spending habits",
          image: _buildImage('categorize.json', 250),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Now sit back and analyze your spending",
          body:
              "Analyze your spending: Get detailed insights and visualizations of your spending habits to help you make better financial decisions",
          image: _buildImage('report.json', 250),
          decoration: pageDecoration,
        )
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback

      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,

      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('get started',
          style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}
