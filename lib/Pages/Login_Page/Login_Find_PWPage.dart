import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Login_Verification.dart';

class Login_Find_PWPage extends StatefulWidget {
  final String CameFrom;
  Login_Find_PWPage(this.CameFrom);
  @override
  _Login_FindPW_PageState createState() => _Login_FindPW_PageState();
}

class _Login_FindPW_PageState extends State<Login_Find_PWPage> {
  TextEditingController controller = TextEditingController();
  String userEmailInput = '';
  bool isEmailValid = false;
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        userEmailInput = controller.text;
        isEmailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(userEmailInput);
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
                  Column(children: [
                    SizedBox(height: 30),
                    Row(children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      SizedBox(width: 20),
                      Text(
                        '${widget.CameFrom}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ]),
                  ]),
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
                      'Enter your Email address associated\nwith your account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF5E8E5E),
                      ),
                    ),
                    SizedBox(height: 40),
                    Container(
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
                            offset: Offset(0, 10), // changes position of shadow
                          )
                        ],
                      ),
                      child: Center(
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          textAlign: TextAlign.center, // 텍스트를 가로 중앙으로 정렬
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
                    SizedBox(height: 60),
                    Container(
                      width: 300,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isEmailValid
                            ? Color(0XFF5E8E5E)
                            : Color(0XFFE8EEF1), //Color(0XFF5E8E5E),
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
                        onPressed: isEmailValid
                            ? () {
                                ShowTimedDialog();
                                print('Input email is: $userEmailInput');
                                print(
                                    'userEmailInput이라는 변수에 이메일 저장했음. API연동할 것.');
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side:
                                BorderSide(color: Color(0xFFE8EEF1), width: 2),
                          ),
                        ),
                        child: Text(
                          'Send verification code',
                          style: GoogleFonts.lemon(
                              fontSize: 16,
                              color: isEmailValid
                                  ? Colors.white
                                  : Color(0XFF5E8E5E)),
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

  void ShowTimedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 4), () {
          /*3초후 자동으로 닫히게 함.*/
          Navigator.of(context).pop(true);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Login_Verification_Page('Your code has been verified successfully.',controller.text))); // 버튼 클릭 시 수행할 액션. 함수 추가
        });
        return AlertDialog(
          contentPadding: EdgeInsets.all(20.0),
          title: Text('Check your email to proceed'),
          content: SizedBox(
            width: 360,
            height: 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Confirmation Code Sent in:'),
                Text(
                  userEmailInput,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E8E5E),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  // 물결장식
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    // Control points for the bezier curve
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
