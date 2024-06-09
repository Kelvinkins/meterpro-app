import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/services/transaction_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreateMeterGroupForm extends StatefulWidget {
  @override
  _CreateMeterGroupFormState createState() => _CreateMeterGroupFormState();
}

class _CreateMeterGroupFormState extends State<CreateMeterGroupForm> {
  final TextEditingController groupNameController = TextEditingController();
  final TransactoinService transactionService = TransactoinService();
  bool isLoading = false;

  Future<void> createGroup() async {
    if (groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group name cannot be empty')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String groupName = groupNameController.text.trim();
    var data = {
      "groupAdmin": FirebaseAuth.instance.currentUser?.email,
      "groupName": groupName,
    };

    try {
      var response = await transactionService.createGroup(context, data);
      if (response != null) {
        Navigator.pop(context);
      } else {
        throw Exception('Failed to create group');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Meter Group'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isLoading ? null : createGroup,
              child: isLoading ? Spinners.spinkitFadingCircle : Text('Create'),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
