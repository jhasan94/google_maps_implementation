import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class DisplayMap extends StatefulWidget {
  @override
  _DisplayMapState createState() => _DisplayMapState();
}

class _DisplayMapState extends State<DisplayMap> {
  //properties
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  GoogleMapController _controller;
  int temp = 0;
  var titleName = "jahid";
  TextEditingController _textFieldController = TextEditingController();

  //initial state
  @override
  void initState() {
    super.initState();
    //initially getting the current location
    getCurrentLocation();
  }

  //default initial camera positions
  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(23.706932, 90.499064),
    zoom: 14.4746,
  );

  //current location finder method
  void getCurrentLocation() async {
    try {
      var location = await _locationTracker.getLocation();
      updateMarker(location);
      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }
      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  target: LatLng(newLocalData.latitude, newLocalData.longitude),
                  zoom: 18.00)));
          updateMarker(newLocalData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
    temp = 1;
  }

  //update marker with current location
  void updateMarker(LocationData locationData) {
    LatLng latlng = LatLng(locationData.latitude, locationData.longitude);
    this.setState(() {
      marker = Marker(
        markerId: MarkerId("current location"),
        position: latlng,
        draggable: false,
        flat: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () => infoField(latlng),
        infoWindow: InfoWindow(title: titleName, snippet: latlng.toString()),
      );
    });
  }

  //info Dialog filed with user input
  Future<void> infoField(LatLng latLng) async {
    titleName = await showDialog<String>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Hello',
              textAlign: TextAlign.center,
            ),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter your name please"),
              onSubmitted: (value) => Navigator.pop(context, value),
            ),
            actions: <Widget>[
              Container(
                child: Text("your location is $latLng"),
              ),
              FlatButton(
                child: new Text('Submit'),
                color: Colors.green,
                onPressed: () {
                  var name = _textFieldController.text;
                  print("your name is $name and your latlng is $latLng");
                  Navigator.pop(context, name);
                },
              )
            ],
          );
        });
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          if (temp == 0)
            Center(child: CircularProgressIndicator())
          else
            GoogleMap(
              mapType: MapType.terrain,
              initialCameraPosition: initialLocation,
              markers: Set.of((marker != null) ? [marker] : []),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    //temp = 0;
    super.dispose();
  }
}
