import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechapp/libraries/custom_dialog.dart';
import 'package:mechapp/utils/type_constants.dart';

class JobModel {
  String otherPersonName,
      phoneNumber,
      amount,
      time,
      cusStatus,
      mechStatus,
      transactID,
      serverCon,
      otherPersonUID;

  JobModel(
      {this.otherPersonName,
      this.phoneNumber,
      this.amount,
      this.time,
      this.cusStatus,
      this.mechStatus,
      this.otherPersonUID,
      this.serverCon,
      this.transactID});
}

class MechJobsF extends StatefulWidget {
  @override
  _MechJobsFState createState() => _MechJobsFState();
}

var rootRef = FirebaseDatabase.instance.reference();
List<JobModel> list = [];
String a_, b_, c_, d_, e_, f_, g_, h_;

class _MechJobsFState extends State<MechJobsF> {
  Stream<List<JobModel>> _getJobs() async* {
    DatabaseReference dataRef =
        rootRef.child("Jobs Collection").child(userType).child(mUID);

    await dataRef.once().then((snapshot) {
      var kEYS = snapshot.value.keys;
      var dATA = snapshot.value;

      getMechVals();
      list.clear();
      for (var index in kEYS) {
        String tempName = dATA[index]['Customer Name'];
        String tempPrice = dATA[index]['Trans Amount'];
        String tempCusStatus = dATA[index]['Trans Confirmation'];
        String tempNumber = dATA[index]['Customer Number'];
        String tempTime = dATA[index]['Trans Time'];
        String tempMechStatus = dATA[index]['Mech Confirmation'];
        String tempCusUID = dATA[index]['Customer UID'];
        String tempTransactID = dATA[index]['Trans ID'];
        String tempServerCon = dATA[index]['Server Confirmation'];

        list.add(
          JobModel(
              serverCon: tempServerCon,
              otherPersonName: tempName,
              amount: tempPrice,
              phoneNumber: tempNumber,
              cusStatus: tempCusStatus,
              time: tempTime,
              mechStatus: tempMechStatus,
              otherPersonUID: tempCusUID,
              transactID: tempTransactID),
        );
      }
    });

    yield list;
  }

