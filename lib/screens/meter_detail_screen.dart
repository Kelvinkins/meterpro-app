import 'dart:io';

import 'package:meterpro/common/global.dart';
import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/screens/subscription_history_screen.dart';
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

class MeterDetailsScreen extends StatefulWidget {
  const MeterDetailsScreen({Key? key, this.data}) : super(key: key);
  final dynamic data;
  @override
  _MeterDetailsScreenState createState() =>
      _MeterDetailsScreenState();
}

class _MeterDetailsScreenState extends State<MeterDetailsScreen> {
  static const _insets = 16.0;
  NotificationService notificationService = NotificationService();
  final bool _isLoaded = false;
   final TextEditingController _meterSnController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();
  dynamic balanceData;
  bool loading=false;
  double get _adWidth =>
      MediaQuery
          .of(context)
          .size
          .width - (2 * _insets);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loading=true;

    transactionService.getBalanceData(context, widget.data["meterSn"]).then((value) {
      setState(() {
        balanceData=value;

      });
    }).whenComplete(() {
      setState(() {
        loading=false;
      });
    });
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 64, 168, 67),
        foregroundColor: Colors.white,
        onPressed: () {
          _showConfirmationDialog(context, widget.data);
        },
        label: widget.data["powerStatus"] == "ON"
            ? const Text("Power Off")
            : const Text("Power On"),
        icon: const Icon(Icons.upgrade),
      ),
      appBar: AppBar(
        backgroundColor: Static.PrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.data["meterSn"]),
        actions: [
          IconButton(onPressed: () {

            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>  SubscriptionHistoryScreen(meterSn: widget.data["meterSn"],)),
                            );
          }, icon: Icon(Icons.history),),
          IconButton(onPressed: () {  }, icon: Icon(Icons.notifications),)
        ],
      ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ListView(
        children: [
          const SizedBox(
            height: 30,
          ),
          Card(
              elevation: 0,
              child:
              SelectableText.rich(
                textScaleFactor: 1.2,
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    const TextSpan(
                      text: "Meter Details",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Static.PrimaryColor),
                    ),
                    TextSpan(
                      text:
                      "\nMeter SN: ${widget.data["meterSn"].toString()}",
                      style: const TextStyle(),
                    ),

                    TextSpan(
                      text:
                      "\nName: ${widget.data["deviceName"].toString()}",
                      style: const TextStyle(),
                    ),
                    widget.data["powerStatus"] == "ON"
                        ? const TextSpan(
                        text: '\nPower Status: ON',
                        style: TextStyle(color: Colors.green))
                        : const TextSpan(
                        text: '\nPower Status: OFF',
                        style: TextStyle(color: Colors.red)),
                    TextSpan(
                      text:
                      '\nDate Added: ${widget.data["dateEnrolled"].toString()}',
                    ),

                    const TextSpan(
                      text: '\n',
                    ),
                  ],
                ),
              )),
       loading? Center(child:Row(mainAxisAlignment: MainAxisAlignment.center, children: [Spinners.spinkitThreeBounceBlue,Text("Retrieving balance data...")],)):
        balanceData==null? Center(child:Text("No Balance Data")):
         SelectableText.rich(
           textAlign: TextAlign.center,
          TextSpan(
            children: [
              const TextSpan(
                text: "Balance Data",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Static.PrimaryColor),
              ),

              TextSpan(
                text:
                '\nPurchased Value: ${intl.NumberFormat.decimalPattern().format(
                    balanceData["subscriptionValue"])}',
              ),
              TextSpan(
                text:
                '\nCurrent Balance: ${intl.NumberFormat.decimalPattern().format(
                    balanceData["balance"])}',
              ),

              TextSpan(
                text:
                '\nDate Added: ${balanceData["dateActivated"].toString()}',
              ),

              const TextSpan(
                text: '\n',
              ),
            ],
          ),
        ) ,

               ElevatedButton(
                child: const Text('\nSubscription Request',

              ),onPressed: (){
                  _meterSnController.text=widget.data["meterSn"];
                 _showControlDialog(context);
               },),

         ],
      ),

    );
  }

  void _showConfirmationDialog(BuildContext context, dynamic data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Action'),
          content: data["powerStatus"] == "ON" ? const Text(
              'Are you sure you want to shut off the meter?') : const Text(
              'Do you want to power on the meter?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog

              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                // Perform the action to shut off the meter
                // Add your logic here
                var payload = {
                  "meterSn": data["meterSn"],
                  "value": {
                    "ForceSwitch": data["powerStatus"] == "ON" ? 0 : 1
                  },
                  "shutOffBy": 0
                };
                transactionService.postMeterCommand(context, payload);
                Navigator.of(context).pop(); // Close the dialog

                setState(() {

                });
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showControlDialog(BuildContext context ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Purchase Units'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _meterSnController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Meter Sn'),
              ),
              TextField(
                controller: _unitsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Units'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Perform the action based on meter control
                String meterSn = _meterSnController.text;
                double units = double.tryParse(_unitsController.text) ?? 0.0;
                var payload={
                  "meterSn": meterSn,
                "subscriptionValue": units,
                "credited": false,
                  "groupID":widget.data["groupID"],
                  "initiator":widget.data["owner"]
              };
                var result= await transactionService.initiateSubscriptionRequest(context, payload);
                if(result!=null){
                  final snackBar = SnackBar(
                    backgroundColor:   Colors.green,
                     content: Text("You have successfully purchased $units unit(s)"),
                    action: SnackBarAction(
                      textColor: Colors.white,
                      label: 'Dismiss',
                      onPressed: () {},
                    ),
                  );
                  ScaffoldMessenger.of(context)
                      .showSnackBar(snackBar);
                }else{
                  final snackBar = SnackBar(
                    backgroundColor:   Colors.red,
                    content: Text("An error has occured purchasing the units"),
                    action: SnackBarAction(
                      textColor: Colors.white,
                      label: 'Dismiss',
                      onPressed: () {},
                    ),
                  );
                  ScaffoldMessenger.of(context)
                      .showSnackBar(snackBar);
                }
                setState(() {

                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Purchase'),
            ),
          ],
        );
      },
    );
  }
}
