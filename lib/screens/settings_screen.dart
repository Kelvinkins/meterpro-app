import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import '../common/global.dart';
import '../services/authentication_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meterpro/common/static.dart' as Static;

import 'auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreen createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  final AuthenticationService authenticationService = AuthenticationService();

  void _launchURL(String url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          backgroundColor: Static.PrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SettingsList(
          sections: [
            // SettingsSection(
            //     title: const Text('Expenria Web',
            //         style: TextStyle(color: Static.PrimaryColor)),
            //     tiles: <SettingsTile>[
            //       SettingsTile.navigation(
            //         leading: const Icon(Icons.web_outlined),
            //         title: const Text('Use the web plaform'),
            //         value: const Text(''),
            //         onPressed: (context) {
            //           _launchURL("https://meterpro.web.app");
            //         },
            //       ),
            //     ]),
            SettingsSection(
                // title: const Text(
                //   'Get in touch',
                //   style: TextStyle(color: Static.PrimaryColor),
                // ),
                tiles: <SettingsTile>[
                  // SettingsTile.navigation(
                  //   leading: const Icon(Icons.help_center_outlined),
                  //   title: const Text('Help center'),
                  //   value: const Text(''),
                  //   onPressed: (context) {
                  //     _launchURL("https://meterpro.web.app/help");
                  //   },
                  // ),
                  // SettingsTile.navigation(
                  //   leading: const Icon(Icons.privacy_tip_outlined),
                  //   title: const Text('Privacy Policy'),
                  //   value: const Text(''),
                  //   onPressed: (context) {
                  //     _launchURL("https://meterpro.web.app/privacy-policy");
                  //   },
                  // ),
                  // SettingsTile.navigation(
                  //   leading: const Icon(Icons.info_outline_rounded),
                  //   title: const Text('About meterpro'),
                  //   value: const Text(''),
                  //   onPressed: (context) {
                  //     _launchURL("https://meterpro.web.app/about");
                  //   },
                  // ),
                  //
                  SettingsTile.navigation(
                    leading:
                        const Icon(Icons.power_settings_new, color: Colors.red),
                    title: const Text(
                      'Log out',
                      style: TextStyle(color: Colors.red),
                    ),
                    value: const Text('Sign Out'),
                    onPressed: (context) async {
                      Navigator.pop(context);
                      await authenticationService.logout(context);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ));
                    },
                  ),
                ])
          ],
        ));
  }
}
