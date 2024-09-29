import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Login_Reset_PWPage extends StatefulWidget {
  @override
  _Login_Reset_PWPageState createState() => _Login_Reset_PWPageState();
}

class _Login_Reset_PWPageState extends State<Login_Reset_PWPage> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String newPassword = '';
  String confirmPassword = '';
  bool isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(() {
      setState(() {
        newPassword = newPasswordController.text;
        isPasswordValid =
            newPassword.isNotEmpty && newPassword == confirmPassword;
      });
    });

    confirmPasswordController.addListener(() {
      setState(() {
        confirmPassword = confirmPasswordController.text;
        isPasswordValid =
            newPassword.isNotEmpty && newPassword == confirmPassword;
      });
    });
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
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
                        'Back to Sign in',
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
                      'Reset your password.',
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
                          controller: newPasswordController,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'New Password',
                            border: InputBorder.none, // Remove border
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            prefix: Padding(
                              padding: const EdgeInsets.only(
                                left: 10.0, right: 10.0),
                              child: Image.asset(
                                'images/Icon_password.png',
                                width: 12, // 아이콘의 너비
                                height: 12, // 아이콘의 높이
                              ),
                            ),
                          ),
                          obscureText: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
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
                          controller: confirmPasswordController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            border: InputBorder.none, // Remove border
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            prefix: Padding(
                              padding: const EdgeInsets.only(
                                left: 10.0, right: 10.0),
                              child: Image.asset(
                                'images/Icon_password_tinted.png',
                                width: 12, // 아이콘의 너비
                                height: 12, // 아이콘의 높이
                              ),
                            ),
                          ),
                          obscureText: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 60),
                    Container(
                      width: 300,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isPasswordValid
                            ? Color(0XFF5E8E5E)
                            : Color(0XFFE8EEF1),
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
                        onPressed: isPasswordValid
                            ? () { // ********** ******** *********       /** 여기에 API연동해서 pw재설정하는거 구현하기  */
                                ShowTimedDialog();
                                print('New Password is: $newPassword');
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
                          'Reset Password',
                          style: GoogleFonts.lemon(
                              fontSize: 16,
                              color: isPasswordValid
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
        return AlertDialog(
          contentPadding: EdgeInsets.all(20.0),
          title: Text('Password Reset Successful'),
          content: SizedBox(
            width: 360,
            height: 90, // Increase the height of the SizedBox
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Your password has been reset.\n'),
                Text(
                  'Please sign in with your new password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E8E5E),
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the previous page
                Navigator.of(context).pop(); // Go back to the find_PW page
                Navigator.of(context).pop(); // Go back to the login main page
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
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
