import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/cus_main.dart';
import 'package:mechapp/dropdown_noti_cate.dart';
import 'package:mechapp/get_location_from_address.dart';
import 'package:mechapp/mechanic/mech_main.dart';
import 'package:mechapp/select_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'libraries/custom_button.dart';
import 'libraries/show_exception_alert_dialog.dart';
import 'utils/type_constants.dart';

TabController _tabController;
FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
DatabaseReference _dataRef = FirebaseDatabase.instance.reference();

class LogOn extends StatefulWidget {
  @override
  _LogOnState createState() => _LogOnState();
}

class _LogOnState extends State<LogOn> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.white, size: 28),
          centerTitle: true,
          title: TabBar(
            controller: _tabController,
            unselectedLabelColor: Colors.blueAccent,
            labelColor: Colors.white,
            labelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
            indicatorColor: Colors.white,
            indicator: BoxDecoration(),
            tabs: [
              Tab(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Sign In",
                  ),
                ),
              ),
              Tab(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Sign Up",
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  "assets/images/bg_image.jpg",
                ),
                fit: BoxFit.fill),
          ),
          child: TabBarView(
            children: [SignInPage(), SignUpPage()],
            controller: _tabController,
          ),
        ),
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _inEmail = TextEditingController();
  TextEditingController _inPass = TextEditingController();
  TextEditingController _inForgotPass = TextEditingController();
  bool isLoading = false;
  bool forgotPassIsLoading = false;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future signIn(String email, String password) async {
    setState(() {
      isLoading = true;
    });
    await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      FirebaseUser user = value.user;

      if (value.user != null) {
        if (!value.user.isEmailVerified) {
          setState(() {
            isLoading = false;
          });
          showToast("Email not verified", context);
          _firebaseAuth.signOut();
          return;
        }
        Firestore.instance
            .collection('All')
            .document(user.uid)
            .get()
            .then((document) {
          String type = document.data["Type"];
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (context) {
                return type == "Customer" ? CusMainPage() : MechMainPage();
              },
            ),
          );

          String uid = type == "Customer" ? "Uid" : "Mech Uid";
          putInDB(type, document.data[uid], document.data["Email"],
              document.data["Company Name"]);

          showToast("Logged in", context);
        }).catchError((e) {
          setState(() {
            isLoading = false;
          });
          showExceptionAlertDialog(
              context: context, exception: e, title: "Error");
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showToast("User doesn't exist", context);
      }
      return;
    }).catchError((e) {
      showExceptionAlertDialog(context: context, exception: e, title: "Error");
      setState(() {
        isLoading = false;
      });
      return;
    });
  }

  Future putInDB(String type, String uid, String email, String name) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      prefs.setBool("isLoggedIn", true);
      prefs.setString("uid", uid);
      prefs.setString("email", email);
      prefs.setString("name", name);
      prefs.setString("type", type);
    });
    _firebaseAuth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(18.0),
        child: Center(
            child: Card(
                elevation: 5,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 25.0),
                    child: SingleChildScrollView(
                        child: Container(
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: 8.0),
                                          child: Text(
                                            "Sign In",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: primaryColor,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CupertinoTextField(
                                          controller: _inEmail,
                                          placeholder: "Email",
                                          placeholderStyle: TextStyle(
                                              fontWeight: FontWeight.w400),
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          padding: EdgeInsets.all(10),
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CupertinoTextField(
                                          controller: _inPass,
                                          placeholder: "Password",
                                          padding: EdgeInsets.all(10),
                                          placeholderStyle: TextStyle(
                                              fontWeight: FontWeight.w400),
                                          obscureText: true,
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black),
                                        ),
                                      ),
                                      MaterialButton(
                                        onPressed: () {
                                          showDialog(
                                            barrierDismissible: true,
                                            context: context,
                                            builder: (_) =>
                                                CupertinoAlertDialog(
                                              title: Column(
                                                children: <Widget>[
                                                  Text("Enter Email"),
                                                ],
                                              ),
                                              content: CupertinoTextField(
                                                controller: _inForgotPass,
                                                placeholder: "Email",
                                                padding: EdgeInsets.all(10),
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                placeholderStyle: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w300),
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black),
                                              ),
                                              actions: <Widget>[
                                                Center(
                                                  child: StatefulBuilder(
                                                    builder:
                                                        (context, _setState) =>
                                                            CustomButton(
                                                      title: forgotPassIsLoading
                                                          ? ""
                                                          : "Reset Password",
                                                      onPress:
                                                          forgotPassIsLoading
                                                              ? null
                                                              : () async {
                                                                  setState(() {
                                                                    forgotPassIsLoading =
                                                                        true;
                                                                  });
                                                                  await _firebaseAuth
                                                                      .sendPasswordResetEmail(
                                                                          email: _inForgotPass
                                                                              .text)
                                                                      .then(
                                                                          (value) {
                                                                    _setState(
                                                                        () {
                                                                      forgotPassIsLoading =
                                                                          true;
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                    showCenterToast(
                                                                        "Reset Mail Sent",
                                                                        context);
                                                                  });
                                                                },
                                                      icon: forgotPassIsLoading
                                                          ? CupertinoActivityIndicator(
                                                              radius: 20)
                                                          : Icon(
                                                              Icons
                                                                  .arrow_forward,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      iconLeft: false,
                                                      hasColor:
                                                          forgotPassIsLoading
                                                              ? true
                                                              : false,
                                                      bgColor: Colors.blueGrey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Forgot Password?",
                                          style: TextStyle(
                                              color: Colors.indigo,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Center(
                                        child: CustomButton(
                                          title: isLoading ? "" : "  SIGN IN  ",
                                          onPress: isLoading
                                              ? null
                                              : () {
                                                  if (_inEmail.text
                                                      .toString()
                                                      .isEmpty) {
                                                    showEmptyToast(
                                                        "Email", context);
                                                    return;
                                                  } else if (_inPass.text
                                                      .toString()
                                                      .isEmpty) {
                                                    showEmptyToast(
                                                        "Password", context);
                                                    return;
                                                  }
                                                  signIn(_inEmail.text,
                                                      _inPass.text);
                                                },
                                          icon: isLoading
                                              ? CupertinoActivityIndicator(
                                                  radius: 20)
                                              : Icon(
                                                  Icons.arrow_forward,
                                                  color: Colors.white,
                                                ),
                                          iconLeft: false,
                                          hasColor: isLoading ? true : false,
                                          bgColor: Colors.blueGrey,
                                        ),
                                      ),
                                    ]))))))));
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int _switchIndex = 1;
  String _switchText = "Register as Mechanic";
  bool _switchBool = false;
  List<Widget> signUps = [
    CusSignUp(),
    MechSignUp(),
  ];
  Widget currentWidget = CusSignUp();
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Center(child: currentWidget),
        Padding(
          padding: EdgeInsets.all(11.0),
          child: CustomButton(
            title: _switchText,
            onPress: () {
              setState(() {
                _switchIndex = _switchBool ? 0 : 1;
                _switchText =
                    _switchBool ? "Register as Mechanic" : "Register as User";
                _switchBool = !_switchBool;
                currentWidget = signUps[_switchIndex];
              });
            },
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            iconLeft: false,
          ),
        ),
      ],
    );
  }
}

