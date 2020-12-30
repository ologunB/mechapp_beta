import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mechapp/cus_main.dart';
import 'package:mechapp/dropdown_noti_cate.dart';
import 'package:mechapp/get_location_from_address.dart';
import 'package:mechapp/mechanic/mech_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'libraries/custom_button.dart';
import 'libraries/show_exception_alert_dialog.dart';
import 'libraries/snackbar.dart';
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
    _tabController = new TabController(vsync: this, length: 2);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        offKeyboard(context);
      },
      child: DefaultTabController(
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
  TextEditingController _inForgotPassEmail = TextEditingController();
  bool isLoading = false;

  // bool forgotPassIsLoading = false;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future signIn(String email, String password, context) async {
    setState(() {
      isLoading = true;
    });
    await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      User user = value.user;

      if (value.user != null) {
        if (!value.user.emailVerified) {
          setState(() {
            isLoading = false;
          });

          showSnackBar(context, "Error", "Email not verified!", duration: 4);

          _firebaseAuth.signOut();
          return;
        }
        FirebaseFirestore.instance
            .collection('All')
            .doc(user.uid)
            .get()
            .then((document) {
          String type = document["Type"];
          String state = document["State"];

          showToast(state, context);

          if (state == "Blocked") {
            showSnackBar(context, "Alert",
                "Your Account has been blocked for going against the FABAT rules. Check with the Admin through our various channels.",
                duration: 6);

            _firebaseAuth.signOut();
            setState(() {
              isLoading = false;
            });
            return;
          } else if (state == "Review") {
            showSnackBar(context, "Alert",
                "Your Account has not been approved as it is under review. Check again in the next 24 hours!",
                duration: 4);

            _firebaseAuth.signOut();
            setState(() {
              isLoading = false;
            });
            return;
          } else {
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                fullscreenDialog: true,
                builder: (context) {
                  return type == "Customer" ? CusMainPage() : MechMainPage();
                },
              ),
            );

            String uid = type == "Customer" ? "Uid" : "Mech Uid";
            putInDB(type, document[uid], document["Email"],
                document["Company Name"], document["Phone Number"]);

            showToast("Logged in", context);
          }
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

  Future putInDB(
      String type, String uid, String email, String name, phone) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      prefs.setBool("isLoggedIn", true);
      prefs.setString("uid", uid);
      prefs.setString("email", email);
      prefs.setString("name", name);
      prefs.setString("type", type);
      prefs.setString("phone", phone);
    });
    _firebaseAuth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      progressIndicator: CupertinoActivityIndicator(radius: 20),
      isLoading: isLoading,
      color: Colors.grey,
      child: Padding(
        padding: EdgeInsets.all(18.0),
        child: Center(
          child: Card(
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 25.0),
              child: SingleChildScrollView(
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            placeholderStyle:
                                TextStyle(fontWeight: FontWeight.w400),
                            keyboardType: TextInputType.emailAddress,
                            padding: EdgeInsets.all(10),
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CupertinoTextField(
                            controller: _inPass,
                            placeholder: "Password",
                            padding: EdgeInsets.all(10),
                            placeholderStyle:
                                TextStyle(fontWeight: FontWeight.w400),
                            obscureText: true,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                        MaterialButton(
                          onPressed: () {
                            showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (_) => CupertinoAlertDialog(
                                title: Column(
                                  children: <Widget>[
                                    Text("Enter Email"),
                                  ],
                                ),
                                content: CupertinoTextField(
                                  controller: _inForgotPassEmail,
                                  placeholder: "Email",
                                  padding: EdgeInsets.all(10),
                                  keyboardType: TextInputType.emailAddress,
                                  placeholderStyle:
                                      TextStyle(fontWeight: FontWeight.w300),
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                                actions: <Widget>[
                                  Center(
                                    child: CustomButton(
                                      title: "Reset Password",
                                      onPress: () async {
                                        if (_inForgotPassEmail.text.isEmpty) {
                                          showEmptyToast("Email", context);
                                          return;
                                        }
                                        Navigator.pop(context);

                                        setState(() {
                                          isLoading = true;
                                        });

                                        await _firebaseAuth
                                            .sendPasswordResetEmail(
                                                email: _inForgotPassEmail.text)
                                            .then((value) {
                                          _inForgotPassEmail.text = "";

                                          setState(() {
                                            isLoading = false;
                                          });
                                          showSnackBar(context, "Alert",
                                              "Reset email sent!",
                                              duration: 4);
                                        }).catchError((e) {
                                          showExceptionAlertDialog(
                                              context: context,
                                              exception: e,
                                              title: "Error");
                                          _inForgotPassEmail.text = "";
                                          setState(() {
                                            isLoading = false;
                                          });
                                          return;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                      ),
                                      iconLeft: false,
                                      bgColor: Colors.blueGrey,
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
                            title: "  SIGN IN  ",
                            onPress: () {
                              if (_inEmail.text.toString().isEmpty) {
                                showEmptyToast("Email", context);
                                return;
                              } else if (_inPass.text.toString().isEmpty) {
                                showEmptyToast("Password", context);
                                return;
                              }
                              signIn(_inEmail.text, _inPass.text, context);
                            },
                            icon: Icon(
                              Icons.arrow_forward,
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
          ),
        ),
      ),
    );
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
    return Center(
      child: ListView(
        shrinkWrap: true,
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
      ),
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
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoActivityIndicator(
                    radius: 18,
                  ),
                ),
                Text(
                  "Loading",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 20),
                )
              ],
            ),
            actions: <Widget>[],
          );
        });

    await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      User user = value.user;

      if (value.user != null) {
        user.sendEmailVerification().then((verify) {
          Map<String, Object> mData = Map();
          mData.putIfAbsent("Company Name", () => _upName.text);
          mData.putIfAbsent("Phone Number", () => _upPhoNum.text);
          mData.putIfAbsent("Email", () => _upEmail.text);
          mData.putIfAbsent("Type", () => "Customer");
          mData.putIfAbsent("Uid", () => user.uid);
          mData.putIfAbsent("State", () => "Current");
          mData.putIfAbsent(
              "Timestamp", () => DateTime.now().millisecondsSinceEpoch);

          FirebaseFirestore.instance
              .collection("Customer")
              .doc(user.uid)
              .set(mData);
          FirebaseFirestore.instance.collection("All").doc(user.uid).set(mData);
          _dataRef
              .child("Customer Collection")
              .child(user.uid)
              .set(mData)
              .then((b) {
            Navigator.pop(context);

            showDialog(
                context: context,
                builder: (_) {
                  return CupertinoAlertDialog(
                    title: Text(
                      "User created, Verify Email!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  );
                });
            setState(() {
              isLoading = false;
            });
            _tabController.animateTo(0);
          });
        });
      } else {
        Navigator.pop(context);

        setState(() {
          isLoading = false;
        });
        showToast("User doesn't exist", context);
      }
      return;
    }).catchError((e) {
      Navigator.pop(context);

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
                      controller: _upName,
                      padding: EdgeInsets.all(10),
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
                      placeholder: "Email",
                      padding: EdgeInsets.all(10),
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
                      placeholder: "Phone Number",
                      padding: EdgeInsets.all(10),
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
                      obscureText: true,
                      padding: EdgeInsets.all(10),
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
                      title: "   SIGN UP   ",
                      onPress: () {
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
                      icon: Icon(
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
  String selectedCity;

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
  TextEditingController _upLocality = TextEditingController(text: " ");
  TextEditingController _upWebsite = TextEditingController();
  TextEditingController _upDescpt = TextEditingController();

  Future mechSignUp(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoActivityIndicator(
                    radius: 18,
                  ),
                ),
                Text(
                  "Loading",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 20),
                )
              ],
            ),
            actions: <Widget>[],
          );
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
      User user = value.user;

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
          m.putIfAbsent("City", () => selectedCity);
          m.putIfAbsent("Locality", () => _upLocality.text);
          m.putIfAbsent("Description", () => _upDescpt.text ?? "Empty");
          m.putIfAbsent("Website Url", () => _upWebsite.text ?? "Empty");
          m.putIfAbsent("Loc Latitude", () => whereLat ?? 6.5);
          m.putIfAbsent("LOc Longitude", () => whereLong ?? 6.5);
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
          m.putIfAbsent("State", () => "Review");
          m.putIfAbsent(
              "Timestamp", () => DateTime.now().millisecondsSinceEpoch);

          Map<String, String> allJobs = Map();
          allJobs.putIfAbsent("Total Job", () => "0");
          allJobs.putIfAbsent("Total Amount", () => "0");
          allJobs.putIfAbsent("Pending Job", () => "0");
          allJobs.putIfAbsent("Pending Amount", () => "0");
          allJobs.putIfAbsent("Pay pending Amount", () => "0");
          allJobs.putIfAbsent("Completed Amount", () => "0");
          allJobs.putIfAbsent("Payment Request", () => "0");
          allJobs.putIfAbsent("Cash Payment Debt", () => "0");

          FirebaseFirestore.instance
              .collection("Mechanics")
              .doc(user.uid)
              .set(m);
          FirebaseFirestore.instance.collection("All").doc(user.uid).set(m);
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
              Navigator.pop(context);
              showDialog(
                  context: context,
                  builder: (_) {
                    return CupertinoAlertDialog(
                      title: Text(
                        "Account created, Verify Email!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      actions: <Widget>[],
                    );
                  });
              setState(() {
                isLoading = false;
              });
              _tabController.animateTo(0);
            });
          });

          if (_mainPicture != null) {
            var reference = _storageRef.child("images/${randomString()}");

            var uploadTask = reference.putFile(_mainPicture);
            var downloadUrl = (await uploadTask.whenComplete(() => null));
            String url = (await downloadUrl.ref.getDownloadURL());

            rootRef.update({"Image Url": url});

            FirebaseFirestore.instance
                .collection("All")
                .doc(mUID)
                .update({"Image Url": url});
          }

          if (_previous2 != null) {
            Reference reference = _storageRef.child("images/${randomString()}");

            UploadTask uploadTask = reference.putFile(_previous2);
            TaskSnapshot downloadUrl =
                (await uploadTask.whenComplete(() => null));
            String url = (await downloadUrl.ref.getDownloadURL());

            rootRef.update({"PreviousImage2 Url": url});

            FirebaseFirestore.instance
                .collection("All")
                .doc(mUID)
                .update({"PreviousImage2 Url": url});
          }
          if (_cacImage != null) {
            Reference reference = _storageRef.child("images/${randomString()}");

            UploadTask uploadTask = reference.putFile(_cacImage);
            TaskSnapshot downloadUrl =
                (await uploadTask.whenComplete(() => null));
            String url = (await downloadUrl.ref.getDownloadURL());

            rootRef.update({"CAC Image Url": url});

            FirebaseFirestore.instance
                .collection("All")
                .doc(mUID)
                .update({"CAC Image Url": url});
          }
          if (_previous1 != null) {
            Reference reference = _storageRef.child("images/${randomString()}");

            UploadTask uploadTask = reference.putFile(_previous1);
            TaskSnapshot downloadUrl =
                (await uploadTask.whenComplete(() => null));
            String url = (await downloadUrl.ref.getDownloadURL());

            rootRef.update({"PreviousImage1 Url": url});

            FirebaseFirestore.instance
                .collection("All")
                .doc(mUID)
                .update({"PreviousImage1 Url": url});
          }
        }).catchError((e) {
          Navigator.pop(context);

          showExceptionAlertDialog(
              context: context, exception: e, title: "Error");
          setState(() {
            isLoading = false;
          });
          return;
        });
      } else {
        Navigator.pop(context);

        setState(() {
          isLoading = false;
        });
        showToast("User doesn't exist", context);
      }
      return;
    }).catchError((e) {
      Navigator.pop(context);

      showExceptionAlertDialog(context: context, exception: e, title: "Error");
      setState(() {
        isLoading = false;
      });
      return;
    });
  }

  @override
  void initState() {
    whereLong = null;
    whereLat = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
      child: Container(
        height: MediaQuery.of(context).size.height / 1.35,
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    height: 100,
                    width: 100,
                    child: GestureDetector(
                      onTap: () {
                        getPic();
                      },
                      child: _mainPicture == null
                          ? Image(
                              image: AssetImage("assets/images/photo.png"),
                              height: 90,
                              width: 90,
                              fit: BoxFit.contain)
                          : Image.file(_mainPicture,
                              height: 90, width: 90, fit: BoxFit.contain),
                    ),
                  ),
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
                SizedBox(height: 6),
                Text("City", style: TextStyle(color: Colors.blue)),
                DropdownButton<String>(
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text("Select your city"),
                  ),
                  value: selectedCity,
                  underline: SizedBox(),
                  items: cityList.map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          value,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }).toList(),
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                    FocusScope.of(context).unfocus();
                  },
                ),
                Divider(
                  color: Colors.black45,
                  thickness: 1,
                ),
                /*       TextField(
                  decoration: InputDecoration(
                      hintText: "Locality",
                      labelText: "Locality",
                      labelStyle: TextStyle(color: Colors.blue)),
                  style: TextStyle(fontSize: 18),
                  controller: _upLocality,
                ),*/
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
                      child: Container(
                        height: 100,
                        width: 100,
                        child: InkWell(
                          onTap: () {
                            getImage1();
                          },
                          child: _previous1 == null
                              ? Image(
                                  image: AssetImage("assets/images/photo.png"),
                                  height: 90,
                                  width: 90,
                                  fit: BoxFit.contain)
                              : Image.file(_previous1,
                                  height: 90, width: 90, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 100,
                        width: 100,
                        child: InkWell(
                          onTap: () {
                            getImage2();
                          },
                          child: _previous2 == null
                              ? Image(
                                  image: AssetImage("assets/images/photo.png"),
                                  height: 90,
                                  width: 90,
                                  fit: BoxFit.contain)
                              : Image.file(_previous2,
                                  height: 90, width: 90, fit: BoxFit.contain),
                        ),
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
                    child: Container(
                  height: 100,
                  width: 100,
                  child: InkWell(
                    onTap: () {
                      getCACImage();
                    },
                    child: _cacImage == null
                        ? Image(
                            image: AssetImage("assets/images/photo.png"),
                            height: 90,
                            width: 90,
                            fit: BoxFit.contain)
                        : Image.file(_cacImage,
                            height: 90, width: 90, fit: BoxFit.contain),
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButton(
                    title: "   Register   ",
                    onPress: () {
                      authenticate();
                    },
                    icon: Icon(
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

  Future getCACImage() async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _cacImage = img;
    });
  }

  Future getImage1() async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _previous1 = img;
    });
  }

  Future getImage2() async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _previous2 = img;
    });
  }

  Future getPic() async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _mainPicture = img;
    });
  }

  authenticate() {
    if (_upEmail.text.toString().isEmpty) {
      showEmptyToast("Email", context);
      return;
    } else if (_upPass.text.toString().isEmpty) {
      showEmptyToast("Password", context);
      return;
    } else if (_upName.text.toString().isEmpty) {
      showEmptyToast("Name", context);
      return;
    } else if (_upPhoneNo.text.toString().isEmpty) {
      showEmptyToast("Phone Number", context);
      return;
    } else if (_upSpecify.text.toString().isEmpty) {
      showEmptyToast("Specification", context);
      return;
    } else if (_upCategory.text.toString().isEmpty) {
      showEmptyToast("Category", context);
      return;
    } else if (_upStreetName.text.toString().isEmpty) {
      showEmptyToast("Street name", context);
      return;
    } else if (selectedCity.isEmpty) {
      showEmptyToast("City", context);
      return;
    } else if (_upLocality.text.toString().isEmpty) {
      showEmptyToast("Locality", context);
      return;
    } else if (_cacImage == null) {
      showEmptyToast("CAC Image", context);
      return;
    } else if (_mainPicture == null) {
      showEmptyToast("Image", context);
      return;
    } else if (whereLat == null) {
      showCenterToast("Choose a Location again", context);
      return;
    }

    mechSignUp(context);
  }

  List<String> cityList = [
    "Ibadan",
    "Lagos",
    "Akure",
    "Abuja",
    "Portharcourt",
    "Ogun"
  ];
}
