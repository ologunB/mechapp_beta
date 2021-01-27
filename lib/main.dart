import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/cus_main.dart';
import 'package:mechapp/log_in.dart';
import 'package:mechapp/mechanic/mech_main.dart';
import 'package:mechapp/utils/type_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyWrapper(),
      theme: ThemeData(
        fontFamily: 'Raleway',
        primaryColor: Color.fromARGB(255, 22, 58, 78),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyWrapper extends StatefulWidget {
  @override
  _MyWrapperState createState() => _MyWrapperState();
}

class _MyWrapperState extends State<MyWrapper> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<String> type, uid;

  @override
  void initState() {
    super.initState();
    type = _prefs.then((prefs) {
      return (prefs.getString('type'));
    });
    uid = _prefs.then((prefs) {
      return (prefs.getString('uid') ?? "mechUID");
    });
    assign();
    getPermissions();
  }

  void assign() async {
    mUID = await uid;
  }

  getPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: type,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            String _type = snapshot.data;
            if (_type == "Mechanic") {
              return MechMainPage();
            } else if (_type == "Customer") {
              return CusMainPage();
            } else {
              return LogOn();
            }
          }
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      "assets/images/app_back.jpg",
                    ),
                    fit: BoxFit.fill),
              ),
            ),
          );
        });
  }
}
