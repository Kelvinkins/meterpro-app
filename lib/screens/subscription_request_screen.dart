import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/services/transaction_service.dart';

class SubscriptionRequestsPage extends StatefulWidget {
  const SubscriptionRequestsPage(this.groupID, {super.key});
  final String groupID;
  @override
  _SubscriptionRequestsPageState createState() =>
      _SubscriptionRequestsPageState();
}

class _SubscriptionRequestsPageState extends State<SubscriptionRequestsPage> {
  List<dynamic> subscriptionRequests = [];
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
    fetchSubscriptionRequests(context, widget.groupID);

  }

  Future<void> fetchSubscriptionRequests(
      BuildContext context, String groupID) async {
    var data = await transactoinService.GetSubscriptionRequestByGroupAdmin(
        context, groupID);
    setState(() {
      subscriptionRequests = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Requests'),
      ),
      body: subscriptionRequests.length > 0
          ? ListView.builder(
        itemCount: subscriptionRequests.length,
        itemBuilder: (context, index) {
          final request = subscriptionRequests[index];
          var payload = {
            'subscriptionRequestID': request['subscriptionRequestID']
          };

          return Card(
            child: ListTile(
              title: Text('Meter Serial Number: ${request["meterSn"]}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${request["subscriptionRequestID"]}'),
                  Text(
                      'Subscription Value: ${request["subscriptionValue"]}'),
                  Text('Initiator: ${request["initiator"]}'),
                  Text('Status: Pending'),
                  _loading
                      ? Spinners.spinkitThreeBounce
                      : Row(
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(
                              Colors.green),
                        ),
                        onPressed: () async {
                          payload["status"] = true;
                          await transactoinService
                              .activateSubscriptionRequest(
                              context, payload);
                          await fetchSubscriptionRequests(
                              context, widget.groupID);
                        },
                        child: Text(
                          "Approve",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(
                              Colors.red),
                        ),
                        onPressed: () async {
                          payload["status"] = false;
                          await transactoinService
                              .activateSubscriptionRequest(
                              context, payload);
                          await fetchSubscriptionRequests(
                              context, widget.groupID);
                        },
                        child: Text(
                          "Decline",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              trailing: _loading
                  ? Spinners.spinkitFadingCircle
                  : Icon(Icons.pending),
            ),
          );
        },
      )
          : Center(
        child: _loading
            ? Spinners.spinkitFadingCircle
            : Text("No Data"),
      ),
    );
  }
}
