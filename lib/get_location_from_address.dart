import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import "package:google_maps_webservice/geocoding.dart";
import 'package:google_maps_webservice/places.dart';
import 'package:mechapp/utils/type_constants.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

class GetLocationFromAddress extends StatefulWidget {
  TextEditingController upStreetName;

  GetLocationFromAddress({this.upStreetName});

  @override
  _GetLocationFromAddressState createState() => _GetLocationFromAddressState();
}

class _GetLocationFromAddressState extends State<GetLocationFromAddress> {
  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<Position> locateUser() async {
    return Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Position currentLocation;

  getUserLocation() async {
    try {
      currentLocation = await locateUser();

      whereLat = currentLocation.latitude;
      whereLong = currentLocation.longitude;
      List<Placemark> placeMark =
          await Geolocator().placemarkFromCoordinates(whereLat, whereLong);
      widget.upStreetName.text =
          placeMark[0].name + ", " + placeMark[0].locality;

      setState(() {});
    } catch (e) {
      showDialog(
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
              children: <Widget>[
                Text("App might not function well"),
                Icon(Icons.error)
              ],
            ),
            actions: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.blue,
                    ),
                    child: FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
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
        },
      );
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    print(response.errorMessage);
    showCenterToast(response.errorMessage, context);
  }

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleMapKey);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            decoration: InputDecoration(
                hintText: "Street name",
                labelText: "Street name",
                labelStyle: TextStyle(color: Colors.blue)),
            style: TextStyle(fontSize: 18),
            controller: widget.upStreetName,
            readOnly: true,
            onTap: () {
              chooseLoca();
            },
          ),
        ),
        InkWell(
            onTap: () {
              chooseLoca();
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                "CHOOSE",
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ))
      ],
    );
  }

  chooseLoca() async {
    Prediction p = await PlacesAutocomplete.show(
        context: context,
        language: "en",
        onError: onError,
        mode: Mode.overlay,
        apiKey: kGoogleMapKey,
        components: [Component(Component.country, "NG")]);
    if (p != null) {
      await _places.getDetailsByPlaceId(p.placeId).then((detail) {
        whereLat = detail.result.geometry.location.lat;
        whereLong = detail.result.geometry.location.lng;
        widget.upStreetName.text = p.description;

        setState(() {});
      }).catchError((a) {
        showCenterToast("No Location selected!", context);
      });
    }
  }
}
