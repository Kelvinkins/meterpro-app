import 'dart:io';
import 'dart:ui';

import 'package:meterpro/common/global.dart';
import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/screens/group_screen.dart';
import 'package:meterpro/screens/notification_screen.dart';
import 'package:meterpro/screens/reportMenu_screen.dart';
import 'package:meterpro/screens/settings_screen.dart';
import 'package:meterpro/screens/my_meter_screen.dart';
import 'package:meterpro/screens/unverified_email.dart';
import 'package:meterpro/services/transaction_service.dart';
import 'package:meterpro/widgets/overview.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';
import 'package:meterpro/common/static.dart' as Static;
import 'package:firebase_analytics/firebase_analytics.dart';
 import 'package:badges/badges.dart' as badges;
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:sidebarx/sidebarx.dart';
import '../services/notification_service.dart';
import 'notification_details.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'dart:isolate';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const _insets = 16.0;
   final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();
  bool _isLoaded = false;
   late Orientation _currentOrientation;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  double get _adWidth => MediaQuery.of(context).size.width - (2 * _insets);
  List<NotificationEvent> _log = [];
  bool? started = false;
  bool _loading = false;

  ReceivePort port = ReceivePort();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentOrientation = MediaQuery.of(context).orientation;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.currentUser?.reload();

    getNotificationPermmission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

   }
  Future<void> getNotificationPermmission() async {
    var status=await messaging.getNotificationSettings();
    if(status.authorizationStatus!=AuthorizationStatus.authorized) {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      print('User granted permission: ${settings.authorizationStatus}');

    }}
  void dispose() {
    super.dispose();
   }

  DateTime today = DateTime.now();
  double totalBalance = 0;
  double totalIncome = 0;
  double totalExpense = 0;

  List<FlSpot> debitDataSet = [];
  List<FlSpot> creditDataSet = [];
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  NotificationService notificationService = NotificationService();

  List<FlSpot> getDebitPlotPoints(dynamic entireData) {
    entireData["monthTransactions"].forEach((dynamic value) {
      if (value['transactionType'] == 1) {
        debitDataSet.add(
          FlSpot((DateTime.parse(value['transactionDate'])).day.toDouble(),
              (value['amount'] as double).toDouble()),
        );
      }
    });
    return debitDataSet;
  }

  List<FlSpot> getCreditPlotPoints(dynamic entireData) {
    entireData["monthTransactions"].forEach((dynamic value) {
      if (value['transactionType'] == 2) {
        creditDataSet.add(
          FlSpot((DateTime.parse(value['transactionDate'])).day.toDouble(),
              (value['amount'] as double).toDouble()),
        );
      }
    });
    return creditDataSet;
  }

  getTotalBalance(dynamic entireData) {
    totalExpense = entireData["totalDebit"];
    totalIncome = entireData["totalCredit"];
    totalBalance = totalIncome - totalExpense;
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    if (assetName.contains("json")) {
      return Lottie.asset('assets/$assetName', width: width);
    } else {
      return Image.asset('assets/$assetName', width: width);
    }
  }

  Widget placeHolder = const OverviewScreen();
  Widget floatingActionButtonPlaceHolder = const Text("");
  @override
  Widget build(BuildContext context) {
    // final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
        key: _key,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (!Platform.isAndroid && !Platform.isIOS) {
                _controller.setExtended(true);
              }
              _key.currentState?.openDrawer();
            },
            icon: const Icon(
              Icons.menu,
              color: Static.PrimaryColor,
            ),
          ),
          actions: [
            //  IconButton(
            //     icon: FutureBuilder<List<dynamic>>(
            //         future: notificationService.getNotifications(context),
            //         builder: (context, snapshot) {
            //           if (snapshot.hasError) {
            //             return const Icon(Icons.notifications_active);
            //           }
            //           if (snapshot.hasData) {
            //             var data = snapshot.data!
            //                 .where((element) => element["isOpened"] == false);
            //             if (data.isEmpty) {
            //               return const Icon(Icons.notifications_active);
            //             } else {
            //               return badges.Badge(
            //                 badgeAnimation: const badges.BadgeAnimation.slide(
            //                     animationDuration: Duration(seconds: 5),
            //                     loopAnimation: true),
            //                 badgeStyle: const badges.BadgeStyle(
            //                     badgeColor: Color.fromARGB(255, 172, 20, 9)),
            //                 badgeContent: Text(
            //                   snapshot.data!
            //                       .where(
            //                           (element) => element["isOpened"] == false)
            //                       .length
            //                       .toString(),
            //                   style: const TextStyle(color: Colors.white),
            //                 ),
            //                 child: const Icon(Icons.notifications_active),
            //               );
            //             }
            //           } else {
            //             return const Icon(Icons.notifications_active);
            //           }
            //         }),
            //     onPressed: () {
            //       Navigator.of(context)
            //           .push(MaterialPageRoute(
            //               builder: (context) => const NotificationScreen()))
            //           .whenComplete(() {
            //         setState(() {});
            //       });
            //     },
            //     color: Static.PrimaryColor,
            //   ),

            IconButton(
              icon: const Icon(
                Icons.notifications,
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => NotificationListPage("${FirebaseAuth.instance.currentUser!.email}")));
              },
              color: Static.PrimaryColor,
            ),


            IconButton(
              icon: const Icon(
                Icons.settings,
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingsScreen()));
              },
              color: Static.PrimaryColor,
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 2,
          title: const Text(
            "MeterProMax",
            style: TextStyle(color: Static.PrimaryColor),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 252, 246, 246),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: floatingActionButtonPlaceHolder,
        drawer: SidebarX(
          controller: _controller,
          theme: SidebarXTheme(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: canvasColor,
              borderRadius: BorderRadius.circular(20),
            ),
            hoverColor: scaffoldBackgroundColor,
            textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            selectedTextStyle: const TextStyle(color: Colors.white),
            itemTextPadding: const EdgeInsets.only(left: 30),
            selectedItemTextPadding: const EdgeInsets.only(left: 30),
            itemDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: canvasColor),
            ),
            selectedItemDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: actionColor.withOpacity(0.37),
              ),
              gradient: const LinearGradient(
                colors: [accentCanvasColor, canvasColor],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.28),
                  blurRadius: 30,
                )
              ],
            ),
            iconTheme: IconThemeData(
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
            selectedIconTheme: const IconThemeData(
              color: Colors.white,
              size: 20,
            ),
          ),
          extendedTheme: const SidebarXTheme(
            width: 200,
            decoration: BoxDecoration(
              color: canvasColor,
            ),
          ),
          footerDivider: divider,
          headerBuilder: (context, extended) {
            return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Static.PrimaryColor),
                accountName: Text("${FirebaseAuth.instance.currentUser?.email?.split('@')[0]}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text("${FirebaseAuth.instance.currentUser?.email}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                currentAccountPicture: const Icon(
                  Icons.electric_bolt,
                  color: Colors.white,
                  size: 50,
                ));
          },
          items: [
            SidebarXItem(
              icon: FontAwesomeIcons.gaugeHigh,
              label: 'Dashboard',
              onTap: () {
                setState(() {
                  placeHolder = const OverviewScreen();
                  floatingActionButtonPlaceHolder = const Text("");
                });
                Navigator.pop(context);
                debugPrint('Overview');
              },
            ),
            // SidebarXItem(
            //     icon: Icons.search,
            //     label: 'Advanced Search',
            //     onTap: () {
            //       setState(() {
            //         floatingActionButtonPlaceHolder = FloatingActionButton(
            //           onPressed: () {
            //             Navigator.of(context).push(
            //               MaterialPageRoute(
            //                   builder: (context) => const DataEntryScreen()),
            //             );
            //           },
            //         );
            //       });
            //     }),
            SidebarXItem(
                icon: Icons.electric_bolt,
                label: 'My Meters',
                onTap: () {
                  setState(() {
                    placeHolder = const MyMeterScreen();
                    floatingActionButtonPlaceHolder = const Text("");
                  });
                  Navigator.pop(context);
                }),

            SidebarXItem(
                icon: Icons.electric_bolt,
                label: 'My Meter Groups',
                onTap: () {
                  setState(() {
                    placeHolder = const GroupScreen();
                    floatingActionButtonPlaceHolder = const Text("");
                  });
                  Navigator.pop(context);
                }),

            //
            // SidebarXItem(
            //     icon: Icons.help_center_outlined,
            //     label: 'Help And Supprt',
            //     onTap: () {
            //       setState(() {
            //         placeHolder = const CategoryScreen();
            //         floatingActionButtonPlaceHolder = const Text("");
            //       });
            //       Navigator.pop(context);
            //     }),
            // SidebarXItem(
            //     icon: FontAwesomeIcons.chartPie,
            //     label: 'Reports',
            //     onTap: () {
            //       setState(() {
            //         placeHolder = const ReportScreen();
            //         floatingActionButtonPlaceHolder = const Text("");
            //       });
            //       Navigator.pop(context);
            //     }),
          ],
        ),
        body: FirebaseAuth.instance.currentUser!.emailVerified?placeHolder:UnverifiedEmailPage());
  }
}

const primaryColor = Static.PrimaryColor;
const canvasColor = Color.fromARGB(255, 11, 177, 110);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);

const businessColor = Color.fromARGB(255, 201, 210, 217);
