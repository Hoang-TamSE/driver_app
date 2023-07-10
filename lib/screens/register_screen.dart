import 'dart:io';

import 'package:dixe_drivers/global/global.dart';
import 'package:dixe_drivers/screens/main_screen.dart';
import 'package:dixe_drivers/screens/motobike_info_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmTextEditingController = TextEditingController();
  bool _passwordVisible = false;

  File? _imageAvatar;
  File? _beforeCCCD;
  File? _afterCCCD;
  final imagePicker = ImagePicker();

  String? downloadAvatar;
  String? downloadBeforeCCCD;
  String? downloadAfterCCCD;
  //declare a globalKey
  final _formKey = GlobalKey<FormState>();
  Future imagePickerAvatar() async {
    final pick = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pick != null) {
        _imageAvatar = File(pick.path);
      } else {
        Fluttertoast.showToast(msg: "Không có tập tin được chọn");
      }
    });
  }

  Future imagePickerBefore() async {
    final pick = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pick != null) {
        _beforeCCCD = File(pick.path);
      } else {
        Fluttertoast.showToast(msg: "Không có tập tin được chọn");
      }
    });
  }

  Future imagePickerAfter() async {
    final pick = await imagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pick != null) {
        _afterCCCD = File(pick.path);
      } else {
        Fluttertoast.showToast(msg: "Không có tập tin được chọn");
      }
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await firebaseAuth
          .createUserWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim())
          .then((auth) async {
        currentUser = auth.user;
        //push avatar
        Reference refAvatar =
            FirebaseStorage.instance.ref().child('${currentUser!.uid}/avatar');
        await refAvatar.putFile(_imageAvatar!);
        downloadAvatar = await refAvatar.getDownloadURL();

        //push beforeCCCD
        Reference refBefore = FirebaseStorage.instance
            .ref()
            .child('${currentUser!.uid}/beforeCCCD');
        await refBefore.putFile(_beforeCCCD!);
        downloadBeforeCCCD = await refBefore.getDownloadURL();

        //push afterCCCD
        Reference refAfter = FirebaseStorage.instance
            .ref()
            .child('${currentUser!.uid}/afterCCCD');
        await refAfter.putFile(_afterCCCD!);
        downloadAfterCCCD = await refAfter.getDownloadURL();

        if (currentUser != null) {
          Map userMap = {
            "id": currentUser!.uid,
            "name": nameTextEditingController.text.trim(),
            "email": emailTextEditingController.text.trim(),
            "address": addressTextEditingController.text.trim(),
            "phone": phoneTextEditingController.text.trim(),
            "avatar": downloadAvatar,
            "beforeCCCD": downloadBeforeCCCD,
            "afterCCCD": downloadAfterCCCD,
          };
          DatabaseReference userRef =
              FirebaseDatabase.instance.ref().child('drivers');
          userRef.child(currentUser!.uid).set(userMap);
        }
        await Fluttertoast.showToast(msg: "Successfully Registered");
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => MotoBikeInfoScreen()));
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
      });
    } else {
      Fluttertoast.showToast(msg: "Not all field are valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              Column(
                children: [
                  Container(
                    child: _imageAvatar == null
                        ? Image.asset(
                            darkTheme
                                ? 'images/city_dark.jpg'
                                : 'images/city.jpg',
                            height: 350,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            _imageAvatar!,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Register",
                    style: TextStyle(
                      color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextFormField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(50)
                                  ],
                                  decoration: InputDecoration(
                                      hintText: "Name",
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: darkTheme
                                          ? Colors.black45
                                          : Colors.grey.shade200,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          borderSide: const BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          )),
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.grey,
                                      )),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Name can\'t be empty';
                                    }
                                    if (text.length < 2) {
                                      return "Please enter a valid name";
                                    }
                                    if (text.length > 50) {
                                      return "Name can\'t be more than 50";
                                    }
                                  },
                                  onChanged: (text) => setState(() {
                                    nameTextEditingController.text = text;
                                  }),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(50)
                                  ],
                                  decoration: InputDecoration(
                                      hintText: "Email",
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: darkTheme
                                          ? Colors.black45
                                          : Colors.grey.shade200,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          borderSide: const BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          )),
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.grey,
                                      )),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Email can\'t be empty';
                                    }
                                    if (EmailValidator.validate(text) != true) {
                                      return "Please enter a valid email";
                                    }
                                    if (text.length > 50) {
                                      return "Email can\'t be more than 50";
                                    }
                                  },
                                  onChanged: (text) => setState(() {
                                    emailTextEditingController.text = text;
                                  }),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                IntlPhoneField(
                                  showCountryFlag: false,
                                  dropdownIcon: Icon(
                                    Icons.arrow_drop_down,
                                    color: darkTheme
                                        ? Colors.amber.shade400
                                        : Colors.grey,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Phone",
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    filled: true,
                                    fillColor: darkTheme
                                        ? Colors.black45
                                        : Colors.grey.shade200,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        borderSide: const BorderSide(
                                          width: 0,
                                          style: BorderStyle.none,
                                        )),
                                  ),
                                  initialCountryCode: 'VN',
                                  disableLengthCheck: true,
                                  onChanged: (text) => setState(() {
                                    phoneTextEditingController.text =
                                        text.completeNumber;
                                  }),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(50)
                                  ],
                                  decoration: InputDecoration(
                                      hintText: "Address",
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: darkTheme
                                          ? Colors.black45
                                          : Colors.grey.shade200,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          borderSide: const BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          )),
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.grey,
                                      )),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Address can\'t be empty';
                                    }
                                    if (text.length < 2) {
                                      return "Please enter a valid email";
                                    }
                                    if (text.length > 50) {
                                      return "Address can\'t be more than 50";
                                    }
                                  },
                                  onChanged: (text) => setState(() {
                                    addressTextEditingController.text = text;
                                  }),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  obscureText: !_passwordVisible,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(50)
                                  ],
                                  decoration: InputDecoration(
                                      hintText: "Password",
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: darkTheme
                                          ? Colors.black45
                                          : Colors.grey.shade200,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          borderSide: BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          )),
                                      prefixIcon: Icon(
                                        Icons.password,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.grey,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _passwordVisible =
                                                !_passwordVisible;
                                          });
                                        },
                                      )),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Password can\'t be empty';
                                    }
                                    if (text.length < 6) {
                                      return "Please enter a valid password";
                                    }
                                    if (text.length > 50) {
                                      return "Password can\'t be more than 50";
                                    }
                                    return null;
                                  },
                                  onChanged: (text) => setState(() {
                                    passwordTextEditingController.text = text;
                                  }),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  obscureText: !_passwordVisible,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(50)
                                  ],
                                  decoration: InputDecoration(
                                      hintText: "Confirm Password",
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      filled: true,
                                      fillColor: darkTheme
                                          ? Colors.black45
                                          : Colors.grey.shade200,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          borderSide: BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          )),
                                      prefixIcon: Icon(
                                        Icons.password,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.grey,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _passwordVisible =
                                                !_passwordVisible;
                                          });
                                        },
                                      )),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Confirm Password can\'t be empty';
                                    }
                                    if (text !=
                                        passwordTextEditingController.text) {
                                      return "Password do not match";
                                    }
                                    if (text.length < 6) {
                                      return "Please enter a valid password";
                                    }
                                    if (text.length > 50) {
                                      return "Password can\'t be more than 50";
                                    }
                                    return null;
                                  },
                                  onChanged: (text) => setState(() {
                                    confirmTextEditingController.text = text;
                                  }),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    imagePickerAvatar();
                                  },
                                  icon: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: darkTheme
                                          ? Colors.amber.shade400
                                          : const Color.fromARGB(
                                              255, 133, 189, 235),
                                      foregroundColor: darkTheme
                                          ? Colors.black
                                          : Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      minimumSize: Size(50, 30)),
                                  label: Text('Ảnh chân dung'),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: darkTheme
                                          ? Colors.amber.shade400
                                          : const Color.fromARGB(
                                              255, 133, 189, 235),
                                      foregroundColor: darkTheme
                                          ? Colors.black
                                          : Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      minimumSize: Size(50, 30)),
                                  onPressed: () {
                                    imagePickerBefore();
                                  },
                                  label: Text('Ảnh CCCD mặt trước'),
                                ),
                                Container(
                                  child: _beforeCCCD == null
                                      ? Text('')
                                      : Image.file(
                                          _beforeCCCD!,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                          height: 250,
                                          width: 400,
                                        ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: darkTheme
                                          ? Colors.amber.shade400
                                          : const Color.fromARGB(
                                              255, 133, 189, 235),
                                      foregroundColor: darkTheme
                                          ? Colors.black
                                          : Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      minimumSize: Size(50, 30)),
                                  onPressed: () {
                                    imagePickerAfter();
                                  },
                                  label: Text('Ảnh CCCD mặt sau'),
                                ),

                                Container(
                                  child: _afterCCCD == null
                                      ? Text('')
                                      : Image.file(
                                          _afterCCCD!,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                          height: 250,
                                          width: 400,
                                        ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.blue,
                                        foregroundColor: darkTheme
                                            ? Colors.black
                                            : Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(32),
                                        ),
                                        minimumSize: Size(double.infinity, 50)),
                                    onPressed: () {
                                      _submit();
                                    },
                                    child: Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    )),
                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Forgot Password',
                                    style: TextStyle(
                                      color: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.blue,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Have an account?",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Text(
                                        "Sign In",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.blue,
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ]),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
