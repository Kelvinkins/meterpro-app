import 'package:flutter/material.dart';
import 'package:meterpro/common/static.dart' as Static;
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/common/global.dart';
import '../screens/meter_detail_screen.dart';
import '../screens/request_unit_page.dart';
import '../screens/subscription_history_screen.dart';
import '../services/notification_service.dart';
import '../services/transaction_service.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MeterDashboard extends StatefulWidget {
  const MeterDashboard(this.meter, {Key? key}) : super(key: key);
  final dynamic meter;

  @override
  _MeterDashboardState createState() => _MeterDashboardState();
}

class _MeterDashboardState extends State<MeterDashboard> {
  static const _insets = 16.0;
  final _key = GlobalKey<ScaffoldState>();
  bool loading = false;
  dynamic vendingHistory = [];
  dynamic sessionStatistics = {};
  final TextEditingController _unitsController = TextEditingController();
  double get _adWidth => MediaQuery.of(context).size.width - (2 * _insets);
  TransactoinService transactionService = TransactoinService();
  List<dynamic> xyPlotData = [];
  bool _loading = false;
  void fetchData() async {
    try {
      setState(() {
        _loading = true;
      });

      final response = await transactionService.getSessionStatistics(
          context, widget.meter['meterSn']);

      if (response != null) {
        setState(() {
          sessionStatistics = response;
        });print(response);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    transactionService.loading.listen((state) {
      if (mounted) {
        setState(() => _loading = state);
      }
    });
    Global.getDeviceId().then((token) {
      var data = {"meterSn": widget.meter["meterSn"], "deviceID": token};
      transactionService.updateDeviceID(context, data);
    });
fetchData();
    getTotalBalance();
    transactionService
        .getSubscriptionHistory(context, widget.meter["meterSn"])
        .then((value) {
      setState(() {
        xyPlotData = value;
        print(xyPlotData);
        getX_PlotPoints(xyPlotData);
        getY_PlotPoints(xyPlotData);
      });
    });

    transactionService
        .getVendingHistoryByMeterSn(context, widget.meter["meterSn"])
        .then((value) {
      setState(() {
        vendingHistory = value;
      });
    });
  }

  void dispose() {
    super.dispose();
  }

  DateTime today = DateTime.now();
  double totalBalance = 0.0;
  double subscriptionValue = 0.0;
  SmsQuery query = SmsQuery();

  List<FlSpot> balanceDs = [];
  List<FlSpot> subscriptionDs = [];

  List<FlSpot> creditDataSet = [];
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  List<FlSpot> getX_PlotPoints(List<dynamic> entireData) {
    entireData.forEach((dynamic value) {
      print(value);
      balanceDs.add(FlSpot(
          (DateTime.parse(value['dateActivated'])).day.toDouble(),
          double.parse(value['balance'].toString())));
    });
    return balanceDs;
  }

  List<FlSpot> getY_PlotPoints(List<dynamic> entireData) {
    entireData.forEach((dynamic value) {
      print("HERER!!!$value");
      subscriptionDs.add(FlSpot(
          (DateTime.parse(value['dateActivated'])).day.toDouble(),
          double.parse(value['currentSubscriptionValue'].toString())));
    });
    return subscriptionDs;
  }

  getTotalBalance() async {
    var data = await transactionService.getBalanceData(
        context, widget.meter["meterSn"]);
    subscriptionValue = double.parse(data["currentSubscriptionValue"].toString());
    totalBalance = double.parse(data["balance"].toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        key: _key,
        appBar: AppBar(
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => SubscriptionHistoryScreen(
                            meterSn: widget.meter["meterSn"],
                          )),
                );
              },
              icon: Icon(Icons.history),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications),
            ),
            IconButton(
                onPressed: () {
                  _showConfirmationDialog(context, widget.meter);
                },
                icon: widget.meter["powerStatus"] == "ON"
                    ? Icon(Icons.power_off)
                    : Icon(
                        Icons.bolt,
                        color: Colors.orange,
                      ))
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Static.PrimaryColor,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => RequestUnitsPage(meter: widget.meter),
              ),
            );
          },
          label: const Text("Request for subscription"),
          icon: const Icon(Icons.add_to_queue),
        ),
        body: _loading
            ? Center(
                child: Spinners.spinkitFadingCircle,
              )
            : RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.meter["meterSn"],
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: const EdgeInsets.all(
                        12.0,
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Static.PrimaryColor,
                              Static.PrimaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              24.0,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 8.0,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Unit Balance',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22.0,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 12.0,
                            ),
                            Text(
                              intl.NumberFormat.decimalPattern()
                                  .format(totalBalance),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 12.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(
                                8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  subscriptionValueCard(
                                      intl.NumberFormat.decimalPattern()
                                          .format(subscriptionValue)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "Usage trend chart",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black87,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    balanceDs.length < 1 || subscriptionDs.length < 1
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                8.0,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 40.0,
                            ),
                            margin: const EdgeInsets.all(
                              12.0,
                            ),
                            child: const Text(
                              "Not enough records to plot Chart",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.black87,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                8.0,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 40.0,
                            ),
                            margin: const EdgeInsets.all(
                              12.0,
                            ),
                            height: 300.0,
                            child: LineChart(
                              LineChartData(
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: getX_PlotPoints(xyPlotData),
                                    isCurved: false,
                                    barWidth: 2.5,
                                    color: Colors.green,
                                  ),
                                  LineChartBarData(
                                    spots: getY_PlotPoints(xyPlotData),
                                    isCurved: false,
                                    barWidth: 2.5,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                              // swapAnimationCurve: Curves.linear,
                              // swapAnimationDuration: const Duration(seconds: 15),
                            ),
                          ),
                    Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "  Balance: ${intl.NumberFormat.decimalPattern().format(totalBalance)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Static.PrimaryColor),
                        )),
                    _loading
                        ? Center(child: CircularProgressIndicator())
                        : sessionStatistics!=null? Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Uptime Session Statistics",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    StatisticCard(
                                      title: 'Average',
                                      value: sessionStatistics['mean'],
                                      color: Colors.blue,
                                    ),
                                    StatisticCard(
                                      title: 'Median',
                                      value: sessionStatistics['median'],
                                      color: Colors.orange,
                                    ),
                                    StatisticCard(
                                      title: 'UpTime',
                                      value: sessionStatistics['totalUpTime'],
                                      color: Colors.green,
                                    )
                                  ],
                                ),Divider(height: 30,), Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [

                                      StatisticCard(
                                      title: 'DownTime',
                                      value: sessionStatistics['totalDownTime'],
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ):Center(child: Text("No Data"),),
                    vendingHistory.length > 0
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: vendingHistory.length,
                            itemBuilder: (context, index) {
                              Map dataAtIndex = vendingHistory[index];
                              return vendingTile(dataAtIndex);
                            },
                          )
                        : Center(child: Text("No Vending history")),
                    const Divider(
                      height: 150,
                    )
                  ],
                )));
  }

  Future<void> _onRefresh() {
    setState(() {});
    return Future.delayed(const Duration(seconds: 1));
  }

  Widget subscriptionValueCard(String value) {
    return Row(
      children: [
        Container(
          child: const Icon(
            Icons.history,
            size: 28.0,
            color: Colors.white,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Subscription Value",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget initialValueCard(String value) {
    return Row(
      children: [
        Container(
          child: const Icon(
            Icons.insights,
            size: 28.0,
            color: Colors.white,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Unit Brought Forward",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget vendingTile(dynamic data) {
    return Container(
      child: Card(
          elevation: 0.3,
          child: ListTile(
            isThreeLine: true,
            leading: Icon(
              Icons.electric_bolt,
              size: 28.0,
              color: Colors.green[700],
            ),
            trailing: loading
                ? Spinners.spinkitThreeBounceBlueSmall
                : Text(
                    data["credited"] == null
                        ? "Pending"
                        : (data["credited"] == true ? "Approved" : "Declined"),
                    style: TextStyle(
                        color: data["credited"] == null
                            ? Colors.orange
                            : (data["credited"]
                                ? Colors.green[700]
                                : Colors.grey)),
                  ),
            title: Text(
              data["meterSn"],
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Text(data["description"]),
              Text("Requested Unit:${data["subscriptionValue"].toString()}")
            ]),
            onTap: () {},
          )),
    );
  }

  void _showConfirmationDialog(BuildContext context, dynamic data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Action'),
          content: data["powerStatus"] == "ON"
              ? const Text('Are you sure you want to shut off the meter?')
              : const Text('Do you want to power on the meter?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // Perform the action to shut off the meter
                // Add your logic here
                setState(() {
                  loading = true;
                });
                var payload = {
                  "meterSn": data["meterSn"],
                  "value": {"ForceSwitch": data["powerStatus"] == "ON" ? 0 : 1},
                  "shutOffBy": 0
                };
                var result =
                    await transactionService.postMeterCommand(context, payload);
                if (result != null) {
                  setState(() {
                    data["powerStatus"] =
                        data["powerStatus"] == "ON" ? "OFF" : "ON";
                  });
                }
                setState(() {
                  loading = false;
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}

class StatisticCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;

  const StatisticCard({
    required this.title,
    required this.value,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 22.0,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
