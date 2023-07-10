import 'dart:io';

import 'package:dixe_drivers/global/global.dart';
import 'package:dixe_drivers/screens/main_screen.dart';
import 'package:dixe_drivers/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();

  String? avatarEdit;

  File? _showImageAvatar;

  final imagePicker = ImagePicker();

  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");

  @override
  void dispose() {
    // todo: implement dispose
    super.dispose();
  }

  Future imagePickerMethod() async {
    final pick = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pick != null) {
        _showImageAvatar = File(pick.path);
      } else {
        Fluttertoast.showToast(msg: "No file selected");
      }
    });
  }

  void _submit() async {
    Reference referenceImageToUpload = FirebaseStorage.instance.refFromURL(
        'gs://dixa-app-47a21.appspot.com/${onlineDriverData.id!}/avatar');
    try {
      await referenceImageToUpload.putFile(_showImageAvatar!);
      avatarEdit = await referenceImageToUpload.getDownloadURL();
    } catch (error) {}

    userRef.child(firebaseAuth.currentUser!.uid).update({
      "avatar": avatarEdit,
    }).then((value) {
      Fluttertoast.showToast(msg: "Updated Successfully.");
    }).catchError((errorMessage) {
      Fluttertoast.showToast(msg: "Error Occcured. \n $errorMessage");
    });
    onlineDriverData.avatar = avatarEdit;
    _showImageAvatar = null;
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  Future<void> showUserNameDialogAlert(BuildContext context, String name) {
    nameTextEditingController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Cập nhật"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: nameTextEditingController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Hủy",
                    style: TextStyle(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () {
                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "name": nameTextEditingController.text.trim(),
                    }).then((value) {
                      nameTextEditingController.clear();
                      Fluttertoast.showToast(
                          msg:
                              "Đã cập nhật thành công và Tải lại ứng dụng để xem các thay đổi");
                    }).catchError((errorMessage) {
                      Fluttertoast.showToast(
                          msg: "Error Occcured. \n $errorMessage");
                    });
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => MainScreen()));
                  },
                  child: Text(
                    "Sửa",
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          );
        });
  }

  Future<void> showUserPhoneDialogAlert(BuildContext context, String name) {
    phoneTextEditingController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Cập nhật"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: phoneTextEditingController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Hủy",
                    style: TextStyle(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () {
                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "phone": phoneTextEditingController.text.trim(),
                    }).then((value) {
                      phoneTextEditingController.clear();
                      Fluttertoast.showToast(
                          msg:
                              "Cập nhật thành công. Tải lại ứng dụng để xem các thay đổi");
                    }).catchError((errorMessage) {
                      Fluttertoast.showToast(
                          msg: "Error Occcured. \n $errorMessage");
                    });
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => MainScreen()));
                  },
                  child: Text(
                    "Sửa",
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          );
        });
  }

  Future<void> showUserAddressDialogAlert(BuildContext context, String name) {
    addressTextEditingController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Cập nhật"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: addressTextEditingController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Hủy",
                    style: TextStyle(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () {
                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "address": addressTextEditingController.text.trim(),
                    }).then((value) {
                      addressTextEditingController.clear();
                      Fluttertoast.showToast(
                          msg:
                              "Cập nhật thành công. Tải lại ứng dụng để xem các thay đổi");
                    }).catchError((errorMessage) {
                      Fluttertoast.showToast(
                          msg: "Error Occcured. \n $errorMessage");
                    });
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => MainScreen()));
                  },
                  child: Text(
                    "Sửa",
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          );
        });
  }

  Future<void> showImageDialogAlert(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Cập nhật"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: _showImageAvatar == null
                        ? Text("Không có hình ảnh")
                        : Image.file(_showImageAvatar!),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  IconButton(
                    onPressed: () {
                      imagePickerMethod();
                    },
                    icon: Icon(Icons.camera_alt),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Hủy",
                    style: TextStyle(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () {
                    _submit();
                  },
                  child: Text(
                    "Sửa",
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const MainScreen()));
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          title: Text(
            "Thông tin cá nhân",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0.0,
        ),
        body: ListView(
          children: [
            Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: onlineDriverData.avatar == null
                        ? Icon(
                            Icons.person,
                            color: Colors.white,
                          )
                        : CircleAvatar(
                            backgroundImage:
                                NetworkImage('${onlineDriverData.avatar}'),
                            radius: 100,
                          ),
                  ),
                  IconButton(
                      onPressed: () {
                        showImageDialogAlert(context);
                      },
                      icon: Icon(Icons.camera_alt)),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Họ và tên:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "${onlineDriverData.name}",
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showUserNameDialogAlert(
                              context, onlineDriverData.name!);
                        },
                        icon: Icon(
                          Icons.edit,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Số điện thoại:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "${onlineDriverData.phone}",
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showUserPhoneDialogAlert(
                              context, onlineDriverData.phone!);
                        },
                        icon: Icon(
                          Icons.edit,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Địa chỉ:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "${onlineDriverData.address}",
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showUserAddressDialogAlert(
                              context, onlineDriverData.address!);
                        },
                        icon: Icon(
                          Icons.edit,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Phương tiện chở:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
        
                     Padding(padding: EdgeInsets.fromLTRB(30, 0, 0, 0)),

                      Text(
                        onlineDriverData.motobike_type=="motobike"? "xe máy"
                        :onlineDriverData.motobike_type=="car"?"ô tô"
                        :"xe thuê",
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Hãng/loại xe:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    Padding(padding: EdgeInsets.fromLTRB(30, 0, 0, 0)),
                      Text("${onlineDriverData.motobike_model}",
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                   Divider(
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Màu xe:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    Padding(padding: EdgeInsets.fromLTRB(30, 0, 0, 0)),
                      Text("${onlineDriverData.motobike_color}",
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Biển số xe:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                     Padding(padding: EdgeInsets.fromLTRB(30, 0, 0, 0)),
                      Text("${onlineDriverData.motobike_number}",
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Text(
                    "${onlineDriverData.email}",
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      firebaseAuth.signOut();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => SplashScreen()));
                    },
                    child: Text(
                      "Đăng xuất",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.red),
                    ),
                  )
                ],
              ),
            ),
          ),
        ]
        ),
      ),
    );
  }
}
