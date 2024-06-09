import 'package:meterpro/common/global.dart';
import 'package:meterpro/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' as intl;
import 'package:firebase_analytics/firebase_analytics.dart';
 import '../common/loaders.dart';
import 'package:meterpro/common/static.dart' as Static;
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

import 'notification_details.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  TransactoinService transactionService = TransactoinService();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  DataTableSource? data;
  static const _insets = 16.0;

  bool _isLoaded = false;

   List<dynamic> categories = [];
  static Widget reportWidget({String? title}) {
    return Text(title!);
  }

  var report = [
    {
      "title": "Usage report by month",
      "description": "This report shows usage report broken down by month",
      "widget": reportWidget(title: "Usage report by month"),
      "icon": const Icon(
        Icons.bar_chart,
        color: Static.PrimaryColor,
      )
    },
    {
      "title": "Transaction Summary Grouped by Month",
      "description":
          "This report shows a summary of the total amount of transactions grouped by month",
      "widget": reportWidget(title: "Transaction Summary Grouped by Month"),
      "icon": const Icon(
        Icons.pie_chart,
        color: Static.PrimaryColor,
      )
    },
    {
      "title": "Credit and Debit Summary Report",
      "description":
          "This report shows a summary of all your debit and credit transactions",
      "widget": reportWidget(title: "Credit and Debit Summary Report"),
      "icon": const Icon(
        Icons.area_chart,
        color: Static.PrimaryColor,
      )
    },
    {
      "title": "Transaction Summary grouped by platform",
      "description":
          "This report shows a summary of all your transactions grouped by platforms",
      "widget": reportWidget(title: "Transaction Summary grouped by platform"),
      "icon": const Icon(
        Icons.show_chart_sharp,
        color: Color.fromARGB(255, 1, 1, 1),
      )
    },
    {
      "title": "Transaction Query/Search",
      "description":
          "Use this report to query and search specific transactions",
      "widget": reportWidget(title: "Transaction Query/Search"),
      "icon": const Icon(
        Icons.search,
        color: Color.fromARGB(255, 1, 1, 1),
      )
    }
  ];

  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void dispose() {
    super.dispose();
   }

  bool vetting = false;
  @override
  Widget build(BuildContext context) {
    ProgressDialog pr = ProgressDialog(context: context);

    return loading
        ?  Center(
            child: Spinners.spinkitThreeBounceBlue,
          )
        : Scaffold(
            // floatingActionButtonLocation:
            //     FloatingActionButtonLocation.centerFloat,
            // floatingActionButton: FloatingActionButton(
            //   backgroundColor: Static.PrimaryColor,
            //   foregroundColor: Colors.white,
            //   onPressed: () async {
            //     Navigator.of(context).push(MaterialPageRoute(
            //       builder: (context) => const CreateCategoryScreen(),
            //     ));
            //   },
            //   child: const Icon(Icons.add),
            // ),
            body: ListView(
            children: [
               const Center(
                  child: Text(
                "Report Menu",
                style: TextStyle(color: Static.PrimaryColor, fontSize: 30),
              )),
              const Divider(
                height: 30,
              ),
              messageTile(report[0]),
              // messageTile(report[1]),
              // messageTile(report[2]),
              // messageTile(report[3]),
              // messageTile(report[4]),
              const Divider(
                height: 70,
              )
            ],
          ));
  }

  Widget messageTile(dynamic data) {
    return Container(
      child: Card(
          elevation: 0.3,
          child: ListTile(
            isThreeLine: true,
            leading: data["icon"],
            title: Text(
              data["title"],
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(
              data["description"],
            ),
            onLongPress: () {},
            onTap: () {

              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => data["widget"]))
                  .whenComplete(() {
                setState(() {});
              });

            },
          )),
    );
  }
}
