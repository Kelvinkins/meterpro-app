import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:meterpro/services/transaction_service.dart';

import '../common/loaders.dart';
import 'meter_detail_screen.dart';

class VendingHistoryScreen extends StatefulWidget {
  @override
  _VendingHistoryScreenState createState() => _VendingHistoryScreenState();
  const VendingHistoryScreen({required this.group, super.key});
  final dynamic group;
}

class _VendingHistoryScreenState extends State<VendingHistoryScreen> {
  List<dynamic> vendingHistory = [];
  TransactoinService transactoinService = TransactoinService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    transactoinService.loading.listen((state) {
      if (mounted) {
        setState(() => _loading = state);
      }
    });
    fetchVendingHistory(widget.group["groupID"]);

  }

  Future<void> fetchVendingHistory(String groupID) async {
    var vendings =
    await transactoinService.getVendingHistoryByGroup(context, groupID);

    setState(() {
      vendingHistory = vendings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.group["groupName"]} Vending history'),
      ),
      body: _loading
          ? Center(
        child: Spinners.spinkitFadingCircle,
      )
          : vendingHistory.isNotEmpty
          ? ListView.builder(
        shrinkWrap: true,
        itemCount: vendingHistory.length,
        itemBuilder: (context, index) {
          Map dataAtIndex = vendingHistory[index];
          return vendingTile(dataAtIndex);
        },
      )
          : Center(child: Text("No Vending history")),
    );
  }

  Widget vendingTile(dynamic data) {
    return Container(
      child: Card(
          elevation: 0.3,
          child: ListTile(
            isThreeLine: true,
            leading: Icon(
              Icons.electric_meter_sharp,
              size: 28.0,
              color: Colors.green[700],
            ),
            trailing: Text(
              data["credited"] == null
                  ? "Pending"
                  : (data["credited"] == true ? "Approved" : "Declined"),
              style: TextStyle(
                  color: data["credited"] == null
                      ? Colors.orange
                      : (data["credited"]
                      ? Colors.green[700]
                      : Colors.red)),
            ),
            title: Text(
              data["meterSn"],
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
            subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(data["description"]),
                  Text("Requested Unit:${data["subscriptionValue"]}"),
                ]),
          )),
    );
  }
}