class CusSignUp extends StatefulWidget {
  @override
  _CusSignUpState createState() => _CusSignUpState();
}

class _CusSignUpState extends State<CusSignUp> {
  TextEditingController _upEmail = TextEditingController();
  TextEditingController _upPass = TextEditingController();
  TextEditingController _upName = TextEditingController();
  TextEditingController _upPhoNum = TextEditingController();
  bool isLoading = false;

  List<bool> categoryBool, specBool, tempSpecBool, tempCategoryBool;

  Future cusSignUp(String email, String password) async {
    setState(() {
      isLoading = true;
    });
    await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      FirebaseUser user = value.user;

      if (value.user != null) {
        user.sendEmailVerification().then((verify) {
          Map<String, Object> mData = Map();
          mData.putIfAbsent("Company Name", () => _upName.text);
          mData.putIfAbsent("Phone Number", () => _upPhoNum.text);
          mData.putIfAbsent("Email", () => _upEmail.text);
          mData.putIfAbsent("Type", () => "Customer");
          mData.putIfAbsent("Uid", () => user.uid);

          Firestore.instance
              .collection("Customer")
              .document(user.uid)
              .setData(mData);
          Firestore.instance
              .collection("All")
              .document(user.uid)
              .setData(mData);
          _dataRef
              .child("Customer Collection")
              .child(user.uid)
              .set(mData)
              .then((b) {
            showCupertinoDialog(
                context: context,
                builder: (_) {
                  return CupertinoAlertDialog(
                    title: Text(
                      "User created, Verify Email!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    actions: <Widget>[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: primaryColor),
                            child: FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "OK",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                });
            setState(() {
              isLoading = false;
            });
            _tabController.animateTo(0);
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showToast("User doesn't exist", context);
      }
      return;
    }).catchError((e) {
      showExceptionAlertDialog(context: context, exception: e, title: "Error");
      setState(() {
        isLoading = false;
      });
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    return Padding(
      padding: EdgeInsets.all(18.0),
      child: Center(
        child: Card(
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "User's SignUp",
                        style: TextStyle(
                            fontSize: 20,
                            color: primaryColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CupertinoTextField(
                      //decoration: InputDecoration(hintText: "Email"),
                      controller: _upName, padding: EdgeInsets.all(10),
                      keyboardType: TextInputType.text,
                      placeholderStyle: TextStyle(fontWeight: FontWeight.w400),

                      placeholder: "Full Name",

                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CupertinoTextField(
                      //decoration: InputDecoration(hintText: "Email"),
                      controller: _upEmail,
                      placeholder: "Email", padding: EdgeInsets.all(10),
                      keyboardType: TextInputType.emailAddress,
                      placeholderStyle: TextStyle(fontWeight: FontWeight.w400),

                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CupertinoTextField(
                      //decoration: InputDecoration(hintText: "Email"),
                      controller: _upPhoNum,
                      placeholder: "Phone Number", padding: EdgeInsets.all(10),
                      keyboardType: TextInputType.number,
                      placeholderStyle: TextStyle(fontWeight: FontWeight.w400),

                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CupertinoTextField(
                      //decoration: InputDecoration(hintText: "Password"),
                      controller: _upPass,
                      placeholder: "Password",
                      obscureText: true, padding: EdgeInsets.all(10),
                      placeholderStyle: TextStyle(fontWeight: FontWeight.w400),

                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Text("Already A Member?",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w500)),
                        MaterialButton(
                          onPressed: () {
                            _tabController.animateTo(0);
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                                color: Colors.indigo,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: CustomButton(
                      title: isLoading ? "" : "   SIGN UP   ",
                      onPress: isLoading
                          ? null
                          : () {
                              if (_upEmail.text.toString().isEmpty) {
                                showEmptyToast("Email", context);
                                return;
                              } else if (_upPass.text.toString().isEmpty) {
                                showEmptyToast("Password", context);
                                return;
                              } else if (_upName.text.toString().isEmpty) {
                                showEmptyToast("Name", context);
                                return;
                              }
                              cusSignUp(_upEmail.text, _upPass.text);
                            },
                      icon: isLoading
                          ? CupertinoActivityIndicator(radius: 20)
                          : Icon(
                              Icons.done,
                              color: Colors.white,
                            ),
                      iconLeft: false,
                      hasColor: isLoading ? true : false,
                      bgColor: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MechSignUp extends StatefulWidget {
  @override
  _MechSignUpState createState() => _MechSignUpState();
}

class _MechSignUpState extends State<MechSignUp> {
  bool isLoading = false;

  List<bool> _specifyBoolList = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  List<bool> _categoryBoolList = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  File _mainPicture, _previous1, _previous2, _cacImage;
  TextEditingController _upSpecify = TextEditingController();
  TextEditingController _upCategory = TextEditingController();
  TextEditingController _upName = TextEditingController();
  TextEditingController _upPhoneNo = TextEditingController();
  TextEditingController _upEmail = TextEditingController();
  TextEditingController _upPass = TextEditingController();
  TextEditingController _upStreetName = TextEditingController();
  TextEditingController _upCity = TextEditingController();
  TextEditingController _upLocality = TextEditingController();
  TextEditingController _upWebsite = TextEditingController();
  TextEditingController _upDescpt = TextEditingController();

  Future mechSignUp() async {
    setState(() {
      isLoading = true;
    });

    var _storageRef = FirebaseStorage.instance.ref();

    List<String> specTempList = [];
    int intA = 0;
    for (bool item in _specifyBoolList) {
      if (item == true) {
        specTempList.add(specifyList[intA]);
      }
      intA++;
    }

    List<String> cateTempList = [];
    int intB = 0;
    for (bool item in _categoryBoolList) {
      if (item == true) {
        cateTempList.add(categoryList[intB]);
      }
      intB++;
    }
    await _firebaseAuth
        .createUserWithEmailAndPassword(
            email: _upEmail.text, password: _upPass.text)
        .then((value) {
      FirebaseUser user = value.user;

      if (value.user != null) {
        user.sendEmailVerification().then((verify) async {
          var rootRef = FirebaseDatabase.instance
              .reference()
              .child("Mechanic Collection")
              .child(user.uid);

          Map<String, Object> m = Map();
          m.putIfAbsent("Company Name", () => _upName.text);
          m.putIfAbsent("Specifications", () => specTempList);
          m.putIfAbsent("Categories", () => cateTempList);
          m.putIfAbsent("Phone Number", () => _upPhoneNo.text);
          m.putIfAbsent("Email", () => _upEmail.text);
          m.putIfAbsent("Street Name", () => _upStreetName.text);
          m.putIfAbsent("City", () => _upCity.text);
          m.putIfAbsent("Locality", () => _upLocality.text);
          m.putIfAbsent("Description", () => _upDescpt.text);
          m.putIfAbsent("Website Url", () => _upWebsite.text);
          m.putIfAbsent("Loc Latitude", () => currentLocation.latitude);
          m.putIfAbsent("LOc Longitude", () => currentLocation.longitude);
          m.putIfAbsent("Image Url", () => "em");
          m.putIfAbsent("CAC Image Url", () => "em");
          m.putIfAbsent("PreviousImage1 Url", () => "em");
          m.putIfAbsent("PreviousImage2 Url", () => "em");
          m.putIfAbsent("Bank Account Name", () => "");
          m.putIfAbsent("Bank Account Number", () => "");
          m.putIfAbsent("Bank Name", () => "");
          m.putIfAbsent("Type", () => "Mechanic");
          m.putIfAbsent("Jobs Done", () => "0");
          m.putIfAbsent("Rating", () => "0.00");
          m.putIfAbsent("Reviews", () => "0");
          m.putIfAbsent("Mech Uid", () => user.uid);

          Map<String, String> allJobs = Map();
          allJobs.putIfAbsent("Total Job", () => "0");
          allJobs.putIfAbsent("Total Amount", () => "0");
          allJobs.putIfAbsent("Pending Job", () => "0");
          allJobs.putIfAbsent("Pending Amount", () => "0");
          allJobs.putIfAbsent("Pay pending Amount", () => "0");
          allJobs.putIfAbsent("Completed Amount", () => "0");
          allJobs.putIfAbsent("Payment Request", () => "0");
          allJobs.putIfAbsent("Cash Payment Debt", () => "0");

          Firestore.instance
              .collection("Mechanics")
              .document(user.uid)
              .setData(m);
          Firestore.instance.collection("All").document(user.uid).setData(m);
          _dataRef
              .child("Mechanic Collection")
              .child(user.uid)
              .set(m)
              .then((b) {
            _dataRef
                .child("All Jobs Collection")
                .child(user.uid)
                .set(allJobs)
                .then((a) {
              showCupertinoDialog(
                  context: context,
                  builder: (_) {
                    return CupertinoAlertDialog(
                      title: Text(
                        "User created, Verify Email!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      actions: <Widget>[
                        /* Center(
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: primaryColor),
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "OK",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),*/
                      ],
                    );
                  });
              setState(() {
                isLoading = false;
              });
              _tabController.animateTo(0);
            });
          });

          if (_mainPicture != null) {
            StorageReference reference =
                _storageRef.child("images/${randomString()}");

            StorageUploadTask uploadTask = reference.putFile(_mainPicture);
            StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
            String url = (await downloadUrl.ref.getDownloadURL());

            rootRef.update({"Image Url": url});

            Firestore.instance
                .collection("All")
                .document(mUID)
                .updateData({"Image Url": url});
          }

          if (_previous2 != null) {
            StorageReference reference =
                _storageRef.child("images/${randomString()}");

            StorageUploadTask uploadTask = reference.putFile(_previous2);
            StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
            String url = (await downloadUrl.ref.getDownloadURL());

            rootRef.update({"PreviousImage2 Url": url});

            Firestore.instance
                .collection("All")
                .document(mUID)
                .updateData({"PreviousImage2 Url": url});
          }
          if (_cacImage != null) {
            StorageReference reference =
                _storageRef.child("images/${randomString()}");

            StorageUploadTask uploadTask = reference.putFile(_cacImage);
            StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
            String url = (await downloadUrl.ref.getDownloadURL());

            rootRef.update({"CAC Image Url": url});

            Firestore.instance
                .collection("All")
                .document(mUID)
                .updateData({"CAC Image Url": url});
          }
          if (_previous1 != null) {
            StorageReference reference =
                _storageRef.child("images/${randomString()}");

            StorageUploadTask uploadTask = reference.putFile(_previous1);
            StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
            String url = (await downloadUrl.ref.getDownloadURL());

            rootRef.update({"PreviousImage1 Url": url});

            Firestore.instance
                .collection("All")
                .document(mUID)
                .updateData({"PreviousImage1 Url": url});
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showToast("User doesn't exist", context);
      }
      return;
    }).catchError((e) {
      showExceptionAlertDialog(context: context, exception: e, title: "Error");
      setState(() {
        isLoading = false;
      });
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
      child: Container(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Card(
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: ListView(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Mechanic's SignUp",
                      style: TextStyle(
                          fontSize: 20,
                          color: primaryColor,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SelectImage(
                  url: "em",
                  defaultUrl: "assets/images/engineer.png",
                  image: _mainPicture,
                ),
                NotiAndCategory(_upSpecify, _specifyBoolList, "Specifications",
                    specifyList),
                NotiAndCategory(
                    _upCategory, _categoryBoolList, "Category", categoryList),
                TextField(
                  decoration: InputDecoration(
                      hintText: "Company Name",
                      labelText: "Company Name",
                      labelStyle: TextStyle(color: Colors.blue)),
                  style: TextStyle(fontSize: 18),
                  controller: _upName,
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText: "Phone Number",
                      labelText: "Phone Number",
                      labelStyle: TextStyle(color: Colors.blue)),
                  controller: _upPhoneNo,
                  style: TextStyle(fontSize: 18),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText: "Email",
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.blue)),
                  controller: _upEmail,
                  style: TextStyle(fontSize: 18),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText: "Password",
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.blue)),
                  controller: _upPass,
                  style: TextStyle(fontSize: 18),
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                ),
                GetLocationFromAddress(upStreetName: _upStreetName),
                TextField(
                  decoration: InputDecoration(
                      hintText: "City",
                      labelText: "City",
                      labelStyle: TextStyle(color: Colors.blue)),
                  style: TextStyle(fontSize: 18),
                  controller: _upCity,
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText: "Locality",
                      labelText: "Locality",
                      labelStyle: TextStyle(color: Colors.blue)),
                  style: TextStyle(fontSize: 18),
                  controller: _upLocality,
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText: "Company's website",
                      labelText: "Company's website",
                      labelStyle: TextStyle(color: Colors.blue)),
                  style: TextStyle(fontSize: 18),
                  controller: _upWebsite,
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText: "Description",
                      labelText: "Description",
                      labelStyle: TextStyle(color: Colors.blue)),
                  style: TextStyle(fontSize: 18),
                  controller: _upDescpt,
                ),
                Center(
                  child: Text(
                    "Images of previous works/workshop or goods",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: SelectImage(
                        url: "e ",
                        defaultUrl: "assets/images/photo.png",
                        image: _previous1,
                      ),
                    ),
                    Expanded(
                      child: SelectImage(
                        url: " e",
                        defaultUrl: "assets/images/photo.png",
                        image: _previous2,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    "Valid ID Certificate / CAC Image",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Center(
                    child: SelectImage(
                  url: " e",
                  defaultUrl: "assets/images/photo.png",
                  image: _cacImage,
                )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButton(
                    title: isLoading ? "" : "   Register   ",
                    onPress: isLoading
                        ? null
                        : () {
                            if (_upEmail.text.toString().isEmpty) {
                              showEmptyToast("Email", context);
                            } else if (_upPass.text.toString().isEmpty) {
                              showEmptyToast("Password", context);
                            } else if (_upName.text.toString().isEmpty) {
                              showEmptyToast("Name", context);
                            } else if (_upPhoneNo.text.toString().isEmpty) {
                              showEmptyToast("Phone Number", context);
                            } else if (_upSpecify.text.toString().isEmpty) {
                              showEmptyToast("Specification", context);
                            } else if (_upCategory.text.toString().isEmpty) {
                              showEmptyToast("Category", context);
                            } else if (_upStreetName.text.toString().isEmpty) {
                              showEmptyToast("Street name", context);
                            } else if (_upCity.text.toString().isEmpty) {
                              showEmptyToast("City", context);
                            } else if (_upLocality.text.toString().isEmpty) {
                              showEmptyToast("Locality", context);
                            } else if (_cacImage == null) {
                              showEmptyToast("CAC Image", context);
                            } else if (_mainPicture == null) {
                              showEmptyToast("Image", context);
                            }
                            mechSignUp();
                          },
                    icon: isLoading
                        ? CupertinoActivityIndicator(radius: 20)
                        : Icon(
                            Icons.done,
                            color: Colors.white,
                          ),
                    iconLeft: false,
                    hasColor: isLoading ? true : false,
                    bgColor: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
