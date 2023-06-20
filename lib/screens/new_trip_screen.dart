import 'dart:async';

import 'package:dixe_drivers/Assistants/assistant_method.dart';
import 'package:dixe_drivers/global/global.dart';
import 'package:dixe_drivers/models/user_ride_request_infomation.dart';
import 'package:dixe_drivers/splashScreen/splash_screen.dart';
import 'package:dixe_drivers/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/fare_amount_collection_dialog.dart';

class NewTripScreen extends StatefulWidget {
  UserRideQuestInformation? userRideQuestInformation;

  NewTripScreen({this.userRideQuestInformation});
  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  bool isRequestDirectionDetails = false;

  String durationFromOriginTODestination = "";

  String? buttonTitle = "Arrived";

  Color? buttonColor;


  Future<void> drawPolyLineFromOriginToDestination(LatLng originLatLng, LatLng destinationLatLng, bool darkTheme) async {
    showDialog(context: context, builder: (BuildContext contenxt) => ProgressDialog(message: "Please wait ...",)
    );
    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    Navigator.pop(context);

    PolylinePoints pPonits = PolylinePoints();

    List<PointLatLng> decodedPolyLinePointsResultList = pPonits.decodePolyline(directionDetailsInfo.e_points!);

    polyLinePositionCoordinates.clear();

    if(decodedPolyLinePointsResultList.isNotEmpty){
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinePositionCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
          color: darkTheme ? Colors.amber.shade400 : Colors.blue,
          polylineId: PolylineId("PolylineID"),
          jointType: JointType.round,
          points: polyLinePositionCoordinates,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
          width: 5,
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if (originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude));
    }
    else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude));
    }
    else{
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);

    }

    newTripGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
        markerId: MarkerId("originID"),
        position: originLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
        circleId: CircleId("originId"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId("destinationId"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);

    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    saveAssignedDriverDetailsToUserRideRequest();

  }
  getDriverLocationUpdatesAtRealTime() {
    LatLng oldLatLng = LatLng(0, 0);
    streamSubscriptionDriverPosition = Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPossition = position;
      onlineDriverCurrentPosition = position;
      
      LatLng latLngLiveDriverPostion = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);
      
      Marker animatingMarker = Marker(
          markerId: MarkerId("AnimatedMarker"),
          position: latLngLiveDriverPostion,
          icon: iconAnimatedMarker!,
          infoWindow: InfoWindow(title: "This is your postion"),
      );
      
      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: latLngLiveDriverPostion, zoom: 18);
        newTripGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        
        setOfMarkers.removeWhere((element) => element.mapsId.value == "AnimatedMarker");

        setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latLngLiveDriverPostion;
      updateDurationTImeAtRealTime();

      Map driverLatLngDataMap = {
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longitude": onlineDriverCurrentPosition!.longitude.toString(),
      };
      
      FirebaseDatabase.instance.ref().child("ALl Ride Requests")
          .child(widget.userRideQuestInformation!.rideRequestId!)
          .child("driverLocation").set(driverLatLngDataMap);
    });
  }

  updateDurationTImeAtRealTime() async {
    if(isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;
    }

    if(onlineDriverCurrentPosition == null) {
      return;
    }

    var originLatLng = LatLng(onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude);
    var destinationLatLng;

    if(rideRequestStatus == "accepted") {
      destinationLatLng = widget.userRideQuestInformation!.originLatLng;
    }
    else{
      destinationLatLng = widget.userRideQuestInformation!.destinationLatLng;
    }
    var directionInformation = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    if(directionInformation != null) {
      setState(() {
        durationFromOriginTODestination = directionInformation.duration_text!;
      });
    }
    isRequestDirectionDetails = false;
  }

  createDriverIconMaker() {
    if(iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2, 2));

      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/motorcycle-icon_1.png").then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  saveAssignedDriverDetailsToUserRideRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child("ALl Ride Requests").child(widget.userRideQuestInformation!.rideRequestId!);

    Map driverLocationMap = {
      "latitude": driverCurrentPossition!.latitude.toString(),
      "longitude": driverCurrentPossition!.longitude.toString(),
    };

    if(databaseReference.child("driverId") != "waiting"){
      databaseReference.child("driverLocation").set(driverLocationMap);

      databaseReference.child("status").set("accepted");
      databaseReference.child("driverId").set(onlineDriverData.id);
      databaseReference.child("driverName").set(onlineDriverData.name);

      databaseReference.child("driverPhone").set(onlineDriverData.phone);
      databaseReference.child("ratings").set(onlineDriverData.ratings);
      databaseReference.child("motobike_details").set(onlineDriverData.motobike_type.toString() + " "
          + onlineDriverData.motobike_number.toString()
          + " (" + onlineDriverData.motobike_color.toString() + ")");

      saveRideRequestIdToDriverHistory();
    }else{
      Fluttertoast.showToast(msg: "This ride is already accepted by another driver. \n Reloading the App");
      Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
    }
  }

  saveRideRequestIdToDriverHistory() {
    DatabaseReference tripHistoryRef = FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("tripsHistory");

    tripHistoryRef.child(widget.userRideQuestInformation!.rideRequestId!).set(true);
  }

  endTripNow() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(message: "Please wait...",)
    );
    var currentDriverPostionLatLng = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);

    var tripDirectionDetails = await AssistantMethods.obtainOriginToDestinationDirectionDetails(currentDriverPostionLatLng, widget.userRideQuestInformation!.originLatLng!);

    double totalFareAmount = AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetails);

    FirebaseDatabase.instance.ref().child("ALl Ride Requests").child(widget.userRideQuestInformation!.rideRequestId!).child("fareAmount").set(totalFareAmount.toString());

    FirebaseDatabase.instance.ref().child("ALl Ride Requests").child(widget.userRideQuestInformation!.rideRequestId!).child("status").set("ended");

    Navigator.pop(context);

    showDialog(
        context: context,
        builder: (BuildContext context) => FareAmountCollectionsDialog(totalFareAmount: totalFareAmount)
    );

    saveFareAmountToDriverEarnings(totalFareAmount);

  }

  saveFareAmountToDriverEarnings(double totalFareAmount){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").once().then((snap) {
      if(snap.snapshot.value != null) {
        double oldEarnings = double.parse(snap.snapshot.value.toString());
        double driverTotalEearnings = totalFareAmount + oldEarnings;

        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").set(driverTotalEearnings.toString());
      }else{
        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").set(totalFareAmount.toString());

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    createDriverIconMaker();
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);

              newTripGoogleMapController = controller;

              setState(() {
                mapPadding = 350;
              });
              var driverCurrentLatLng = LatLng(driverCurrentPossition!.latitude,
                  driverCurrentPossition!.longitude);
              var userPickUpLatLng =
                  widget.userRideQuestInformation!.originLatLng;

              drawPolyLineFromOriginToDestination(
                  driverCurrentLatLng, userPickUpLatLng!, darkTheme);

              getDriverLocationUpdatesAtRealTime();
            },
          ),

          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Container(
                  decoration: BoxDecoration(
                    color: darkTheme ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow:[
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 18,
                        spreadRadius: 0.5,
                        offset: Offset(0.6, 0.6),
                      )
                    ]
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(durationFromOriginTODestination,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkTheme ? Colors.amber.shade400 : Colors.black,
                        ),
                        ),

                        SizedBox(height: 10,),
                        Divider(thickness: 1, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),

                        SizedBox(height: 10,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.userRideQuestInformation!.userName!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkTheme ? Colors.amber.shade400 : Colors.black,
                              ),
                            ),
                            
                            IconButton(onPressed: () {},
                                icon: Icon(
                                  Icons.phone,
                                  color: darkTheme ? Colors.amber.shade400 : Colors.black,
                                ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10,),

                        Row(
                          children: [
                            Image.asset("images/origin.png",
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 10,),



                            Expanded(child:
                            Container(
                              child: Text(
                                widget.userRideQuestInformation!.originAddress!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: darkTheme ? Colors.amberAccent : Colors.black
                                ),
                              ),
                            ),
                            )
                          ],
                        ),

                        Row(
                          children: [
                            Image.asset("images/destination.png",
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 10,),



                            Expanded(child:
                            Container(
                              child: Text(
                                widget.userRideQuestInformation!.destinationAddress!,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: darkTheme ? Colors.amberAccent : Colors.black
                                ),
                              ),
                            ),
                            )
                          ],
                        ),
                        SizedBox(height: 10,),

                        Divider(
                          thickness: 1,
                          color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                        ),

                        SizedBox(height: 10,),

                        ElevatedButton.icon(
                            onPressed: () async {
                              if(rideRequestStatus == "accepted"){
                                rideRequestStatus = "arrived";

                                FirebaseDatabase.instance.ref().child("ALl Ride Requests").child(widget.userRideQuestInformation!.rideRequestId!).child("status").set(rideRequestStatus);

                                setState(() {
                                  buttonTitle = "Let's Go";
                                  buttonColor = Colors.lightGreen;
                                });

                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) => ProgressDialog(message: "Loading...",) );
                                
                                await drawPolyLineFromOriginToDestination(
                                    widget.userRideQuestInformation!.originLatLng!,
                                    widget.userRideQuestInformation!.destinationLatLng!,
                                    darkTheme);

                                Navigator.pop(context);
                                
                              }else if (rideRequestStatus == "arrived"){
                                rideRequestStatus = "ontrip";

                                FirebaseDatabase.instance.ref().child("ALl Ride Requests").child(widget.userRideQuestInformation!.rideRequestId!).child("status").set(rideRequestStatus);

                                setState(() {
                                  buttonTitle = "End Trip";
                                  buttonColor = Colors.red;
                                });
                              }else if (rideRequestStatus == "ontrip") {
                                endTripNow();
                              }

                            },
                            icon: Icon(Icons.directions_bike, color: darkTheme ? Colors.black: Colors.white, size: 25,),
                            label: Text(buttonTitle!
                            ))
                      ],
                    ),
                  ),
                ),
              ),
          )
        ],
      ),
    );
  }
}
