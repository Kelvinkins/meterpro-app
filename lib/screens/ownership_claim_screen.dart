import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meterpro/common/global.dart';
import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/services/transaction_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClaimOwnershipForm extends StatefulWidget {
  @override
  _ClaimOwnershipFormState createState() => _ClaimOwnershipFormState();
}

class _ClaimOwnershipFormState extends State<ClaimOwnershipForm> {
  final TextEditingController meterSnController = TextEditingController();
  final TextEditingController deviceNameController = TextEditingController();
  bool _isProcessing = false;
  TransactoinService transactoinService = TransactoinService();

  Future<void> claimOwnership(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Fluttertoast.showToast(msg: 'Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(
            msg: 'Location permissions are permanently denied, we cannot request permissions.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      var data = {
        "email": FirebaseAuth.instance.currentUser?.email,
        "meterSn": meterSnController.text,
        "deviceID": await Global.getDeviceId(),
        "deviceName": deviceNameController.text,
        "latitude": position.latitude,
        "longitude": position.longitude,
      };

      var response = await transactoinService.claimMeter(context, data);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Meter ownership claimed successfully!');
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: 'Failed to claim meter ownership. Please try again!');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Claim Meter Ownership'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: meterSnController,
              decoration: InputDecoration(labelText: 'Meter Serial Number'),
            ),
            TextFormField(
              controller: deviceNameController,
              decoration: InputDecoration(labelText: 'Device Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isProcessing ? null : () async {
                await claimOwnership(context);
              },
              child: _isProcessing
                  ? Spinners.spinkitFadingCircle
                  : Text('Claim Ownership'),
            ),
          ],
        ),
      ),
    );
  }
}
