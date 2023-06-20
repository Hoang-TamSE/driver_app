import 'dart:async';

import 'package:dixe_drivers/Assistants/assistant_method.dart';
import 'package:dixe_drivers/global/global.dart';
import 'package:dixe_drivers/pushNotification/push_notificaiton_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  LocationPermission? _locationPermission;

  String statusText = "Now Offline";
  Color buttonColors = Colors.grey;
  bool isDriverActive = false;

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateDriverPosition() async {
    Position cPostion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPossition = cPostion;

    LatLng latLngPosition =
    LatLng(driverCurrentPossition!.latitude, driverCurrentPossition!.longitude);
    CameraPosition cameraPosition =
    CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
    await AssistantMethods.searchAddressForGeographicCoOrdinates(
        driverCurrentPossition!, context);
    print("This our address = " + humanReadableAddress);
    
    

    // initializeGeoFireListener();

    // AssitantMethods.readTripsKeysForOnlineUser(content)
  }
  readCurrentDriverInfomation() async {
    currentUser = firebaseAuth.currentUser;
    
    FirebaseDatabase.instance.ref()
      .child("drivers")
      .child(currentUser!.uid)
      .once()
      .then((snap) {
        if(snap.snapshot.value != null) {
          onlineDriverData.id = (snap.snapshot.value as Map)["id"];
          onlineDriverData.name = (snap.snapshot.value as Map)["name"];
          onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
          onlineDriverData.email = (snap.snapshot.value as Map)["email"];
          onlineDriverData.address = (snap.snapshot.value as Map)["address"];
          onlineDriverData.motobike_model = (snap.snapshot.value as Map)["motobike_details"]["motobike_model"];
          onlineDriverData.motobike_color = (snap.snapshot.value as Map)["motobike_details"]["motobike_color"];
          onlineDriverData.motobike_number = (snap.snapshot.value as Map)["motobike_details"]["motobike_number"];
          onlineDriverData.motobike_type = (snap.snapshot.value as Map)["motobike_details"]["type"];


          driverVehicleType = (snap.snapshot.value as Map)["motobike_details"]["type"];
        }
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    checkIfLocationPermissionAllowed();
    readCurrentDriverInfomation();

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
            padding: EdgeInsets.only(top: 40),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);

              newGoogleMapController = controller;
              locateDriverPosition();
          },
        ),
        statusText != "Now Online" ?
        Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          color: Colors.black87,
        ) : Container(),

        Positioned(
          top: statusText != "Now Online" ? MediaQuery.of(context).size.height * 0.45 : 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    if(isDriverActive != true) {
                      driverIsOnlineNow();
                      updateDriverLocationAtRealTime();
                      setState(() {
                        statusText = "Now Online";
                        isDriverActive = true;
                        buttonColors = Colors.transparent;
                      });
                    }else{
                      driverIsOfflineNow();
                      setState(() {
                        statusText = "Now Offline";
                        isDriverActive = false;
                        buttonColors = Colors.grey;
                      });
                      Fluttertoast.showToast(msg: "You are offline now");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: buttonColors,
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    )
                  ),
                  child: statusText != "Now Online" ? Text(statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  ) : Icon(
                    Icons.phonelink_ring,
                    color: Colors.white,
                    size: 26,
                  )
              ),
            ],
          ),
        )
      ],
    );
  }
  driverIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    Geofire.initialize("activeDrivers");
    Geofire.setLocation(currentUser!.uid, driverCurrentPossition!.latitude, driverCurrentPossition!.longitude);

    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).child("newRideStatus");

    ref.set('idle');
    ref.onValue.listen((event) { });
  }
  updateDriverLocationAtRealTime()  {
      streamSubscriptionPostion = Geolocator.getPositionStream().listen((Position position) {
        if(isDriverActive == true) {
          Geofire.setLocation(currentUser!.uid, driverCurrentPossition!.latitude, driverCurrentPossition!.longitude);
        }

        LatLng latLng = LatLng(driverCurrentPossition!.latitude, driverCurrentPossition!.longitude);

        newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
      });


  }
  driverIsOfflineNow() {
    Geofire.removeLocation(currentUser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).child("newRideStatus");

    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(Duration(milliseconds: 2000), () {
      SystemChannels.platform.invokeListMethod("SystemNavigator.pop");
    }) ;
  }


}
