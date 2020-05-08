import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rave/flutter_rave.dart';
import 'package:mechapp/utils/my_models.dart';
import 'package:mechapp/utils/type_constants.dart';

import 'add_car_activity.dart';
import 'libraries/custom_button.dart';
import 'libraries/custom_dialog.dart';

class PayMechanicPage extends StatefulWidget {
  final EachMechanic mechanic;
  PayMechanicPage({Key key, @required this.mechanic}) : super(key: key);
  @override
  _PayMechanicPageState createState() => _PayMechanicPageState();
}

class _PayMechanicPageState extends State<PayMechanicPage> {
  String t3, t4;

  final carsReference =
      FirebaseDatabase.instance.reference().child("Car Collection").child(mUID);

  List<Car> cars;
  StreamSubscription<Event> _onCarAddedSubscription;

  @override
  void initState() {
    super.initState();
    cars = new List();
    getJobs();
    _onCarAddedSubscription = carsReference.onChildAdded.listen(_onCarAdded);
  }

  @override
  void dispose() {
    _onCarAddedSubscription.cancel();
    super.dispose();
  }

  void _onCarAdded(Event event) {
    setState(() {
      cars.add(new Car.fromSnapshot(event.snapshot));
    });
  }

  Future<List<String>> getJobs() async {
    DatabaseReference dataRef = FirebaseDatabase.instance
        .reference()
        .child("All Jobs Collection")
        .child(widget.mechanic.uid);

    await dataRef.once().then((snapshot) {
      var dATA = snapshot.value;

      setState(() async {
        t3 = dATA['Pending Job'];
        t4 = dATA['Pending Amount'];
      });
    });

    List<String> list = [];
    return list;
  }

