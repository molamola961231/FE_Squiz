import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Login_Find_PWPage.dart';
import 'Login_Verification.dart';
import 'package:buttom_navigation/homepage.dart';
import 'dart:convert'; //json 변환
import 'package:http/http.dart' as http; // api통신(엔드포인트) 위해.
import 'package:get/get.dart';
import '/Model/StateManaging.dart'; // 유저 정보 저장및 확인

class Login_MainPage extends StatefulWidget {
  @override
  State<Login_MainPage> createState() => _Login_MainPageState();
}

class _Login_MainPageState extends State<Login_MainPage> {
  TextEditingController controller = TextEditingController(); //  ID
  TextEditingController controller2 = TextEditingController(); //  PW
  TextEditingController controller3 = TextEditingController(); // 이름

  TextEditingController IDcontroller = TextEditingController(); //  ID컨트롤러
  TextEditingController PWcontroller2 = TextEditingController(); //  PW컨트롤러
  bool isSignInSelected = true; // 로그인 / 회원가입 상태를 관리하는 변수
  bool SignInSucceeded = false; // 로그인 성공 여부를 나타내는 변수
  bool _obscureText = true; // 비밀번호 숨김 상태를 나타내는 변수
/*UserID handler*/
  final AccountController _accountController = Get.put(AccountController());
  /*로그인성공시 동작할 함수*/
  Future<void> registerUser() async {
    final String url = 'http://13.209.134.75:8080/user/join';
    final headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> requestBody = {
      'nickname': controller3.text,
      'password': controller2.text,
      'email': controller.text,
      'gender': 1,
      'is_deleted': true
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        setState(() {
          SignInSucceeded = true;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Congrats!'),
              content: Text('Now you are our member!'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 406) {
        setState(() {
          SignInSucceeded = false;
        });
        print('Sign Up Failed: Email already exists.');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Error'),
              content: Column(
                children: [
                  SizedBox(height: 30),
                  Text(
                      'This Email is already Occupied.\nPlease try with new Email address')
                ],
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          SignInSucceeded = false;
        });
        print('Sign Up Failed: Unexpected error.');
      }
    } catch (e) {
      setState(() {
        SignInSucceeded = false;
      });
      print('Sign Up Failed: $e');
    }
  }

  Future<void> SendVerificationEmail(String email) async {
    final String url =
        'http://13.209.134.75:8080/user/mailSend'; // Updated URL to point to the correct endpoint
    final headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> requestBody = {'email': email};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Login_Verification_Page(
                "SignUp", controller.text,
                Password: controller2.text, UserNickname: controller3.text),
          ),
        );
      } else {
        print(controller.text);
        print('Email verification failed: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> signInUser() async {
    final String url = 'http://13.209.134.75:8080/user/login';
    final headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> requestBody = {
      'email': controller.text, //IDcontroller.text,//
      'password': controller2.text, //PWcontroller2.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['isSuccess'] == true) {
          final userInfo = responseBody['result'][0];
          _accountController.getUserInfo(
              controller.text, //IDcontroller.text,
              controller2.text, //PWcontroller2.text,
              userInfo['nickname'], // UserNickname.value
              userInfo['userId'] //UserToken.value
              );
          _accountController.PrintUserInfo(); // 로그출력용
          setState(() {
            SignInSucceeded = true;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          setState(() {
            SignInSucceeded = false;
          });
          print('Sign In Failed: ${responseBody['message']}');
        }
      } else if (response.statusCode == 406) {
        setState(() {
          SignInSucceeded = false;
        });
        print('Sign In Failed: Email already exists.');
      } else {
        setState(() {
          SignInSucceeded = false;
        });
        print('Sign In Failed: Unexpected error.');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Sign In Failed!'),
              content: Text('Please check ID and PW again!'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        SignInSucceeded = false;
      });
      print('Sign In Failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Color(0XFFA7CDA7),
      height: MediaQuery.of(context).size.height,
      child: GestureDetector(
        onTap: () {
          // 바깥 영역을 탭했을 때 키보드를 숨깁니다
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          // Wrap with SingleChildScrollView
          child: Center(
            child: Container(
              color: Color(0xFF5E8E5E),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60),
                  SizedBox(width: MediaQuery.of(context).size.width), //여백
                  Container(
                    //이미지
                    child: Image.asset('images/File_Browser_link_Image.png'),
                  ),
                  SizedBox(height: 30),
                  Row(
                    // <-> 로그인/회원가입 탭... Ontap을 setState로 설정하기
                    children: [
                      InkWell(
                        /*왼쪽 container*/
                        child: Container(
                          width: (MediaQuery.of(context).size.width) / 2,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSignInSelected
                                ? Color(0XFFA0C7A0)
                                : Color(0XFF6E996E),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Sign in",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            isSignInSelected = true;
                          });
                        },
                      ),
                      InkWell(
                          /*오른쪽 container */
                          child: Container(
                            width: (MediaQuery.of(context).size.width) / 2,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSignInSelected
                                  ? Color(0XFF6E996E)
                                  : Color(0XFFA0C7A0),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Sign up",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              isSignInSelected = false;
                            });
                          })
                    ],
                  ),
                  Column(children: [
                    Visibility(
                        /* 로그인 박스 */
                        visible: isSignInSelected,
                        child: Container(
                          decoration: BoxDecoration(color: Color(0XFFA7CDA7)),
                          // 서식박스
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 40,
                                width: (MediaQuery.of(context).size.width),
                              ),

                              Text(
                                'Welcome Back!!', // TextField의 hintText 대신 텍스트 사용
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color(0XFF5E8E5E), //Colors.grey,
                                ),
                              ),
                              SizedBox(height: 30),
                              Container(
                                /*이메일 박스*/
                                width: 300,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF759CB2).withOpacity(0.7),
                                      spreadRadius: 0,
                                      blurRadius: 5.0,
                                      offset: Offset(
                                          0, 10), // changes position of shadow
                                    )
                                  ],
                                ),
                                child: Center(
                                  /*  */
                                  child: TextField(
                                    controller: controller, //
                                    autofocus: false, //true,
                                    textAlign:
                                        TextAlign.center, // 텍스트를 가로 중앙으로 정렬
                                    decoration: InputDecoration(
                                      hintText: 'Example@email.com',
                                      border: InputBorder.none, // Remove border
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10 /*horizontal: 20*/),
                                      prefixIcon: Padding(
                                        // 이메일 아이콘
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10.0),
                                        child: Image.asset(
                                          'images/Icon_email.png',
                                          width: 20, // 아이콘의 너비
                                          height: 20, // 아이콘의 높이
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                              ),
                              /*  */
                              SizedBox(height: 30),
                              // Add spacing between fields
                              Container(
                                /*PW박스 */
                                width: 300,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF759CB2).withOpacity(0.7),
                                      spreadRadius: 0,
                                      blurRadius: 5.0,
                                      offset: Offset(
                                          0, 10), // changes position of shadow
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: TextField(
                                    controller:
                                        controller2, //controller2,//PWcontroller2
                                    obscureText: _obscureText, // 비밀번호 숨김
                                    autofocus: false, //true,
                                    textAlign:
                                        TextAlign.center, // 텍스트를 가로 중앙으로 정렬
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      border: InputBorder.none, // Remove border
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      prefixIcon: Padding(
                                        // 이메일 아이콘
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _obscureText =
                                                  !_obscureText; // 비밀번호 표시/숨김 전환
                                            });
                                          },
                                          child: Image.asset(
                                            _obscureText
                                                ? 'images/Icon_password.png'
                                                : 'images/Icon_password_ShowPW.png',
                                            width: 12, // 아이콘의 너비
                                            height: 12, // 아이콘의 높이
                                          ),
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),

                              Row(children: [
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width) / 2,
                                ),
                                InkWell(
                                    child: Text(
                                      "Forgot your password?",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0XFF2BA24C),
                                      ),
                                    ),
                                    onTap: () {
                                      print('회원 비밀번호찾기 구현');
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Login_Find_PWPage(
                                                      "Back to Sign in"))); // 버튼 클릭 시 수행할 액션. 함수 추가
                                    })
                              ]),
                              SizedBox(height: 20),

                              Container(
                                  decoration: BoxDecoration(
                                    color: Color(0XFFA7CDA7),
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color(0xFF759CB2).withOpacity(0.7),
                                        spreadRadius: 0,
                                        blurRadius: 5.0,
                                        offset: Offset(0,
                                            10), // changes position of shadow
                                      )
                                    ],
                                  ),
                                  child: OutlinedButton(
                                      onPressed: signInUser, //TesthandleSignIn,
                                      // () {print('로그인버튼 클릭... 여기에 로그인 구현');},
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        side: BorderSide(
                                            color: Color(0xFFE8EEF1), width: 2),
                                      ),
                                      child: Container(
                                          height: 30,
                                          width: 250,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            'Sign in',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lemon(
                                              fontSize: 20,
                                              color: Color(0xFFFDE599),
                                            ),
                                          )))),
                              SizedBox(height: 30),
                              /* 소셜 로그인 생기면 주석처리 해제 */
                              // Text(
                              //   'OR', // TextField의 hintText 대신 텍스트 사용
                              //   textAlign: TextAlign.center,
                              //   style: GoogleFonts.lemon(
                              //     fontSize: 14,
                              //     color: Colors.white,
                              //   ),
                              // ),
                              // Text(
                              //   'Sign in with', // TextField의 hintText 대신 텍스트 사용
                              //   textAlign: TextAlign.center,
                              //   style: GoogleFonts.lemon(
                              //     fontSize: 20,
                              //     color: Colors.white,
                              //   ),
                              // ),

                              // SizedBox(height: 20),

                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     InkWell(
                              //       child:
                              //           Image.asset("images/Icon_Google.png"),
                              //       onTap: () {
                              //         print("구글 로그인 구현");
                              //       },
                              //     ),
                              //     // SizedBox(width: 60),
                              //     // InkWell(
                              //     //   child:
                              //     //       Image.asset("images/Icon_Facebook.png"),
                              //     //   onTap: () {
                              //     //     print("페이스북 로그인 구현");
                              //     //   },
                              //     // ),
                              //     // SizedBox(width: 60),
                              //     // InkWell(
                              //     //   child: Image.asset("images/Icon_Apple.png"),
                              //     //   onTap: () {
                              //     //     print("애플 로그인 구현");
                              //     //   },
                              //     // ),
                              //   ],
                              // ),
                            ],
                          ),
                        )),
                    /*회원가입 박스*/
                    Visibility(
                        visible: !isSignInSelected,
                        child: Container(
                          decoration: BoxDecoration(color: Color(0XFFA7CDA7)),
                          // 서식박스
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 60,
                                width: (MediaQuery.of(context).size.width),
                              ),

                              Container(
                                /*회원 이름 박스*/
                                width: 300,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF759CB2).withOpacity(0.7),
                                      spreadRadius: 0,
                                      blurRadius: 5.0,
                                      offset: Offset(
                                          0, 10), // changes position of shadow
                                    )
                                  ],
                                ),
                                child: Center(
                                  /*  */
                                  child: TextField(
                                    controller: controller3,
                                    autofocus: false, //true,
                                    textAlign:
                                        TextAlign.center, // 텍스트를 가로 중앙으로 정렬
                                    decoration: InputDecoration(
                                      hintText: 'Your user Name',
                                      border: InputBorder.none, // Remove border
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10 /*horizontal: 20*/),
                                      prefixIcon: Padding(
                                        // 이메일 아이콘
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10.0),
                                        child: Image.asset(
                                          'images/Icon_name.png',
                                          width: 20, // 아이콘의 너비
                                          height: 20, // 아이콘의 높이
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                              // Add spacing between fields
                              Container(
                                /*이메일 박스*/
                                width: 300,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF759CB2).withOpacity(0.7),
                                      spreadRadius: 0,
                                      blurRadius: 5.0,
                                      offset: Offset(
                                          0, 10), // changes position of shadow
                                    )
                                  ],
                                ),
                                child: Center(
                                  /*  */
                                  child: TextField(
                                    controller: controller,
                                    autofocus: false, //true,
                                    textAlign:
                                        TextAlign.center, // 텍스트를 가로 중앙으로 정렬
                                    decoration: InputDecoration(
                                      hintText: 'Example@email.com',
                                      border: InputBorder.none, // Remove border
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10 /*horizontal: 20*/),
                                      prefixIcon: Padding(
                                        // 이메일 아이콘
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10.0),
                                        child: Image.asset(
                                          'images/Icon_email.png',
                                          width: 20, // 아이콘의 너비
                                          height: 20, // 아이콘의 높이
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                              ),
                              /*  */
                              SizedBox(height: 30),
                              // Add spacing between fields
                              Container(
                                /*PW박스 */
                                width: 300,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF759CB2).withOpacity(0.7),
                                      spreadRadius: 0,
                                      blurRadius: 5.0,
                                      offset: Offset(
                                          0, 10), // changes position of shadow
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: TextField(
                                    controller: controller2,
                                    obscureText: _obscureText, // 비밀번호 숨김
                                    autofocus: false, //true,
                                    textAlign:
                                        TextAlign.center, // 텍스트를 가로 중앙으로 정렬
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      border: InputBorder.none, // Remove border
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      prefixIcon: Padding(
                                        // 이메일 아이콘
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _obscureText =
                                                  !_obscureText; // 비밀번호 표시/숨김 전환
                                            });
                                          },
                                          child: Image.asset(
                                            _obscureText
                                                ? 'images/Icon_password.png'
                                                : 'images/Icon_password_ShowPW.png',
                                            width: 12, // 아이콘의 너비
                                            height: 12, // 아이콘의 높이
                                          ),
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(children: [
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width) / 2,
                                ),
                              ]),
                              SizedBox(height: 20),
                              Container(
                                  decoration: BoxDecoration(
                                    color: Color(0XFFA7CDA7),
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color(0xFF759CB2).withOpacity(0.7),
                                        spreadRadius: 0,
                                        blurRadius: 5.0,
                                        offset: Offset(0,
                                            10), // changes position of shadow
                                      )
                                    ],
                                  ),
                                  child: OutlinedButton(
                                      onPressed: () {
                                        if (_accountController
                                            .AfterAuth.isFalse) {
                                          print('인증페이지로 이동');
                                          /*      이전에 세 텍스트 필드가 제대로 되었는지 확인하는 과정 여기에  추가할 것          */

                                          // 이메일 보내는 API 호출
                                          SendVerificationEmail(
                                              controller.text);
                                        }
                                        if (_accountController
                                            .AfterAuth.isTrue) {
                                          registerUser();
                                        } //
                                      },
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        side: BorderSide(
                                            color: Color(0xFFE8EEF1), width: 2),
                                      ),
                                      child: Container(
                                          height: 30,
                                          width: 250,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Text(
                                            'Sign up',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lemon(
                                              fontSize: 20,
                                              color: Color(0xFFFDE599),
                                            ),
                                          )))),
                              SizedBox(height: 30),
                              /* 소셜로그인 업데이트 되면 주석처리 해제하면 됨. */
                              // Text(
                              //   'OR', // TextField의 hintText 대신 텍스트 사용
                              //   textAlign: TextAlign.center,
                              //   style: GoogleFonts.lemon(
                              //     fontSize: 14,
                              //     color: Colors.white,
                              //   ),
                              // ),
                              // Text(
                              //   'Sign up with', // TextField의 hintText 대신 텍스트 사용
                              //   textAlign: TextAlign.center,
                              //   style: GoogleFonts.lemon(
                              //     fontSize: 20,
                              //     color: Colors.white,
                              //   ),
                              // ),

                              SizedBox(height: 20),
                              /* 소셜로그인 업데이트 되면 주석처리 해제하면 됨. */
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     InkWell(
                              //       child:
                              //           Image.asset("images/Icon_Google.png"),
                              //       onTap: () {
                              //         print("구글 회원가입 구현");
                              //       },
                              //     ),
                              //     // SizedBox(width: 60),
                              //     // InkWell(
                              //     //   child:
                              //     //       Image.asset("images/Icon_Facebook.png"),
                              //     //   onTap: () {
                              //     //     print("페이스북 회원가입 구현");
                              //     //   },
                              //     // ),
                              //     // SizedBox(width: 60),
                              //     // InkWell(
                              //     //   child: Image.asset("images/Icon_Apple.png"),
                              //     //   onTap: () {
                              //     //     print("애플 회원가입 구현");
                              //     //   },
                              //     // ),
                              //   ],
                              // ),
                            ],
                          ),
                        )),
                  ])
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
