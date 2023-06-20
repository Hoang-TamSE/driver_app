import 'package:dixe_drivers/infoHandler/app_info.dart';
import 'package:dixe_drivers/screens/login_screen.dart';
import 'package:dixe_drivers/screens/motobike_info_screen.dart';
import 'package:dixe_drivers/screens/search_places_screen.dart';
import 'package:dixe_drivers/splashScreen/splash_screen.dart';
import 'package:dixe_drivers/themeProvider/theme_provider.dart';
import 'package:dixe_drivers/widgets/fare_amount_collection_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: ThemeMode.system,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
