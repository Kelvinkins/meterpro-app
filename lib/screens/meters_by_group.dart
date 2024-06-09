import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/services/transaction_service.dart';
import 'package:meterpro/widgets/meter_dashboard.dart';
import 'add_meter_to_group_form.dart';
import 'vending_history_screen.dart';
import 'subscription_request_screen.dart';

class MeterByGroupScreen extends StatefulWidget {
  final dynamic group;
  const MeterByGroupScreen(this.group, {Key? key}) : super(key: key);

  @override
  _MeterByGroupScreenState createState() => _MeterByGroupScreenState();
}

class _MeterByGroupScreenState extends State<MeterByGroupScreen> {
  final TransactoinService transactionService = TransactoinService();
  bool isLoading = true;
  List<dynamic> meters = [];

  @override
  void initState() {
    super.initState();
    loadMeters();
  }

  Future<void> loadMeters() async {
    try {
      var result = await transactionService.getMetersByGroupID(context, widget.group["groupID"]);
      setState(() {
        meters = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading meters: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group["groupName"]),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VendingHistoryScreen(group: widget.group),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.request_page),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubscriptionRequestsPage(widget.group["groupID"]),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMeterToGroupForm(group:widget.group),
            ),
          );
        },
        label: Text("Add Meter"),
        icon: Icon(Icons.add),
      ),
      body: isLoading
          ? Center(child: Spinners.spinkitFadingCircle)
          : ListView.builder(
        itemCount: meters.length,
        itemBuilder: (context, index) {
          return MeterCard(meter: meters[index]);
        },
      ),
    );
  }
}

class MeterCard extends StatelessWidget {
  final dynamic meter;
  const MeterCard({Key? key, required this.meter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.electric_meter, color: Theme.of(context).primaryColor),
        title: Text(meter["meterSn"]),
        subtitle: Text("Usage: ${meter["totalUsageAccum"]} kWh"),
        trailing: Text(meter["status"], style: TextStyle(color: meter["status"] == "ONLINE" ? Colors.green : Colors.red)),
        onTap: () {

        },
      ),
    );
  }
}
