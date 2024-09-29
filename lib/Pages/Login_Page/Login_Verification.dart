import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'Login_Reset_PWPage.dart';
import 'dart:convert'; //json 변환
import 'package:http/http.dart' as http; // api통신(엔드포인트) 위해.
import 'package:get/get.dart';
import '/Model/StateManaging.dart'; // 유저 정보 저장및 확인

class Login_Verification_Page extends StatefulWidget {
  final String Message_On_verified; // 추가: 문자열 변수
  final String Email;
  final String? Password; // Made optional
  final String? UserNickname; // Made optional
  Login_Verification_Page(this.Message_On_verified, this.Email,
      {this.Password,
      this.UserNickname}); // Updated constructor to make Password and UserNickname optional

  @override
  _Login_Verification_Page_State createState() =>
      _Login_Verification_Page_State();
}

class _Login_Verification_Page_State extends State<Login_Verification_Page> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();
  TextEditingController controller5 = TextEditingController();
  TextEditingController controller6 = TextEditingController();

  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  FocusNode focusNode5 = FocusNode();
  FocusNode focusNode6 = FocusNode();

  FocusNode focusNodeDummy = FocusNode(); // Add this line

  String verificationCode = ""; // 나중에 이거 서버로 verificationCode전달하게끔.
  bool isVerified = false; //
  final AccountController _accountController = Get.put(AccountController());
  bool isSignup = false; // Initialize to false
  @override
  void initState() {
    super.initState();
    isSignup = widget.Message_On_verified == "SignUp"; // Set value in initState
    focusNode1.requestFocus();
  }


  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    controller4.dispose();
    controller5.dispose();
    controller6.dispose();
    super.dispose();
  }

  void updateVerificationCode() {
    setState(() {
      verificationCode = controller1.text +
          controller2.text +
          controller3.text +
          controller4.text +
          controller5.text +
          controller6.text;
    });
  }

  void handleBackspace(TextEditingController controller, FocusNode currentNode,
      FocusNode prevNode) {
    if (controller.text.isEmpty) {
      FocusScope.of(context).requestFocus(prevNode);
    } else {
      controller.clear();
      updateVerificationCode();
    }
  }

  Future<void> VerifyViaAPI(String email, String authNum) async {
    final String url =
        'http://13.209.134.75:8080/user/mailauthCheck'; // Corrected URL
    final headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> requestBody = {
      'email': email,
      'authNum': authNum,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print(responseBody);
        setState(() {
          isVerified = responseBody['isSuccess'] == true;
          _accountController.updateAfterAuth(true);
        });
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    } finally {
      if (!isSignup) {
        showVerificationDialog(isSignup);
      }
    }
  }

  Future<void> registerUser() async {
    final String url = 'http://13.209.134.75:8080/user/join';
    final headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> requestBody = {
      'nickname': widget.UserNickname,
      'password': widget.Password,
      'email': widget.Email,
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
        // Handle successful registration
        print('Registration successful');
      } else {
        // Handle registration failure
        print('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred during registration: $e');
    } finally {
      showVerificationDialog(isSignup);
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
        print('재전송 완료');
      } else {
        print('Email verification failed: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Widget buildCodeBox(TextEditingController controller, FocusNode currentNode,
      FocusNode nextNode, FocusNode prevNode) {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Color(0xFFE8EEF1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(0xFFBABEC1),
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: currentNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number, // Changed to show only numeric keyboard
        maxLength: 1,
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: "",
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            updateVerificationCode();
            FocusScope.of(context).requestFocus(nextNode);
          } else {
            handleBackspace(controller, currentNode, prevNode);
          }
        },
        onSubmitted: (value) {
          updateVerificationCode();
          FocusScope.of(context).requestFocus(nextNode);
        },
      ),
    );
  }

  void showVerificationDialog(bool isSignup) {
    showDialog(
      context: context,
      barrierDismissible: false, // 다이얼로그 바깥을 클릭해도 닫히지 않도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isVerified == true ? 'Verified!' : 'Verification Fail'),
          content: widget.Message_On_verified ==
                  'Your code has been verified successfully.'
              ? Text(// 비밀번호 재설정의 경우
                  isVerified == true
                      ? widget.Message_On_verified
                      : 'The code you entered is incorrect. Please try again.')
              : Text(// 회원가입의 경우
                      isVerified == true 
                          ? (isSignup 
                              ? 'Verification Succeeded! You can now proceed with signing up' 
                              : 'Congrats! You are now our member!') 
                          : 'The code you entered is incorrect. Please try again.'
                      ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                if (isVerified) {
                  //pw재설정인 경우
                  if (widget.Message_On_verified ==
                      'Your code has been verified successfully.') {
                    print('From finding password page');
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Login_Reset_PWPage()));
                  } else {
                    Navigator.of(context).pop(); // 팝업 제거
                    Navigator.of(context).pop(); // signup페이지로 이동
                  }
                } else {
                  print('실패');
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD4E7D4),
      body: GestureDetector(
        onTap: () {
          // 바깥 영역을 탭했을 때 키보드를 숨깁니다
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      height: 160,
                      color: Color(0xFF5E8E5E),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(height: 30),
                      Row(children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: const Color.fromRGBO(255, 255, 255, 1)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(width: 20),
                        Text(
                          'Back to code',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'images/Find_PW_Lime_Image.png', // Replace with your lemon image asset
                      height: 120,
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Please enter the 6 digit code that \nis sent to your email address',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF5E8E5E),
                      ),
                    ),
                    SizedBox(height: 40),
                    /*입력상자*/
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildCodeBox(controller1, focusNode1, focusNode2,
                            focusNodeDummy), // Use focusNodeDummy
                        buildCodeBox(
                            controller2, focusNode2, focusNode3, focusNode1),
                        buildCodeBox(
                            controller3, focusNode3, focusNode4, focusNode2),
                        buildCodeBox(
                            controller4, focusNode4, focusNode5, focusNode3),
                        buildCodeBox(
                            controller5, focusNode5, focusNode6, focusNode4),
                        buildCodeBox(controller6, focusNode6, focusNodeDummy,
                            focusNode5), // Use focusNodeDummy
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      "If you haven’t received the code",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF868686),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                            width:
                                ((MediaQuery.of(context).size.width) / 2) + 10),
                        TextButton(
                          onPressed: () {
                            SendVerificationEmail(widget.Email);
                          },
                          child: Text(
                            'Resend',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E6426),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: 300,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0XFF5E8E5E),
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
                          print('Email로 보낸 확인 코드 확인하는 API 연동하는 코드');
                          print(verificationCode);
                          VerifyViaAPI(widget.Email, verificationCode);
                          if (widget.Message_On_verified == "SignUp") {
                            registerUser();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side:
                                BorderSide(color: Color(0xFFE8EEF1), width: 2),
                          ),
                        ),
                        child: Text(
                          'Verify and Proceed',
                          style: GoogleFonts.lemon(
                            fontSize: 16,
                            color: Colors.white, // 텍스트 색상을 흰색으로 변경
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    var firstControlPoint = Offset(size.width / 4, size.height - 30);
    var firstEndPoint = Offset(size.width / 2, size.height - 60);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 90);
    var secondEndPoint = Offset(size.width, size.height - 60);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
