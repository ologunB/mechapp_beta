import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/libraries/custom_button.dart';
import 'package:mechapp/mechanic/mech_main.dart';
import 'package:mechapp/utils/my_models.dart';
import 'package:mechapp/utils/type_constants.dart';
import 'package:rave_flutter/rave_flutter.dart';

class MechWallet extends StatefulWidget {
  @override
  _MechWalletState createState() => _MechWalletState();
}

class _MechWalletState extends State<MechWallet> {
  String t5 = "--", t8 = "--";
  String t6 = "--", t7 = "--";
  var rootRef = FirebaseDatabase.instance.reference();

  Future getJobs() async {
    DatabaseReference dataRef = FirebaseDatabase.instance
        .reference()
        .child("All Jobs Collection")
        .child(mUID);

    await dataRef.once().then((snapshot) {
      var dATA = snapshot.value;

      //  setState(() async {
      t5 = dATA['Cash Payment Debt'];
      t8 = dATA['Completed Amount'];

      t6 = dATA['Pay pending Amount'];
      t7 = dATA['Payment Request'];
      // });
    });
  }

  Widget _buildFutureBuilder() {
    return Center(
      child: FutureBuilder(
        future: getJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              padding: EdgeInsets.all(20),
              //  alignment: Alignment.center,
              height: double.infinity,
              color: Color(0xb090A1AE),
              child: Column(children: <Widget>[
                  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Debt: ₦$t5",
                  style: TextStyle(
                      fontSize: 22,
                      color: primaryColor,
                      fontWeight: FontWeight.w900),
                ),
                SizedBox(width: 10),
                Text(
                  "Earning: ₦$t6",
                  style: TextStyle(
                      fontSize: 22,
                      color: primaryColor,
                      fontWeight: FontWeight.w900),
                ),
              ],
                  ),
                  SizedBox(height: 20),
                  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  onPress: () {
                    if (double.parse(t5) < 500) {
                      showCenterToast(
                          "You can't pay less than ₦500", context);
                      return;
                    }
                    payDebt(context);
                  },
                  title: "PAY DEBT",
                  iconLeft: false,
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
                CustomButton(
                  onPress: () {
                    if (double.parse(t5) < 500) {
                      showCenterToast(
                          "You can't WITHDRAW less than ₦500", context);
                      return;
                    }
                    withdraw(context);
                  },
                  title: "WITHDRAW",
                  iconLeft: false,
                  hasColor: true,
                  bgColor: Colors.deepOrange,
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ],
                  ),
                  Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Transactions",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
                  ),
                  trxs.length == 0
                ? Padding(
                  padding: const EdgeInsets.all(38.0),
                  child: emptyList("Transactions"),
                )
                : ListView.builder(
                    itemCount: trxs.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.black12)
                              ],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: ListTile(
                                title: Text(
                                  trxs[index].amount,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black),
                                ),
                                subtitle: Text(
                                  trxs[index].date,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ]),
            );
          }
          return CupertinoActivityIndicator(radius: 20);
        },
      ),
    );
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void payDebt(context) async {
    var initializer = RavePayInitializer(
        amount: double.parse(t5),
        publicKey: ravePublicKey,
        encryptionKey: raveEncryptKey)
      ..country = "NG"
      ..currency = "NGN"
      ..email = mEmail
      ..fName = mName
      ..lName = "lName"
      ..narration = "FABAT MANAGEMENT"
      ..txRef = "SCH${DateTime.now().millisecondsSinceEpoch}"
      ..acceptAccountPayments = false
      ..acceptCardPayments = true
      ..acceptAchPayments = false
      ..acceptGHMobileMoneyPayments = false
      ..acceptUgMobileMoneyPayments = false
      ..staging = false
      ..isPreAuth = true
      ..displayFee = true;

    RavePayManager()
        .prompt(context: context, initializer: initializer)
        .then((result) {
      if (result.status == RaveStatus.success) {
        doAfterSuccess(result.message);
      } else if (result.status == RaveStatus.cancelled) {
        if (mounted) {
          scaffoldKey.currentState.showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                "Closed!",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              backgroundColor: primaryColor,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else if (result.status == RaveStatus.error) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(
                  "Error",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
                content: Text(
                  "An error has occured ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              );
            });
      }

      print(result);
    });
  }

  void doAfterSuccess(String serverData) {
    final String ppA = "0";
    final String cA = ((double.parse(t8) * 5) + double.parse(t5)).toString();

    final Map<String, Object> allJobs = Map();
    allJobs.putIfAbsent("Cash Payment Debt", () => ppA);
    allJobs.putIfAbsent("Completed Amount", () => cA);

    String made =
        "You sent a payment of $t5 to the FABAT ADMIN, your debt has been cleared.";

    final Map<String, String> sentMessage = Map();
    sentMessage.putIfAbsent("notification_message", () => made);
    sentMessage.putIfAbsent("notification_time", () => thePresentTime());
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text(
              "Finishing processing",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 20),
            ),
            content: CupertinoActivityIndicator(radius: 20),
          );
        });
    rootRef
        .child("Notification Collection")
        .child("Mechanic")
        .child(mUID)
        .child(mUID)
        .set(sentMessage)
        .then((a) {
      rootRef
          .child("All Jobs Collection")
          .child(mUID)
          .update(allJobs)
          .then((a) {
        showToast("Payment Complete", context);
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => MechMainPage()));
      });
    });
  }

  TextEditingController _amountC = TextEditingController();

  bool isLoading = false;

  void processWithdraw() {
    String amount = _amountC.toString().trim();

    final String ppA = (double.parse(t6) - double.parse(amount)).toString();
    final String pR = (double.parse(t7) + double.parse(amount)).toString();

    final Map<String, Object> allJobs = Map();
    allJobs.putIfAbsent("Pay pending Amount", () => ppA);
    allJobs.putIfAbsent("Payment Request", () => pR);

    Map<String, String> pRequest = Map();
    allJobs.putIfAbsent("amount", () => amount);
    allJobs.putIfAbsent("uid", () => mUID);
    allJobs.putIfAbsent("date", () => thePresentTime());

    rootRef
        .child("Payment Request")
        .child("Pending")
        .child(mUID)
        .set(pRequest)
        .then((a) {
      rootRef
          .child("All Jobs Collection")
          .child(mUID)
          .update(allJobs)
          .then((a) {
        setState(() {
          t6 = ppA;
          t7 = pR;
          isLoading = false;
          showCenterToast("Request Made", context);
          Navigator.pushReplacement(context,
              CupertinoPageRoute(builder: (context) => MechMainPage()));
        });
      });
    });
  }

  void withdraw(context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              "How much do you want to withdraw?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: CupertinoTextField(
                placeholder: "Amount",
                placeholderStyle: TextStyle(
                    fontWeight: FontWeight.w300, color: Colors.black38),
                padding: EdgeInsets.all(10),
                maxLines: 1,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 20, color: Colors.black),
                controller: _amountC,
              ),
            ),
            actions: <Widget>[
              Center(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.red),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Cancel",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: primaryColor,
                  ),
                  child: FlatButton(
                    onPressed: () {
                      if (_amountC.text.isEmpty) {
                        showCenterToast("Enter a number", context);
                        return;
                      } else if (double.tryParse(_amountC.text) < 500) {
                        showCenterToast(
                            "You can't withdraw less than ₦500", context);
                        return;
                      }
                      processWithdraw();
                    },
                    child: Text(
                      "Proceed",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  List<EachTrx> trxs;
  StreamSubscription<Event> _onTrxAddedSubscription;

  @override
  void initState() {
    super.initState();
    trxs = new List();
    _onTrxAddedSubscription = trxReference.onChildAdded.listen(_onTrxAdded);
  }

  @override
  void dispose() {
    _onTrxAddedSubscription.cancel();
    super.dispose();
  }

  void _onTrxAdded(Event event) {
    setState(() {
      trxs.add(new EachTrx.fromSnapshot(event.snapshot));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(color: Color(0xb090A1AE), child: _buildFutureBuilder()),
    );
  }
}

final trxReference = FirebaseDatabase.instance
    .reference()
    .child("Payment Request")
    .child("Pending")
    .child(mUID);
