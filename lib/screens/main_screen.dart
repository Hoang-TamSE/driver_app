
import 'package:dixe_drivers/tabPages/earning_tab.dart';
import 'package:dixe_drivers/tabPages/profile_tab.dart';
import 'package:dixe_drivers/tabPages/ratting_tab.dart';
import 'package:dixe_drivers/tabPages/home_tab.dart';
import 'package:flutter/material.dart';
import 'package:dixe_drivers/global/global.dart';
import 'package:dixe_drivers/splashScreen/splash_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  TabController? tabController;
  int selectedIndex = 0;

  onItemClick(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabController = TabController(
        length: 4,
        vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children:  const [
          HomeTabPage(),
          EarningTabPage(),
          RatingsTabPage(),
          ProfileTabPage(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "Thu nhập"),
          BottomNavigationBarItem(icon: Icon(Icons.start), label: "Xếp hạng"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
        ],
        unselectedItemColor: darkTheme ? Colors.black45 : Colors.white54,
        selectedItemColor: darkTheme ? Colors.black : Colors.white,
        backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClick,
      ),

    );
  }
}
