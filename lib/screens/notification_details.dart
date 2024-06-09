import 'dart:io';

import 'package:meterpro/common/global.dart';
import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/services/notification_service.dart';
import 'package:meterpro/services/transaction_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:meterpro/common/static.dart' as Static;
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
 import 'package:badges/badges.dart' as badges;
import 'package:timeago/timeago.dart' as timeago;

class NotificationDetailsScreen extends StatefulWidget {
  const NotificationDetailsScreen({Key? key, this.data}) : super(key: key);
  final dynamic data;
  @override
  _NotificationDetailsScreenState createState() =>
      _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {
  static const _insets = 16.0;
   NotificationService notificationService = NotificationService();
  bool _isLoaded = false;

  double get _adWidth => MediaQuery.of(context).size.width - (2 * _insets);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Set Is Open true
    if (widget.data["notificationID"] != null) {
      notificationService.opened(context, widget.data["notificationID"]);
    } else {
      transactionService.opened(context, widget.data["aiTipID"]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
   }


  void dispose() {
    super.dispose();
   }

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  TransactoinService transactionService = TransactoinService();

  Widget _buildImage(String assetName, [double width = 350]) {
    if (assetName.contains("json")) {
      return Lottie.asset('assets/$assetName', width: width);
    } else {
      return Image.asset('assets/$assetName', width: width);
    }
  }

  TextEditingController textEditingController = TextEditingController();
  TextEditingController txtLogController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Static.PrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(widget.data["subject"]),
        ),
        backgroundColor: const Color.fromARGB(255, 252, 246, 246),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: ListView(
          children: [
            SizedBox(height: 50),
            Text(
              "Subject: ${widget.data["subject"]}",
              style: const TextStyle(
                fontSize: 20.0,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              height: 10,
            ),
            Text(
              widget.data["body"],
              style: const TextStyle(fontSize: 20, color: Colors.black54),
            ),
            SizedBox(height: 50),
          ]
        ));
  }
}
