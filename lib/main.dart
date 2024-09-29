import 'package:flutter/material.dart';
import 'Pages/Login_Page/Login_MainPage.dart';
import 'package:get/get.dart'; // 북마크 상태관리 위해 getx 사용
import 'Model/StateManaging.dart'; // 상태관리 페이지
import 'package:flutter_dotenv/flutter_dotenv.dart'; // env파일사용.


void main() async {
  await dotenv.load(fileName: "asset/const.env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /*앱 전반에 걸쳐 사용될 get x 컨트롤러 주입 부분.*/
    final BookmarkController bookmarkController =
        Get.put(BookmarkController()); //의존성 주입

    final ProfileController profileController = Get.put(ProfileController());

    return GetMaterialApp(
      // MaterialApp에서 Get패키지 이용하는 GetMaterialApp로 변화
      debugShowCheckedModeBanner: false,
      home: 
      Login_MainPage(),
    );
  }
}
// CustomBottomNavBar.dart