  Widget _buildFutureBuilder() {
    return Center(
      child: StreamBuilder<List<JobModel>>(
        stream: _getJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return list.length == 0
                ? emptyList("Jobs")
                : Container(
                    color: Color(0xb090A1AE),
                    height: double.infinity,
                    child: StaggeredGridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      children: list.map<Widget>((item) {
                        return Center(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    item.otherPersonName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.deepPurple),
                                  ),
                                  Text(
                                    item.phoneNumber,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  Text(
                                    "₦" + item.amount,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Center(
                                    child: Text(
                                      item.time,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 22, color: Colors.black),
                                    ),
                                  ),
                                  ButtonConfirm(index: item),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      staggeredTiles: list
                          .map<StaggeredTile>((_) => StaggeredTile.fit(2))
                          .toList(),
                      mainAxisSpacing: 3.0,
                      crossAxisSpacing: 4.0,
                    ),
                  );
          }
          return CupertinoActivityIndicator(radius: 20);
        },
      ),
    );
  }

  getMechVals() {
    rootRef
        .child("All Jobs Collection")
        .child(mUID)
        .once()
        .then((snapshot) async {
      var dATA = snapshot.value;

      a_ = dATA["Total Job"];
      b_ = dATA["Total Amount"];
      c_ = dATA["Pending Job"];
      d_ = dATA["Pending Amount"];
      e_ = dATA['Cash Payment Debt'];
      f_ = dATA['Pay pending Amount'];
      g_ = dATA['Payment Request'];
      h_ = dATA['Completed Amount'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      color: Color(0xb090A1AE),
      child: _buildFutureBuilder(),
    );
  }
}

class ButtonConfirm extends StatefulWidget {
  final JobModel index;

  ButtonConfirm({this.index});

  @override
  _ButtonConfirmState createState() => _ButtonConfirmState();
}

class _ButtonConfirmState extends State<ButtonConfirm> {
  String status = "Confirm Job?";
  Color statusColor = Colors.blue;

  void confirmJob(JobModel index, aSetState, context) async {
    String otherUID = index.otherPersonUID;
    String transactID = index.transactID;
    String amount = index.amount;
    String nameOfMech = index.otherPersonName;
    String serverCon = index.serverCon;

    try {
        a_ = (int.parse(a_) + 1).toString(); // Total Jobs
      b_ = (int.parse(b_) + int.parse(amount)).toString(); // Total Amount
      c_ = (int.parse(c_) - 1).toString(); // Pending Jobs
      d_ = (int.parse(d_) - int.parse(amount)).toString(); // Pending Amount
      e_ =
      (int.parse(e_) + (int.parse(amount) / 5).round()).toString(); // Cash Payment debt
      f_ = (int.parse(f_) + int.parse(amount)).toString(); // Pay pending Amount

      final Map<String, Object> updateJobs = Map();
      updateJobs.putIfAbsent("Total Job", () => a_);
      updateJobs.putIfAbsent("Total Amount", () => b_);
      updateJobs.putIfAbsent("Pending Job", () => c_);
      updateJobs.putIfAbsent("Pending Amount", () => d_);

      if (serverCon == "By Cash") {
        updateJobs.putIfAbsent("Cash Payment Debt", () => e_);
      } else {
        updateJobs.putIfAbsent("Pay pending Amount", () => f_);
      }

      String sent = "Your payment of ₦" +
          amount +
          " to " +
          nameOfMech +
          " for " +
          " has been confirmed by admin. Thanks for using FABAT";

      String received = "You have a confirmed payment of ₦" +
          amount +
          " by " +
          mName +
          " and shall be available soonest. Thanks for using FABAT";

      final Map<String, Object> sentMessage = Map();
      sentMessage.putIfAbsent("notification_message", () => sent);
      sentMessage.putIfAbsent("notification_time", () => thePresentTime());
      sentMessage.putIfAbsent(
          "Timestamp", () => DateTime.now().millisecondsSinceEpoch);

      final Map<String, Object> receivedMessage = Map();
      receivedMessage.putIfAbsent("notification_message", () => received);
      receivedMessage.putIfAbsent("notification_time", () => thePresentTime());
      receivedMessage.putIfAbsent(
          "Timestamp", () => DateTime.now().millisecondsSinceEpoch);

      Map<String, Object> valuesToMech = Map();
      valuesToMech.putIfAbsent("Mech Confirmation", () => "Confirmed");

      rootRef
          .child("Notification Collection")
          .child("Mechanic")
          .child(mUID)
          .child(transactID)
          .set(receivedMessage)
          .then((value) {
        rootRef
            .child("Jobs Collection")
            .child("Mechanic")
            .child(mUID)
            .child(transactID)
            .update(valuesToMech);
      });

        sendSendNotification(sent, otherUID);

        rootRef
          .child("Notification Collection")
          .child("Customer")
          .child(otherUID)
          .push()
          .set(sentMessage)
          .then((value) {
        rootRef
            .child("Jobs Collection")
            .child("Customer")
            .child(otherUID)
            .child(transactID)
            .update(valuesToMech);
        rootRef.child("All Jobs Collection").child(mUID).update(updateJobs);
      });

      aSetState(() {
        bool isConfirmed = widget.index.mechStatus == "Confirmed";
        status = isConfirmed ? "RATE MECH." : "PENDING!";
        statusColor = isConfirmed ? Colors.teal : Colors.red;
      });
      Navigator.pop(context);
      showToast("Confirmed", context);
    } catch (exp) {
      showToast("Getting values. Try again...", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index.cusStatus == "Confirmed" &&
        widget.index.mechStatus == "Confirmed") {
      status = "COMPLETED!";
      statusColor = Colors.black12;
    } else if (widget.index.mechStatus == "Confirmed") {
      status = "PENDING!";
      statusColor = Colors.red;
    } else {
      status = "Confirm Job?";
      statusColor = Colors.blue;
    }
    return StatefulBuilder(
      builder: (context, _setState) => Center(
        child: RaisedButton(
          color: statusColor,
          onPressed: status == "Confirm Job?"
              ? () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => CustomDialog(
                      title: "Are you sure you want to confirm the Customer?",
                      onClicked: () {
                       // showCenterToast(widget.index.otherPersonUID, context);
                        confirmJob(widget.index, _setState, context);
                      },
                      includeHeader: true,
                    ),
                  );
                }
              : () {},
          child: Padding(
            padding: EdgeInsets.all(6.0),
            child: Text(
              status,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
