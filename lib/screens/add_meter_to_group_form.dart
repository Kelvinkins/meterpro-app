import 'package:flutter/material.dart';
import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/services/transaction_service.dart';
import 'package:flutter/services.dart';

class AddMeterToGroupForm extends StatefulWidget {
  final dynamic group;
  const AddMeterToGroupForm({Key? key, required this.group}) : super(key: key);

  @override
  _AddMeterToGroupFormState createState() => _AddMeterToGroupFormState();
}

class _AddMeterToGroupFormState extends State<AddMeterToGroupForm> {
  final TextEditingController meterSnController = TextEditingController();
  final TransactoinService transactionService=TransactoinService();
  bool _isSubmitting = false;

  void addToGroup() async {
    if (_isSubmitting) return; // Prevent multiple submissions
    setState(() {
      _isSubmitting = true;
    });

    try {
      String meterSn = meterSnController.text;
      var data = {
        "groupID": widget.group["groupID"],
        "meterSn": meterSn,
      };

      bool success = await transactionService.addMeterToGroup(context,data);

      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add meter. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Meter to "${widget.group["groupName"]}"'),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: meterSnController,
              decoration: InputDecoration(
                labelText: 'Meter Serial Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.electric_meter_sharp),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : addToGroup,
              child: _isSubmitting ? Spinners.spinkitFadingCircle:  Text('Add to Group'),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
