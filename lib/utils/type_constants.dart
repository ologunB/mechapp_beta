import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mechapp/libraries/toast.dart';
import 'package:http/http.dart' as http;

String mUID, mEmail, mName, userType, mPhone;
Position currentLocation;
double whereLat, whereLong;

Color primaryColor = Color.fromARGB(255, 22, 58, 78);

Widget emptyList(String typeOf) {
  return Container(
   // height: double.infinity,
    width: double.infinity,
    alignment: Alignment.center,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.hourglass_empty,
          color: Colors.white,
          size: 30,
        ),
        Text(
          "No $typeOf!",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          textAlign: TextAlign.center,
        )
      ],
    ),
  );
}

List<String> specifyList = [
  "Audi",
  "BMW",
  "Chrysler",
  "Dodge",
  "Ford",
  "Honda",
  "Hyundai",
  "Jeep",
  "Kia",
  "Mazda",
  "Mercedes Benz",
  "Nissan",
  "Peugeot",
  "Porsche",
  "RAM",
  "Range Rover",
  "Suzuki",
  "Toyota",
  "Volkswagen"
];
List<String> categoryList = [
  "Accidented Vehicle",
  "Air Conditioner",
  "Brake System",
  "Brake pad replacement",
  "Call Us",
  "Car Scan",
  "Car Tint",
  "Electrician",
  "Engine Expert",
  "Exhaust System",
  "Locking & Keys/Security",
  "Oil & Filter Change",
  "Painter",
  "Panel Beater",
  "Tow trucks",
  "Upholstery & Interior",
  "Wheel Balancing & Alignment",
];

showEmptyToast(String aa, BuildContext context) {
  Toast.show("$aa cannot be empty", context,
      duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
  return;
}

showToast(String aa, BuildContext context) {
  Toast.show("$aa", context,
      duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
  return;
}

showCenterToast(String aa, BuildContext context) {
  Toast.show("$aa", context,
      duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
  return;
}

const chars = "abcdefghijklmnopqrstuvwxyz0123456789";

String randomString() {
  Random rnd = Random(DateTime.now().millisecondsSinceEpoch);
  String result = "";
  for (var i = 0; i < 12; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }
  return result;
}

String thePresentTime() {
  return DateFormat("MMM d, yyyy HH:mm:ss a").format(DateTime.now());
}

final commaFormat = new NumberFormat("#,##0", "en_US");
String raveEncryptKey = "FLWSECK_TEST3ba765b74b1f";
String ravePublicKey = "FLWPUBK_TEST-9ba09916a6e4e8385b9fb2036439beac-X";
String kGoogleMapKey = "AIzaSyBW3PTaSdgjmxTuUkEe0wLZZDNdnIcyVNQ";
String oneOnlineSignalKey = "0204afd4-6076-4902-8014-49def7d87337";

offKeyboard(context) {
  FocusScopeNode currentFocus = FocusScope.of(context);

  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}

Future sendSendNotification(String message, String toUID) async {
  String url = "https://onesignal.com/api/v1/notifications";
  var imgUrlString =
      "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/images%2Fmnmnmn.jpg?alt=media&token=048ad75f-308e-4ef0-9373-0d6f98f3fad7";

  var client = http.Client();

  var headers = {
    "Content-Type": "application/json; charset=utf-8",
    "Authorization": "Basic MzNiYjYyNjAtZmI3ZS00NTYwLTk5YzctY2Q0Yjc4NmEyYmYx"
  };

  var body = {
    "app_id": oneOnlineSignalKey,
    "headings": {"en": "New Notification"},
    "contents": {"en": message},
    "include_external_user_ids": [toUID],
    "android_background_layout": {
      "image": imgUrlString,
      "headings_color": "ff000000",
      "contents_color": "ff0000FF"
    }
  };

  await client
      .post(url, headers: headers, body: jsonEncode(body))
      .then((value) => (res) {
            return "Done";
          })
      .catchError((a) {
    print(a.toString());
    // showCenterToast("Error: " + a.toString(), context);
    return "Error";
  });

  return "Done";
}
