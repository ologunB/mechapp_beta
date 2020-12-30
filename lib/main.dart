import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/cus_main.dart';
import 'package:mechapp/log_in.dart';
import 'package:mechapp/mechanic/mech_main.dart';
import 'package:mechapp/notifiers/job_notifier.dart';
import 'package:mechapp/utils/type_constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
    create: (context) => JobNotifier(),
    child: MyApp(),
  ));
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
  }

  void assign() async {
    mUID = await uid;
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
