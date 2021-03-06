import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/cus_main.dart';

class OrderConfirmedDone extends StatefulWidget {
  final String from;

  const OrderConfirmedDone({Key key, this.from = ""}) : super(key: key);

  @override
  _OrderConfirmedDoneState createState() => _OrderConfirmedDoneState();
}

class _OrderConfirmedDoneState extends State<OrderConfirmedDone> {
  @override
  void initState() {
    widget.from == "Cart"
        ? Future.delayed(Duration(seconds: 5)).then((val) {
            Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(builder: (context) => CusMainPage()),
                (Route<dynamic> route) => false);
          })
        : Future.delayed(Duration(seconds: 5)).then((val) {
            Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(builder: (context) => CusMainPage()),
                (Route<dynamic> route) => false);
          });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => CusMainPage()),
              (Route<dynamic> route) => false);
        },
        child: Container(
          padding: EdgeInsets.all(50),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/images/confirmed.png"),
              SizedBox(height: 30),
              Text(
                "Order Confirmed, In queue for confirmation",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                    color: Colors.lightGreen,
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => CusMainPage()),
                          (Route<dynamic> route) => false);
                    },
                    child: Text(
                      "CLOSE",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    )),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
