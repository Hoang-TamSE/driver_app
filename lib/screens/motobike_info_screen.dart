import 'package:dixe_drivers/global/global.dart';
import 'package:dixe_drivers/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MotoBikeInfoScreen extends StatefulWidget {
  const MotoBikeInfoScreen({Key? key}) : super(key: key);

  @override
  State<MotoBikeInfoScreen> createState() => _MotoBikeInfoScreenState();
}

class _MotoBikeInfoScreenState extends State<MotoBikeInfoScreen> {

  final motobikeModelTextEditingController = TextEditingController();
  final motobikeNumberTextEditingController = TextEditingController();
  final motobikeColorTextEditingController = TextEditingController();

  List<String> carTypes = ["Car", "CNG", "motobike"];
  String? selectedCarType;

  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
        Map driverCarInfoMap = {
          "motobike_model": motobikeModelTextEditingController.text.trim(),
          "motobike_number": motobikeNumberTextEditingController.text.trim(),
          "motobike_color": motobikeColorTextEditingController.text.trim(),
          "type": selectedCarType,
        };
        DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('drivers');
        userRef.child(currentUser!.uid).child("motobike_details").set(driverCarInfoMap);
        Fluttertoast.showToast(msg: "MotoBike details has been saved.");
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => SplashScreen()));
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
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(darkTheme ? "images/city_dark.jpg" : "images/city.jpg"),

                SizedBox(height: 20,),

                Text(
                  "Add Car Details",
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
                                    hintText: "MotoBike Model",
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
                                      Icons.motorcycle_sharp,
                                      color: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.grey,
                                    )),
                                autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Motobike Model can\'t be empty';
                                  }
                                  if (text.length < 2) {
                                    return "Please enter a valid Motobike Model";
                                  }
                                  if (text.length > 50) {
                                    return "Motobike Model can\'t be more than 50";
                                  }
                                },
                                onChanged: (text) => setState(() {
                                  motobikeModelTextEditingController.text = text;
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
                                    hintText: "MotoBike Number",
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
                                      Icons.numbers,
                                      color: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.grey,
                                    )),
                                autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'MotoBike Number can\'t be empty';
                                  }

                                  if (text.length > 10) {
                                    return "MotoBike Number can\'t be more than 50";
                                  }
                                },
                                onChanged: (text) => setState(() {
                                  motobikeNumberTextEditingController.text = text;
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
                                    hintText: "MotoBike Color",
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
                                      Icons.color_lens,
                                      color: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.grey,
                                    )),
                                autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Motobike Color can\'t be empty';
                                  }
                                  if (text.length > 50) {
                                    return "Motobike Color can\'t be more than 50";
                                  }
                                },
                                onChanged: (text) => setState(() {
                                  motobikeColorTextEditingController.text = text;
                                }),
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              DropdownButtonFormField(
                                decoration: InputDecoration(
                                  hintText: "Please Choose MotoBike Type",
                                  prefixIcon: Icon(
                                      Icons.car_crash,
                                      color: darkTheme? Colors.amber.shade400: Colors.grey),
                                  filled: true,
                                  fillColor: darkTheme? Colors.black45: Colors.grey.shade200,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )
                                  )
                                ),
                                  items: carTypes.map((car) {
                                    return DropdownMenuItem(
                                        child: Text(
                                          car,
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      value: car,
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedCarType = newValue.toString();
                              });
                              }
                              ),

                              SizedBox(height: 20,),


                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.blue,
                                      onPrimary: darkTheme
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
                            ],
                          ),
                        ),
                      ]),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
