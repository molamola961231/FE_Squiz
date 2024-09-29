import 'package:flutter/material.dart';
/* import dart files */
import '/Reusables/CustomBottomNavBar.dart';
import '/Reusables/DefaultAppBar.dart';
// import '/Pages/Quiz_Page/Make_Quiz_Card.dart';
import '/Pages/PDF_Page/PDF_Main_storage_access.dart';
// import '/dbshow.dart';
import '/Pages/SQuiz_Page/Squiz_Main_Page.dart';
import '/Pages/Setting_Page/SettingPage.dart';
import 'Pages/Social_Page/Social_Main_Page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; //bottom navigation 에서 뭐가 클릭된건지 알림.

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateBottomBar(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    Center(
      child: StorageAccessPage(),
    ),
    Center(
      child: DatabaseCheckPage(),
    ),
    Center(
      child: 
      Social_MainPage(),
      // Text(
      //   'Shop Page',
      //   style: TextStyle(fontSize: 50),
      // ),
      // child: Login_MainPage(),
    ),
    Center(
      child: SettingsPage(),
      // Text(
      //   'Setting',
      //   style: TextStyle(fontSize: 50),
      // ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),

      body: _pages[_selectedIndex],
      bottomNavigationBar: 
      Container(
        color: Colors.green,
        child: CustomBottomNavBar(
            selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
      ),
    );
  }
  // Add your state variables and methods here
}
