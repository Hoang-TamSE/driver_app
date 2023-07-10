import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String? phone;
  String? name;
  String? id;
  String? email;
  String? address;
  String? avatar;
  String? beforeCCCD;
  String? afterCCCD;

  UserModel({this.name, this.phone, this.email, this.id, this.address, this.avatar, this.beforeCCCD, this.afterCCCD});

  UserModel.fromSnapshot(DataSnapshot snap) {
    phone = (snap.value as dynamic)["phone"];
    id = snap.key;
    name = (snap.value as dynamic)["name"];
    email = (snap.value as dynamic)["email"];
    address = (snap.value as dynamic)["address"];
    avatar = (snap.value as dynamic)["avatar"];
    beforeCCCD = (snap.value as dynamic)["beforeCCCD"];
    afterCCCD = (snap.value as dynamic)["afterCCCD"];
  }
}
