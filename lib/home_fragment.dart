import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechapp/each_service.dart';
import 'package:mechapp/utils/my_models.dart';
import 'package:mechapp/utils/type_constants.dart';
import 'package:mechapp/view_mech_profile.dart';
import 'package:google_geocoding/google_geocoding.dart' show GoogleGeocoding, LatLon;
class HomeFragment extends StatefulWidget {
  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  var theAddress = "---";

  @override
  void initState() {
    super.initState();
    getUserLocation();
    getProfiles();
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  getUserLocation() async {
    try {
      currentLocation = await locateUser();
      var googleGeocoding = GoogleGeocoding(kGoogleMapKey);
      var result =
      await googleGeocoding.geocoding.getReverse(LatLon(currentLocation.latitude, currentLocation.longitude));
      theAddress = result.results[0].formattedAddress.split(",")[0].trim();

      setState(() {
        theAddress = result.results[0].formattedAddress.split(",")[0].trim();
      });
    } catch (e) {
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text(
                "Error getting Location",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text("App might not function well"), Icon(Icons.error)],
              ),
              actions: <Widget>[
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Color.fromARGB(255, 22, 58, 78),
                      ),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "OK",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          });
    }
  }

  List<EachMechanic> mechList = [];
  List<EachMechanic> sortedList = [];
  bool showService = true;
  bool showSearch = false;
  bool noMechFound = false;

  var rootRef = FirebaseDatabase.instance.reference().child("Mechanic Collection");

  Map dATA = {};

  Future<Map> getProfiles() async {
    await rootRef.once().then((snapshot) {
      dATA = snapshot.value;
    });
    return dATA;
  }

  void onSearchMechanic(String val) {
    if (mechList != null) {
      val = val.trim();
      if (val.isNotEmpty) {
        sortedList.clear();
        for (EachMechanic item in mechList) {
          if (item.name.toUpperCase().contains(val.toUpperCase())) {
            sortedList.add(item);
          }
        }
        if (sortedList.isEmpty) {
          setState(() {
            showService = false;
            showSearch = true;
            textServices = "Found Mechanics";
            noMechFound = true;
          });
          return;
        }
        setState(() {
          noMechFound = false;

          showService = false;
          showSearch = true;
          textServices = "Found Mechanics";
        });
      } else {
        setState(() {
          noMechFound = false;
          showService = true;
          showSearch = false;
          textServices = "Services";
          FocusScope.of(context).unfocus();
        });
      }
    } else {
      showCenterToast("Geting mechanics", context);
    }
  }

  String textServices = "Services";

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    CarouselOptions carouselOptions = CarouselOptions(
      height: MediaQuery.of(context).size.height / 4,
      autoPlay: true,
      enableInfiniteScroll: true,
      enlargeCenterPage: true,
      pauseAutoPlayOnTouch: true,
    );
    return Container(
      color: primaryColor,
      child: Column(
        children: <Widget>[
          FutureBuilder(
            future: getProfiles(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                var kEYS = [];
                if (dATA != null) {
                  kEYS = dATA.keys.toList();
                }

                mechList.clear();
                for (var key in kEYS) {
                  String tempName = dATA[key]['Company Name'];
                  String tempPhoneNumber = dATA[key]['Phone Number'];
                  String tempStreetName = dATA[key]['Street Name'];
                  String tempCity = dATA[key]['City'];
                  String tempLocality = dATA[key]['Locality'];
                  String tempDescription = dATA[key]['Description'];
                  String tempImage = dATA[key]['Image Url'];
                  String tempMechUid = dATA[key]['Mech Uid'];
                  String tempRating = dATA[key]['Rating'];
                  var tempLongPos = double.parse(dATA[key]['LOc Longitude'].toString());
                  var tempLatPos = double.parse(dATA[key]['Loc Latitude'].toString());

                  List cat = dATA[key]["Categories"];
                  List specs = dATA[key]["Specifications"];
                  mechList.add(EachMechanic(
                      uid: tempMechUid,
                      name: tempName,
                      locality: tempLocality,
                      phoneNumber: tempPhoneNumber,
                      streetName: tempStreetName,
                      city: tempCity,
                      descrpt: tempDescription,
                      image: tempImage,
                      specs: specs,
                      categories: cat,
                      mLat: tempLatPos,
                      mLong: tempLongPos,
                      rating: tempRating));
                }
                return Container();
              }
              return Container();
            },
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8, left: 8.0, right: 8.0),
            child: CarouselSlider(
              options: carouselOptions,
              items: [
                "assets/images/cc1.jpg",
                "assets/images/cc2.jpg",
                "assets/images/cc3.jpg",
                "assets/images/cc4.jpg",
                "assets/images/cc6.jpg",
                "assets/images/cc7.jpg",
                "assets/images/cc5.jpg"
              ].map((i) {
                return Builder(
                  builder: (context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Stack(
                        children: <Widget>[
                          Align(
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),
                              child: Image(
                                image: AssetImage(i),
                                fit: BoxFit.fill,
                                color: Colors.black38,
                                colorBlendMode: BlendMode.dstOut,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: ListTile(
                              title: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "",
                                  style: TextStyle(
                                      backgroundColor: Colors.blueAccent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                              ),
                              subtitle: Text("",
                                  style: TextStyle(
                                      backgroundColor: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blueAccent)),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.location_on,
                color: Colors.red,
              ),
              Flexible(
                child: Text(
                  theAddress,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: CupertinoTextField(
              prefix: Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(
                  Icons.search,
                  color: primaryColor,
                ),
              ),
              placeholder: "Search Mechanics...",
              onChanged: onSearchMechanic,
              padding: EdgeInsets.all(10),
              clearButtonMode: OverlayVisibilityMode.editing,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              textServices,
              style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12)],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 11),
                child: Stack(
                  children: <Widget>[
                    Visibility(
                      visible: showService,
                      child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: httpServicesList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => EachService(
                                    title: httpServicesList[index].typeTitle,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(0.0),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: CachedNetworkImage(
                                      imageUrl: httpServicesList[index].typeImageUrl,
                                      height: 40,
                                      width: 40,
                                      placeholder: (context, url) =>
                                          CupertinoActivityIndicator(radius: 10),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      httpServicesList[index].typeTitle,
                                      style: TextStyle(fontSize: 18, color: primaryColor),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                      ),
                    ),
                    Visibility(
                      visible: showSearch,
                      child: ListView.builder(
                        itemCount: sortedList.length,
                        itemBuilder: (context, int index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => ViewMechProfile(
                                    mechanic: sortedList[index],
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [BoxShadow(color: Colors.black12)],
                                    borderRadius: BorderRadius.circular(15)),
                                child: Center(
                                    child: ListTile(
                                  subtitle: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.call,
                                            color: primaryColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(
                                              sortedList[index].phoneNumber,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black54),
                                            ),
                                          ),
                                          Icon(
                                            Icons.message,
                                            color: primaryColor,
                                          ),
                                        ],
                                      ),
/*
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: .0),
                                    child: Text(
                                      "4.5KM Away",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
*/
                                    ],
                                  ),
                                  title: Text(
                                    sortedList[index].name,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black),
                                  ),
                                  leading: CachedNetworkImage(
                                    imageUrl: sortedList[index].image,
                                    height: 48,
                                    width: 48,
                                    placeholder: (context, url) => Image(
                                      image: AssetImage("assets/images/person.png"),
                                    ),
                                    errorWidget: (context, url, error) => Image(
                                      image: AssetImage("assets/images/person.png"),
                                    ),
                                  ),
                                )),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Visibility(child: emptyList("Mechanic"), visible: noMechFound)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ServiceType {
  String typeTitle, typeImageUrl;

  ServiceType({this.typeTitle, this.typeImageUrl});
}

List<ServiceType> httpServicesList = [
  ServiceType(
      typeTitle: "Accidented Vehicle",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/images%2Ficons8-crashed-car-48.png?alt=media&token=166baa0b-269d-4d90-8391-2b3146ffabb0"),
  ServiceType(
      typeTitle: "Air Conditioner",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/service%20images%2Faircondition.png?alt=media&token=424aaf59-5948-4b7a-8bcf-038d6a8f0d49"),
  ServiceType(
      typeTitle: "Brake System",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/images%2Ficons8-brake-discs-64.png?alt=media&token=11f5b66e-06bc-42a3-bd29-8162420d0c30"),
  ServiceType(
      typeTitle: "Brake pad replacement",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/images%2Ficons8-brake-pedal-48.png?alt=media&token=f6afaea3-279c-4310-95ec-db0c684b557e"),
  ServiceType(
      typeTitle: "Call Us",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/service%20images%2Fcallus.png?alt=media&token=809bb036-c523-4528-9681-ed69cc3d52d8"),
  ServiceType(
      typeTitle: "Car Scan",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/images%2Ficons8-barcode-reader-100.png?alt=media&token=fdf865bc-adc2-45bd-8fce-11848481c390"),
  ServiceType(
      typeTitle: "Car Tint",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/service%20images%2Fcartint.png?alt=media&token=7f47bcea-3eb6-4dca-8cd9-db02b8080172"),
  ServiceType(
      typeTitle: "Electrician",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/service%20images%2Felectrician.png?alt=media&token=6c6ed46b-b6d8-4982-9461-6ced94739f92"),
  ServiceType(
      typeTitle: "Engine Expert",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/service%20images%2Fengineexpert.png?alt=media&token=e164f9f0-b6ee-44da-aa73-03e732454d70"),
  ServiceType(
      typeTitle: "Exhaust System",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/service%20images%2Fexhaustsys.png?alt=media&token=7cf46711-f422-47eb-9e83-a7663439c125"),
  ServiceType(
      typeTitle: "Locking & Keys/Security",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/images%2Ficons8-car-rental-64.png?alt=media&token=38b1d7b6-6861-41f8-a112-d68998100702"),
  ServiceType(
      typeTitle: "Oil & Filter Change",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/service%20images%2Foilfilter.png?alt=media&token=45347067-f0bd-4ac1-b0cf-aaa74863fd77"),
  ServiceType(
      typeTitle: "Painter",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/service%20images%2Fpainterr.png?alt=media&token=e9295378-aa59-4886-bb45-49bdc4282b0c"),
  ServiceType(
      typeTitle: "Panel Beater",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/images%2Ficons8-manual-metal-arc-welding-50.png?alt=media&token=588f9d82-81ed-486c-a63b-110aa636b84c"),
  ServiceType(
      typeTitle: "Tow trucks",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/images%2Ficons8-tow-truck-64.png?alt=media&token=bfdc0928-f089-445d-b9dd-f550125f57f6"),
  ServiceType(
      typeTitle: "Upholstery & Interior",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/images%2Ficons8-wing-chair-48.png?alt=media&token=ba5247a5-fb6b-4a06-81a0-ffefe6e78164"),
  ServiceType(
      typeTitle: "Wheel Balancing & Alignment",
      typeImageUrl:
          "https://firebasestorage.googleapis.com/v0/b/mechanics-b3612.appspot.com/o/service%20images%2Fwheelbala.png?alt=media&token=a1543d44-a60b-4629-a65f-f604908a314a"),
];
