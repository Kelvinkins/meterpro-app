import 'package:firebase_messaging/firebase_messaging.dart';


class Global {
  static String refreshToken = "";
  static bool? isMock = false;
  static dynamic user;
  static List<dynamic> unvettedData = [];
  static List<dynamic> data = [];

  //expenira_inter
  static String expeniraInter = "ca-app-pub-2109400871305297/8646076276";

  //expenira_banner
  static String expeniraBanner = "ca-app-pub-2109400871305297/2265851821";


  static Future<String?> getDeviceId() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    return token;
  }
}
