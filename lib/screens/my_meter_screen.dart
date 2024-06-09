import 'package:flutter/material.dart';
import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/widgets/meter_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/transaction_service.dart';
import 'ownership_claim_screen.dart'; // Ensure you have this widget or replace it with a suitable one

class MyMeterScreen extends StatefulWidget {
  const MyMeterScreen({Key? key}) : super(key: key);

  @override
  _MyMeterScreenState createState() => _MyMeterScreenState();
}

class _MyMeterScreenState extends State<MyMeterScreen> {
  TransactoinService transactionService = TransactoinService();
  bool _isLoading = true;
  List<dynamic> _meters = [];

  @override
  void initState() {
    super.initState();
    fetchMeters();
  }

  Future<void> fetchMeters() async {
    try {
      var meters = await transactionService.getMeters(context, FirebaseAuth.instance.currentUser?.email ?? '');
      setState(() {
        _meters = meters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show an error message or handle the error appropriately
      print('Error fetching meters: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Meters'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchMeters,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: Spinners.spinkitFadingCircle)
          : _meters.isEmpty
          ? Center(child: Text('No meters found'))
          : ListView.builder(
        itemCount: _meters.length,
        itemBuilder: (context, index) => meterTile(_meters[index]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>  ClaimOwnershipForm())),
        label: Text('Add Meter'),
        icon: Icon(Icons.add),
      ),
    );
  }

  Widget meterTile(dynamic data) {
    return ListTile(
      leading: Icon(Icons.electric_meter_sharp, color: Colors.green[700], size: 28),
      title: Text(data['meterSn'], style: TextStyle(fontSize: 20)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Name: ${data["deviceName"]}"),
          Text("Last updated: ${data["lastUpdated"]}"),
        ],
      ),
      trailing: Text(
        data["powerStatus"],
        style: TextStyle(
          color: data["powerStatus"] == "ON" ? Colors.green[700] : Colors.grey,
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MeterDashboard(data),
          ),
        );
      },
      onLongPress: () => _showConfirmationDialog(context, data),
    );
  }

  void _showConfirmationDialog(BuildContext context, dynamic data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Action'),
          content: Text(
              data["powerStatus"] == "ON" ?
              'Are you sure you want to shut off the meter?' :
              'Do you want to power on the meter?'
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await togglePowerStatus(data);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> togglePowerStatus(dynamic data) async {
    var payload = {
      "meterSn": data["meterSn"],
      "value": {"ForceSwitch": data["powerStatus"] == "ON" ? 0 : 1},
    };
    try {
      var result = await transactionService.postMeterCommand(context, payload);
      if (result != null) {
        setState(() {
          data["powerStatus"] = data["powerStatus"] == "ON" ? "OFF" : "ON";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change meter status: $e')),
      );
    }
  }
}
