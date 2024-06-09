import 'package:flutter/material.dart';
import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/services/transaction_service.dart';

class RequestUnitsPage extends StatefulWidget {
  final dynamic meter;
  const RequestUnitsPage({required this.meter, Key? key}) : super(key: key);

  @override
  _RequestUnitsPageState createState() => _RequestUnitsPageState();
}

class _RequestUnitsPageState extends State<RequestUnitsPage> {
  final TextEditingController _unitsController = TextEditingController();
  final TransactoinService transactoinService=TransactoinService();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Units'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _unitsController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Units'),
              style: TextStyle( // Set style for input text
                fontSize: 100,
                color:Colors.green,// Set font size
                fontWeight: FontWeight.bold, // Set font weight
              ),
            ),
            const SizedBox(height: 20),
            _loading ? Spinners.spinkitFadingCircle : ElevatedButton(
              onPressed: () async {
                double units = double.tryParse(_unitsController.text) ?? 0.0;
                setState(() => _loading = true);

                var payload = {
                  "meterSn": widget.meter["meterSn"],
                  "subscriptionValue": units,
                  "groupID": widget.meter["groupID"],
                  "initiator": widget.meter["owner"]
                };

                var result = await transactoinService.initiateSubscriptionRequest(context, payload);

                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text("You have successfully purchased $units unit(s)"),
                      action: SnackBarAction(
                        textColor: Colors.white,
                        label: 'Dismiss',
                        onPressed: () {},
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text("An error has occurred purchasing the units"),
                      action: SnackBarAction(
                        textColor: Colors.white,
                        label: 'Dismiss',
                        onPressed: () {},
                      ),
                    ),
                  );
                }
                setState(() => _loading = false);
                Navigator.of(context).pop(); // Close the page
              },
              child: const Text('Request'),
            ),
          ],
        ),
      ),
    );
  }
}
