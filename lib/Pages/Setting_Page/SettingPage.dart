import 'dart:io'; // File키워드 사용
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // 파일 picker: 이미지 선택
import 'package:google_fonts/google_fonts.dart';
import '/Pages/Login_Page/Login_MainPage.dart'; // 로그아웃시 이동경로
import '/Pages/Login_Page/Login_Find_PWPage.dart'; // pw재설정
import 'package:get/get.dart'; // 프로필 사진 전역변수처럼 사용하기위해.
import '/Model/StateManaging.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /*GetX를 이용한 전역변수화 된 프로필 경로  관리... 24.07.15 업데이트 */
  final ProfileController profileController = Get.find();
  final AccountController _accountController = Get.put(AccountController());

  bool showPWField = false; // pw 보일지 말지.
  bool showEMLField = false; // 이메일 보일지 말지.
  TextEditingController controller = TextEditingController(); // PW
  TextEditingController controller2 = TextEditingController(); // Email 추가연락처
  // String? _profileImagePath; // 프로필 이미지 파일 원 경로

  bool isDefault = true;
  bool isValid = false;

  @override
  void initState() {
    super.initState();
    //_loadProfileImage(); GetX사용으로 대체됨
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        setState(() {
          //_profileImagePath = result.files.first.path;
          profileController.setProfileImage(result.files.first.path!);
        });
        // _saveProfileImage(result.files.first.path!); // Save the picked image path GetX사용으로 대체됨
      } else {
        print('File selection cancelled');
      }
    } catch (e) {
      print('Error picking image file: $e');
    }
  }

  String Text_HintText(bool isDefault, isValid) {
    if (!isDefault && !isValid) {
      return 'Invalid Password';
    } else if (!isDefault && isValid) {
      return 'Valid Password !';
    } else {
      return 'Check your Password';
    }
  }

  Color SetTextColor(String Text) {
    if (Text == 'Invalid Password') {
      return Color(0XFFFA5959);
    } else if (Text == 'Valid Password !') {
      return Color(0XFF6BA16A);
    } else {
      return Color(0xFF686868);
    }
  }

  // Future<void> _showDeleteDialog(BuildContext context) async {
  //   showCupertinoDialog(
  //     context: context,
  //     builder: (context) => CupertinoAlertDialog(
  //       title: Text('Delete Database'),
  //       content: Text('Are you sure you want to delete all database files?'),
  //       actions: [
  //         CupertinoDialogAction(
  //           child: Text('Cancel'),
  //           onPressed: () => Navigator.of(context).pop(),
  //         ),
  //         CupertinoDialogAction(
  //           child: Text('Delete'),
  //           isDestructiveAction: true,
  //           onPressed: () async {
  //             await _deleteDatabaseFiles();
  //             Navigator.of(context).pop();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _deleteDatabaseFiles() async {
  //   try {
  //     var databasesPath = await getDatabasesPath();
  //     Directory directory = Directory(databasesPath);
  //     var files = directory.listSync();

  //     for (var file in files) {
  //       if (file is File &&
  //           (basename(file.path).endsWith('.pdf.db') ||
  //               basename(file.path).startsWith('MEMO_'))) {
  //         await file.delete();
  //         print('Deleted database file: ${file.path}');
  //       }
  //     }

  //     print('Database files deletion completed.');
  //   } catch (e) {
  //     print('Error deleting database files: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      children: [
        Image.asset('images/Setting_info.png'),
        ListTile(
          leading: Obx(
            () => CircleAvatar(
              radius: 40,
              backgroundImage: profileController.profileImagePath.isNotEmpty
                  ? FileImage(File(profileController.profileImagePath.value))
                  : null,
              //GetX사용으로 대체됨
              // _profileImagePath != null
              //   ? FileImage(File(_profileImagePath!))
              //   : null,
              backgroundColor: Colors.grey,
              child: IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: _pickImage,
              ),
            ),
          ),
          title: Text('${_accountController.UserNickname.value}'),
          subtitle: Text('${_accountController.UserID.value}'),
          trailing: Icon(Icons.arrow_forward,
              size: 20), // Made the size of the icon smaller
          onTap: _pickImage,
        ),
        SizedBox(height: 30),
        ExpansionTile(
          title: Text('My Account Info'),
          children: [
            ListTile(
              title: Text('ID (Email): ${_accountController.UserID.value}'),
            ),
            ListTile(
              title: Text('PW 확인'),
              trailing: showPWField
                  ? Icon(Icons.expand_less)
                  : Icon(Icons.expand_more),
              onTap: () {
                setState(() {
                  showPWField = !showPWField;
                });
              },
            ),
            Visibility(
              visible: showPWField,
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Container(
                        width: 300,
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: SetTextColor(Text_HintText(
                                  isDefault, isValid))), // 텍스트를 가로 중앙으로 정렬
                          decoration: InputDecoration(
                            hintText: 'Check your Password',
                            border: InputBorder.none, // Remove border
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            prefixIcon: Padding(
                              // PW 아이콘
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0),
                              child: Image.asset(
                                'images/Icon_password.png',
                                width: 12, // 아이콘의 너비
                                height: 12, // 아이콘의 높이
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            print(
                                _accountController.isPWvalid(controller.text));
                            if (_accountController.isPWvalid(controller.text)) {
                              setState(() {
                                isDefault = false;
                                isValid = true;
                                controller.text =
                                    Text_HintText(isDefault, isValid);
                              });
                            } else if (!_accountController
                                .isPWvalid(controller.text)) {
                              setState(() {
                                isDefault = false;
                                isValid = false;
                                controller.text =
                                    Text_HintText(isDefault, isValid);
                              });
                            } else if (controller.text == '') {
                              setState(() {
                                isDefault = true;
                                isValid = false;
                                controller.text =
                                    Text_HintText(isDefault, isValid);
                              });
                            }
                          },
                          icon: Image.asset('images/Icon_Enter.png',
                              width: 20, height: 20))
                    ],
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
            ListTile(
              title: Text('PW 재설정'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Login_Find_PWPage("Back to Settings")));
              },
              trailing: Icon(Icons.arrow_forward, size: 20),
            ),
            ListTile(
              title: Text('이메일추가'),
              trailing: showEMLField
                  ? Icon(Icons.expand_less)
                  : Icon(Icons.expand_more),
              onTap: () {
                setState(() {
                  showEMLField = !showEMLField;
                });
              },
            ),
            Visibility(
              visible: showEMLField,
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Container(
                        width: 300,
                        child: TextField(
                          controller: controller2,
                          autofocus: true,
                          textAlign: TextAlign.center, // 텍스트를 가로 중앙으로 정렬
                          decoration: InputDecoration(
                            hintText: 'Add your Email',
                            border: InputBorder.none, // Remove border
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            prefixIcon: Padding(
                              // PW 아이콘
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0),
                              child: Image.asset(
                                'images/Icon_email.png',
                                width: 12, // 아이콘의 너비
                                height: 12, // 아이콘의 높이
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            print(controller2.text);
                          },
                          icon: Image.asset('images/Icon_Enter.png',
                              width: 20, height: 20))
                    ],
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
            ListTile(
              title: Text('계정 퀴즈 데이터 서버 백업 및 복원 기능 (유료기능)'),
            ),
            // Container(
            //   width: double.infinity,
            //   height: 60,
            //   child: Row(
            //     children: [
            //       SizedBox(width: 16),
            //       Text('Delete All database'),
            //       Spacer(),
            //       IconButton(
            //         icon: Icon(Icons.delete, color: Color(0xFF686868)),
            //         onPressed: () => _showDeleteDialog(context), //() => () {},
            //       ),
            //     ],
            //   ),
            // )
          ],
        ),
        SizedBox(height: 30),
        ExpansionTile(
          title: Text('My AI'),
          children: [
            ListTile(
              title: Text('이번달에 할당받은 토큰: ???개'),
            ),
            ListTile(
              title: Text('이번달 사용 토큰: ${_accountController.Get_Used_APIToken()}개'),
            ),
            ListTile(
              title: Text('남은 토큰: ??? - ${_accountController.Get_Used_APIToken()}개'),
            ),
          ],
        ),
        SizedBox(height: 30),
        ExpansionTile(
          title: Text('Subscription ... 추후 업데이트예정'),
          children: [
            ListTile(
              title: Text('현재 구독 요금제: \$15 per month, \nAnnual Subscription'),
            ),
            ListTile(
              title: Text('다른 구독 요금 옵션'),
            ),
            ListTile(
              title: Text('광고 ON/OFF 기능'),
            ),
            ListTile(
              title: Text('구독 해지 기능'),
            ),
          ],
        ),
        SizedBox(height: 30),
        ExpansionTile(
          title: Text('Language'),
          children: [
            ListTile(
              title: Text('English'),
            ),
            ListTile(
              title: Text(
                '한국어 will soon be updated',
                style: TextStyle(color: Color(0xFFAEAEAE)), // Change color to AEAEAE
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        ListTile(
          title: Text('Feedback'),
          trailing: Icon(Icons.arrow_forward, size: 20),
          onTap: () {
            // 피드백 기능 구현 (이메일 보내기)
          },
        ),
        SizedBox(height: 50),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF759CB2).withOpacity(0.7),
                spreadRadius: 0,
                blurRadius: 5.0,
                offset: Offset(0, 10), // changes position of shadow
              )
            ],
          ),
          child: OutlinedButton(
            onPressed: () {
              print('로그아웃버튼 클릭... 여기에 로그아웃 구현');
              _accountController.handleLogout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login_MainPage()),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              side: BorderSide(color: Color(0xFFE8EEF1), width: 2),
            ),
            child: Container(
              height: 30,
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(
                'Log Out',
                textAlign: TextAlign.center,
                style: GoogleFonts.lemon(
                  fontSize: 20,
                  color: Color(0XFFA7CDA7),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
