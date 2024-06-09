import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/transaction_service.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({Key? key}) : super(key: key);

  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  TransactoinService transactionService = TransactoinService();
  List<dynamic> usages = [];
  Map<String, dynamic> getDayWithHighestUsage(List<dynamic> usageData) {
    Map<String, dynamic> highestUsageDay = usageData[0];
    for (var data in usageData) {
      if (data['unit'] > highestUsageDay['unit']) {
        highestUsageDay = data;
      }
    }
    return highestUsageDay;
  }

  Map<String, dynamic> getDayWithLowestUsage(List<dynamic> usageData) {
    Map<String, dynamic> lowestUsageDay = usageData[0];
    for (var data in usageData) {
      if (data['unit'] < lowestUsageDay['unit']) {
        lowestUsageDay = data;
      }
    }
    return lowestUsageDay;
  }

  double getAverageDailyUsage(List<dynamic> usageData) {
    double totalUnits = 0;
    for (var data in usageData) {
      totalUnits += data['unit'];
    }
    return totalUnits / usageData.length;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    transactionService.getLast7DaysUsage(context, 7,FirebaseAuth.instance.currentUser?.email ?? '').then((value) {
      setState(() {
        usages = value;
      });
    });
  }
  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
  @override
  Widget build(BuildContext context) {     List<PieChartSectionData> sections = usages.map((data) {
    return PieChartSectionData(
      value: data['unit'],
      color: getRandomColor(),
      title: data['dayOfWeek'],
      radius: 50,
    );
  }).toList();

  return Scaffold(
      appBar: AppBar(
        title: Text('Overview'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Daily Usage',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Flex(direction: Axis.vertical, children: [
                usages.isNotEmpty
                    ? Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: PieChart(
                            PieChartData(
                              sections: sections
                            ),
                          ),
                        ),
                      )
                    : Center(child: Text("No Data"))
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Insights:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
         usages.isNotEmpty? Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                child: ListView(
                  children: [
                    _buildInsightTile(
                        'Highest Usage Day', getDayWithHighestUsage(usages)['dayOfWeek'], '${getDayWithHighestUsage(usages)['unit']} units'),
                    _buildInsightTile(
                        'Lowest Usage Day', getDayWithLowestUsage(usages)['dayOfWeek'], '${getDayWithLowestUsage(usages)['unit']} units'),
                    _buildInsightTile('Average Daily Usage', '', '${getAverageDailyUsage(usages).toStringAsFixed(2)} units'),
                  ],
                ),
              ),
            ),
          ):Center(child: Text("No Data"),)
        ],
      ),
    );
  }

  Widget _buildInsightTile(String title, String day, String value) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: day.isNotEmpty
          ? Text('Day: $day\nUsage: $value')
          : Text('Usage: $value'),
      onTap: () {
        // Action to view more details
      },
    );
  }
}
