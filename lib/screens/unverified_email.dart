import 'package:flutter/material.dart';
import 'package:meterpro/services/authentication_service.dart';

class UnverifiedEmailPage extends StatelessWidget {

  AuthenticationService authenticationService=AuthenticationService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Email is Unverified',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Please verify your email address to access all features of our app.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
            var user= await authenticationService.resendActivationLink();
              if(user!=null){
                final snackBar = SnackBar(
                  backgroundColor:   Colors.green,
                  content: const Text("A verification link has been sent to your email"),
                  action: SnackBarAction(
                    textColor: Colors.white,
                    label: 'Dismiss',
                    onPressed: () {},
                  ),
                );
                ScaffoldMessenger.of(context)
                    .showSnackBar(snackBar);
              }
              },
              child: Text('Resend Verification Email'),
            ),
          ],
        ),
      ),
    );
  }
}