  _pay(BuildContext context) {
    final _rave = RaveCardPayment(
      isDemo: true,
      //        .setEncryptionKey("ab5cfe0059e5253250eb68a4")
      //       .setPublicKey("FLWPUBK-37eaceebb259b1537c67009339575c01-X")
      encKey: "FLWSECK_TEST3ba765b74b1f",
      publicKey: "FLWPUBK_TEST-9ba09916a6e4e8385b9fb2036439beac-X",
      transactionRef: "SCH${DateTime.now().millisecondsSinceEpoch}",
      amount: double.parse(amountController.text),
      email: mEmail,
      onSuccess: (response) {
        doAfterSuccess(response);

        /*   if (mounted) {
          scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text("Transaction Sucessful!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
              action: SnackBarAction(label: "Done", onPressed: () {}),
            ),
          );
        }*/
      },
      onFailure: (err) {


       },
      onClosed: () {
        if (mounted) {
          scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text("Closed!", style: TextStyle(color: Colors.white, fontSize: 18),),
              backgroundColor: primaryColor,
              duration: Duration(seconds: 3),
             ),
          );
        }
      },
      context: context,
    );

    _rave.process();
  }

  bool isLoading = false;

  TextEditingController carController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  void doAfterSuccess(String serverData) {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    EachMechanic mech = widget.mechanic;
    String TransactionID = randomString();
    setState(() {
      isLoading = true;
    });

    // To get the current time
    String now = thePresentTime();
    String amount_ = amountController.text;

    //updates jobs on both side
    final Map<String, String> valuesToCustomer = Map();
    valuesToCustomer.putIfAbsent("Mech Name", () => mech.name);
    valuesToCustomer.putIfAbsent("Customer Name", () => mName);
    valuesToCustomer.putIfAbsent("Mech UID", () => mech.uid);
    valuesToCustomer.putIfAbsent("Mech Number", () => mech.phoneNumber);
    valuesToCustomer.putIfAbsent("Mech Image", () => mech.image);
    valuesToCustomer.putIfAbsent("Trans Amount", () => amount_);
    valuesToCustomer.putIfAbsent("Trans Time", () => now);
    valuesToCustomer.putIfAbsent("Car Type", () => carController.text);
    valuesToCustomer.putIfAbsent("Server Confirmation", () => serverData);
    valuesToCustomer.putIfAbsent("Trans Description", () => "description_");
    valuesToCustomer.putIfAbsent("Trans ID", () => TransactionID.toString());
    valuesToCustomer.putIfAbsent("Trans Confirmation", () => "Unconfirmed");
    valuesToCustomer.putIfAbsent("Mech Confirmation", () => "Unconfirmed");
    valuesToCustomer.putIfAbsent("hasReviewed", () => "False");

    Map<String, String> valuesToMech = Map();
    valuesToMech.putIfAbsent("Customer UID", () => mUID);
    valuesToMech.putIfAbsent("Customer Name", () => mName);
    valuesToMech.putIfAbsent("Customer Number", () => "Cus number");
    valuesToMech.putIfAbsent("Trans Amount", () => amount_);
    valuesToMech.putIfAbsent("Trans Time", () => now);
    valuesToMech.putIfAbsent("Server Confirmation", () => serverData);
    valuesToMech.putIfAbsent("Car Type", () => carController.text);
    valuesToMech.putIfAbsent("Trans Description", () => "description_");
    valuesToMech.putIfAbsent("Trans ID", () => TransactionID.toString());
    valuesToMech.putIfAbsent("Trans Confirmation", () => "Unconfirmed");
    valuesToMech.putIfAbsent("Mech Confirmation", () => "Unconfirmed");

    int aa = int.parse(t3) + 1;
    int bb = int.parse(t4) + int.parse(amount_);

    final Map<String, String> updateJobs = Map();
    updateJobs.putIfAbsent("Pending Job", () => aa.toString());
    updateJobs.putIfAbsent("Pending Amount", () => bb.toString());

    String received = "You have a pending payment of ₦" +
        amount_ +
        " by " +
        mName +
        " and shall be available if confirmed by the customer. Thanks for using FABAT";

    String made = "You have made a payment of ₦" +
        amount_ +
        " to " +
        mech.name +
        " for " +
        carController.text +
        " and has been withdrawn from your Card. Thanks for using FABAT";

    final Map<String, String> sentMessage = Map();
    sentMessage.putIfAbsent("notification_message", () => made);
    sentMessage.putIfAbsent("notification_time", () => now);

    final Map<String, String> receivedMessage = Map();
    receivedMessage.putIfAbsent("notification_message", () => received);
    receivedMessage.putIfAbsent("notification_time", () => now);

    databaseReference
        .child("Jobs Collection")
        .child("Mechanic")
        .child(mech.uid)
        .child(TransactionID)
        .set(valuesToMech);
    databaseReference
        .child("Notification Collection")
        .child("Mechanic")
        .child(mech.uid)
        .push()
        .set(receivedMessage);
    databaseReference
        .child("Jobs Collection")
        .child("Customer")
        .child(mUID)
        .child(TransactionID)
        .set(valuesToCustomer);
    databaseReference
        .child("Notification Collection")
        .child("Customer")
        .child(mUID)
        .push()
        .set(sentMessage);

    databaseReference
        .child("All Jobs Collection")
        .child(mech.uid)
        .update(updateJobs);
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text("Pay Mechanic"),
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Color(0xb090A1AE)),
        child: ListView(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: widget.mechanic.image,
                height: 100,
                width: 100,
                placeholder: (context, url) => Image(
                  image: AssetImage("assets/images/person.png"),
                  height: 100,
                  width: 100,
                ),
                errorWidget: (context, url, error) => Image(
                  image: AssetImage("assets/images/person.png"),
                  height: 100,
                  width: 100,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                widget.mechanic.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: FlatButton(
                onPressed: () {
                  scaffoldKey.currentState.showBottomSheet(
                    (context) => Container(
                      height: MediaQuery.of(context).size.height / 3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CustomButton(
                            title: "   Add Car   ",
                            onPress: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  fullscreenDialog: true,
                                  builder: (context) {
                                    return AddCarActivity();
                                  },
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: MediaQuery.removePadding(
                              child: cars.length == 0
                                  ? emptyList("Cars")
                                  : ListView.builder(
                                      itemCount: cars.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            carController.text =
                                                cars[index].brand +
                                                    ", " +
                                                    cars[index].model +
                                                    ", " +
                                                    cars[index].date;
                                            setState(() {});
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black12)
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Center(
                                                child: ListTile(
                                                  title: Row(
                                                    children: <Widget>[
                                                      Text(
                                                        cars[index].brand,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Text(
                                                        " - ${cars[index].date}",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.black54),
                                                      )
                                                    ],
                                                  ),
                                                  subtitle: Text(
                                                    cars[index].model,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  leading: CachedNetworkImage(
                                                    imageUrl: cars[index].img,
                                                    height: 50,
                                                    width: 50,
                                                    placeholder: (context,
                                                            url) =>
                                                        CupertinoActivityIndicator(
                                                            radius: 10),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration:
                                                          new BoxDecoration(
                                                        image:
                                                            new DecorationImage(
                                                          fit: BoxFit.fill,
                                                          image: AssetImage(
                                                              "assets/images/car.png"),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  trailing: IconButton(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        size: 30,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              true,
                                                          builder: (_) =>
                                                              CustomDialog(
                                                            title:
                                                                "Are you sure you want to remove the car from garage?",
                                                            onClicked: () {
                                                              Navigator.pop(
                                                                  context);
                                                              carsReference
                                                                  .child(cars[
                                                                          index]
                                                                      .id)
                                                                  .remove();
                                                              setState(() {
                                                                cars.removeAt(
                                                                    index);
                                                              });
                                                            },
                                                            includeHeader: true,
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              context: context,
                            ),
                          ),
                        ],
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  );
                },
                child: CupertinoTextField(
                  prefix: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.add),
                  ),
                  placeholder: "Add Car",
                  enabled: false,
                  controller: carController,
                  padding: EdgeInsets.all(10),
                  style: TextStyle(fontSize: 22),
                  onTap: () {},
                  keyboardType: TextInputType.numberWithOptions(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: CupertinoTextField(
                prefix: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image(
                    image: AssetImage("assets/images/naira_icon.png"),
                    height: 30,
                  ),
                ),
                placeholder: "Amount",
                controller: amountController,
                padding: EdgeInsets.all(10),
                style: TextStyle(fontSize: 22),
                keyboardType: TextInputType.numberWithOptions(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Ensure you have agreed on Job description and price with the mechanic before you proceed with payment",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                    fontWeight: FontWeight.w700),
              ),
            ),
            CustomButton(
              title: "   PROCEED   ",
              onPress: () {
                if (carController.text.isEmpty ||
                    amountController.text.isEmpty) {
                  showToast("Fill all fields", context);
                  return;
                }
                _pay(context);
              },
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
              iconLeft: false,
            ),
          ],
        ),
      ),
    );
  }
}
