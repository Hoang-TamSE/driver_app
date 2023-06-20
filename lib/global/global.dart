// import 'package:dixa_app_users/models/user_model.dart';
import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:dixe_drivers/models/directions_details_info.dart';
import 'package:dixe_drivers/models/driver_data.dart';
import 'package:dixe_drivers/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

StreamSubscription<Position>? streamSubscriptionPostion;
StreamSubscription<Position>? streamSubscriptionDriverPosition;

AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

UserModel? userModelCurrentInfo;

Position? driverCurrentPossition;

String userDropOffAddress = "";
DriverData onlineDriverData = DriverData();
DirectionDetailsInfo? tripDirectionDetailsInfo;

String? driverVehicleType = "";
