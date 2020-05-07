import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rave/flutter_rave.dart';
import 'package:mechapp/utils/my_models.dart';
import 'package:mechapp/utils/type_constants.dart';

import 'libraries/custom_button.dart';

class PayMechanicPage extends StatefulWidget {
  final EachMechanic mechanic;
  PayMechanicPage({Key key, @required this.mechanic}) : super(key: key);
  @override
  _PayMechanicPageState createState() => _PayMechanicPageState();
}

class _PayMechanicPageState extends State<PayMechanicPage> {
/*
  processTransaction() async {
    // Get a reference to RavePayInitializer
    var initializer = RavePayInitializer(
        amount: 500,
        publicKey: "FLWPUBK-5782e04d7522253c79dba17b7e94e754-X",
        encryptionKey: "e4c8352d12b797aa9fefae22")
      ..country = "NG"
      ..currency = "NGN"
      ..email = "customer@email.com"
      ..fName = "Ciroma"
      ..lName = "Adekunle"
      ..narration = "payment for service" ?? ''
      ..txRef = "Text Reference"
      // ..subAccounts = subAccounts
      //  ..acceptMpesaPayments = acceptMpesaPayment
      ..acceptAccountPayments = true
      ..acceptCardPayments = true
      // ..acceptAchPayments = acceptAchPayments
      //  ..acceptGHMobileMoneyPayments = acceptGhMMPayments
      //  ..acceptUgMobileMoneyPayments = acceptUgMMPayments
      ..staging = true
      ..isPreAuth = true
      ..displayFee = false;

    // Initialize and get the transaction result
    RaveResult response = await RavePayManager()
        .prompt(context: context, initializer: initializer);
  }
*/

  _pay(BuildContext context) {
    final _rave = RaveCardPayment(
      //isDemo: true,
      encKey: "c53e399709de57d42e2e36ca",
      publicKey: "FLWPUBK-d97d92534644f21f8c50802f0ff44e02-X",
      transactionRef: "SCH${DateTime.now().millisecondsSinceEpoch}",
      amount: 100,
      email: "ologunbabatope@gmail.com",
      onSuccess: (response) {
        print("$response");
        print("Transaction Successful");

        if (mounted) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("Transaction Sucessful!"),
              backgroundColor: Colors.green,
              duration: Duration(
                seconds: 5,
              ),
            ),
          );
        }
      },
      onFailure: (err) {
        print("$err");
        print("Transaction failed");
      },
      onClosed: () {
        print("Transaction closed");
      },
      context: context,
    );

    _rave.process();
  }

  TextEditingController carController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  List catBoolList = List();
  List tempCatBoolList = List();
  @override
  Widget build(BuildContext context) {
    for (String item in widget.mechanic.categories) {
      catBoolList.add(false);
    }
    return Scaffold(
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
          //  height: MediaQuery.of(context).size.height,
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
                  ),
                  errorWidget: (context, url, error) => Image(
                    image: AssetImage("assets/images/person.png"),
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
                padding: EdgeInsets.all(5.0),
                child: CupertinoTextField(
                  prefix: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.add),
                  ),
                  placeholder: "Add Car",
                  enabled: false,
                  padding: EdgeInsets.all(10),
                  style: TextStyle(fontSize: 22),
                  keyboardType: TextInputType.numberWithOptions(),
                  clearButtonMode: OverlayVisibilityMode.editing,
                ),
              ),
              descDropdown(context),
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
                  padding: EdgeInsets.all(10),
                  style: TextStyle(fontSize: 22),
                  keyboardType: TextInputType.numberWithOptions(),
                  clearButtonMode: OverlayVisibilityMode.editing,
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
        ));
  }

  Widget descDropdown(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: CupertinoTextField(
        prefix: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image(
            image: AssetImage("assets/images/description.png"),
            height: 30,
          ),
        ),
        suffix: Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: FlatButton(
            onPressed: () {
              FocusScope.of(context).unfocus();

              showDialog(
                context: context,
                builder: (_) => CupertinoAlertDialog(
                  title: Text(
                    "Choose Category",
                    style: TextStyle(fontSize: 20),
                  ),
                  content: Container(
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: ListView.builder(
                      itemCount: catBoolList.length,
                      itemBuilder: (context, index) {
                        tempCatBoolList = catBoolList;
                        return Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Material(
                            child: StatefulBuilder(
                              builder: (context, _setState) => CheckboxListTile(
                                title: Text(
                                  widget.mechanic.categories[index],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 18),
                                ),
                                value: catBoolList[index],
                                onChanged: (e) {
                                  _setState(
                                    () {
                                      catBoolList[index] = !catBoolList[index];
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  actions: <Widget>[
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.red),
                          child: FlatButton(
                            onPressed: () {
                              setState(() {
                                catBoolList = tempCatBoolList;
                              });
                              Navigator.of(context).pop();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                Expanded(
                                  child: Text(
                                    "Cancel",
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    CustomButton(
                      title: "OK",
                      onPress: () {
                        setState(() {
                          List<String> aTempList = [];
                          int intI = 0;
                          for (bool item in catBoolList) {
                            if (item == true) {
                              aTempList.add(widget.mechanic.categories[intI]);
                            }
                            intI++;
                          }
                          descController.text = aTempList
                              .toString()
                              .substring(1, aTempList.toString().length - 1);
                        });
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.done,
                        color: Colors.white,
                      ),
                      iconLeft: false,
                    ),
                  ],
                ),
              );
            },
            child: Text(
              "SELECT",
              style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 22, 58, 78),
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        placeholder: "Description",
        padding: EdgeInsets.all(10),
        style: TextStyle(fontSize: 22),
        clearButtonMode: OverlayVisibilityMode.editing,
      ),
    );
  }
}
