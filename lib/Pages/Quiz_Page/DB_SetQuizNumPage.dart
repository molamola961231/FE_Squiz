import 'package:flutter/material.dart';
import 'DB_OptionalCardQuiz.dart';

class MakeQuizFromDB extends StatefulWidget {
  final String DB_PDF_NAME;
  final List<Map<String, dynamic>> dataTable;

  MakeQuizFromDB({
    required this.DB_PDF_NAME,
    required this.dataTable,
  });

  @override
  _MakeQuizFromDBState createState() => _MakeQuizFromDBState();
}

class _MakeQuizFromDBState extends State<MakeQuizFromDB> {
  int numberOfQuizzes = 0;
/* 퀴즈의 갯수를 정하면 불러온 dataTable에서 해당 갯수만큼의 퀴즈를 풀이하게 합니당*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffB77D44),
      appBar: AppBar(
        // 선택에 따라 객관식 /주관식으로 나뉨.
        backgroundColor: Color(0xFF6BA16A),
        title: Text('Saved Quiz from ${widget.DB_PDF_NAME}'),
      ),
      body: GestureDetector(
        onTap: () {
          // 키보드가 열려 있을 때 외부 영역 탭하면 포커스를 해제하고 키보드를 숨깁니다.
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Center(
          child: SingleChildScrollView(
            // 입력때문에 자식 위젯이 화면에 표시될 때 화면의 크기를 벗어나게 된다.
            child: Container(
              //카드 서식
              height: 600,
              width: 320,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/Card_Background.png"),
                  fit: BoxFit.cover,
                ),
                color: Colors.white,
                border: Border.all(width: 4, color: Colors.green),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    // 입력창 서식.
                    width: 270,
                    height: 48,
                    decoration: BoxDecoration(
                      // 입력창 장식
                      color: Color(0xFFFFE299), // Box의 배경색
                      borderRadius:
                          BorderRadius.circular(10), // Box의 모서리를 둥글게 설정
                    ),
                    child: TextField(
                      //입력창 영역. 숫자만 입력가능합니다.
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType
                          .number, //숫자만 입력하게 설정하며, 숫자가 아니라면 error처리됨.
                      onChanged: (value) {
                        //입력값이 변경될때마다 콜백되는 함수. 자연수인지를 검산합니다.
                        setState(() {
                          numberOfQuizzes = int.tryParse(value) ??
                              0; // => 입력된 값이 정수로 변환될 수 있다면 해당 값을 numberOfQuizzes에 저장하고, 변환할 수 없는 경우 기본값으로 0을 사용
                        });
                      },
                      decoration: InputDecoration(
                        // 텍스트필드의 힌트가 되는 텍스트입니다.
                        hintText: numberOfQuizzes > 0
                            ? 'How many Quiz Questions?'
                            : 'Please type Right numbers',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  ElevatedButton(
                    // 입력값을 제출하는 버튼입니다. 0보다 작다면 콜백함수의 내용으로 _navigateToQuizScreen(context)가 설정되고, 아니면 null로서 클릭이 불가능합니다.
                    onPressed: numberOfQuizzes > 0 &&
                            numberOfQuizzes <= widget.dataTable.length
                        ? () => navigateToDBQuizPage()
                        // 여기에 콜백함수 구현: 퀴즈 푸는 화면으로 보내보는 것.

                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6BA16A),
                    ),
                    child: Text(
                      'Start Quiz!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /** */
  void navigateToDBQuizPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DB_OptionalCardQuiz(
          dataTable: widget.dataTable.sublist(0, numberOfQuizzes),
          dbPath: widget
              .DB_PDF_NAME, // Assuming DB_PDF_NAME is the path or use the appropriate variable
        ),
      ),
    );
  }
  /** */
}
