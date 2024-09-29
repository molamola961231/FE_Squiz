import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/Model/QuestionModel.dart';
import '/Reusables/DefaultAppBar.dart';
import 'dart:convert'; // utf-8로 컨버트하기 위한 패키지 가져옴
import '/Model/SQLiteQuizModel.dart'; // db저장을 위해.
import '/Pages/SQuiz_Page/Squiz_Main_Page.dart';

class OptionalCardQuiz extends StatefulWidget {
  final List<QuestionModel> loaded_questions; /*json 퀴즈를 불러온 불러온 리스트*/
  final String dbPath; /*퀴즈 데이터가 저장될 db의 path 가져옴*/
  const OptionalCardQuiz(
      {Key? key, required this.loaded_questions, required this.dbPath})
      : super(key: key);

  @override
  _OptionalCardQuiz createState() => _OptionalCardQuiz();
}

class _OptionalCardQuiz extends State<OptionalCardQuiz> {
  int currentIndex =
      0; //  currentIndex가 변경될 때마다 해당 상태를 참조하는 위젯 및 그 자식 위젯들만 다시 그려진다.
  //즉 빌드가 다시 진행되도 currentIndex는 prev / next버튼 통해 변경된 상태로 유지가 되야한다.
  Map<int, String?> userSelections = {}; /* 퀴즈에서 유저가 선택한 옵션 선택하는 선택지 */
  bool GotoResult = false; /* 결과확인페이지로 넘어갈지 결정하는 인자. */

  @override
  Widget build(BuildContext context) {
    // 상위 위젯의 현재 인덱스에 해당하는 변환json데이터를 currentIndex_Quiz라 하겠습니다.
    final currentIndex_Quiz = widget.loaded_questions[currentIndex];

    return Scaffold(
      appBar: DefaultAppBar(),
      backgroundColor: Color(0xffB77D44),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40),
            Visibility(
              //GotoResult가 거짓일때는 퀴즈를 표시합니다.
              visible: !GotoResult,
              child: Container(
                height: 600,
                width: 320,
                decoration: BoxDecoration(
                  /* 카드 디자인 설명 */
                  image: DecorationImage(
                    image: AssetImage('images/Card_Background.png'),
                    fit: BoxFit.cover,
                  ),
                  color: Colors.white,
                  border: Border.all(width: 4, color: Colors.green),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  /* 카드 내용은 column에 배치 */
                  children: [
                    /* [문제박스 디자인 서식 -> 문제박스 내용] , [옵션박스 디자인 서식 -> 디자인박스 내용] */
                    SizedBox(height: 30),
                    Container(
                      /* 문제박스 서식 */
                      height: 200,
                      width: 270,
                      decoration: BoxDecoration(
                        /* 문제박스 데코 */
                        color: Color(0xFFE2F0D9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        /* 문제박스내용  */
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /* 문제 번호 - 문제 쌍 */
                          Padding(
                            /*문제 번호*/
                            padding:
                                const EdgeInsets.only(left: 16.0, top: 10.0),
                            child: Text(
                              /* 문제 번호 */
                              '${currentIndex + 1}번 문제',
                              /* next / prev버튼 조작으로 currentIndex상태가 변하면 해당 위젯의 상태도 변해 새로 렌더링된다 */
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            /* 문제 */
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  utf8.decode(currentIndex_Quiz.question.runes
                                      .toList()),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    /* 문제박스와 옵션박스 간격*/
                    Column(
                      children: [
                        /* 4지선다 박스 생성 */
                        for (int i = 0;
                            i < currentIndex_Quiz.options.length;
                            i++)
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              /* 박스는 클릭시 색깔이 바뀌기에 GestureDector 사용  */
                              onTap: () {
                                /* 누른 선다 숫자 저장. */
                                setState(() {
                                  userSelections[
                                      currentIndex] = currentIndex_Quiz
                                          .options[
                                      i]; /* next / prev버튼 조작으로 currentIndex상태가 변하면 해당 위젯의 상태도 변해 새로 렌더링된다 */
                                });
                              },
                              child: Container(
                                /* 선다박스 */
                                height: 48,
                                width: 270,
                                decoration: BoxDecoration(
                                  color: userSelections[currentIndex] ==
                                          currentIndex_Quiz.options[
                                              i] /* next / prev버튼 조작으로 currentIndex상태가 변하면 해당 위젯의 상태도 변해 새로 렌더링된다 */
                                      ? Color(0xFFE2F0D9) // 사용자가 해당 선택지를 선택한 경우
                                      : Color(
                                          0xFFFFE299), // 사용자가 해당 선택지를 선택하지 않은 경우
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(utf8.decode(currentIndex_Quiz
                                      .options[i].runes
                                      .toList())),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      /* 버튼 행나열 */
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          child: FloatingActionButton(
                            onPressed: () {
                              if (currentIndex > 0) {
                                setState(() {
                                  currentIndex--;
                                });
                              }
                            },
                            child: Icon(Icons.arrow_back, color: Colors.white),
                            backgroundColor: Colors.green,
                            mini: false,
                            heroTag: null,
                          ),
                        ),
                        SizedBox(
                          width: 130,
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          child: FloatingActionButton(
                            /*다음버튼*/
                            onPressed: () {
                              if (currentIndex <
                                  widget.loaded_questions.length - 1) {
                                setState(() {
                                  currentIndex++;
                                });
                              } else {
                                // Show results
                                /**/ _Show_HandIn_Dicision_Dialog();
                                /**/ print('Popup에서 눌린 값: ${GotoResult}');
                                UpdateDatabase();
                                _showResults();
                                //dialog써볼까?
                              }
                            },
                            backgroundColor: currentIndex <
                                    widget.loaded_questions.length - 1
                                ? Colors.green
                                : Color(0xFFFAEA59), //Colors.green, //
                            mini: false,
                            heroTag: null,

                            child: currentIndex <
                                    widget.loaded_questions.length - 1
                                ? Icon(Icons.arrow_forward, color: Colors.white)
                                : Icon(Icons.check,
                                    color: Colors.green /*Colors.white*/),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              //결과페이지
              visible: GotoResult, // GotoResult가 true일 때 결과 페이지 표시
              child: Container(
                height: 600,
                width: 320,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/Card_Background.png'),
                    fit: BoxFit.cover,
                  ),
                  color: Color(0xFFE2F0D9),
                  border: Border.all(width: 4, color: Colors.green),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Container(
                      // 문제 박스
                      height: 200,
                      width: 270,
                      decoration: BoxDecoration(
                        color: userSelections[currentIndex] ==
                                widget.loaded_questions[currentIndex].answer
                            ? Color(0xFFC4F398)
                            : Color(0xFFFFCEB3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Text(
                          '${currentIndex + 1}번 문제: ${widget.loaded_questions[currentIndex].question}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Column(
                      // 선다박스
                      children: widget.loaded_questions[currentIndex].options
                          .map((option) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: 48,
                            width: 270,
                            decoration: BoxDecoration(
                              color: option ==
                                      widget
                                          .loaded_questions[currentIndex].answer
                                  ? Color(0xFFC4F398)
                                  : Color(0xFFFFCEB3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    option,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (userSelections[currentIndex] == option)
                                  Icon(Icons.check, color: Colors.orange),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 15),
                    Row(
                      /* 버튼 행나열 */
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          child: FloatingActionButton(
                            onPressed: () {
                              if (currentIndex > 0) {
                                setState(() {
                                  currentIndex--;
                                });
                              }
                            },
                            child: Icon(Icons.arrow_back, color: Colors.white),
                            backgroundColor: Colors.green,
                            mini: false,
                            heroTag: null,
                          ),
                        ),
                        SizedBox(
                          width: 130,
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          child: FloatingActionButton(
                            /*다음버튼*/
                            onPressed: () {
                              if (currentIndex <
                                  widget.loaded_questions.length - 1) {
                                setState(() {
                                  currentIndex++;
                                });
                              } else {
                                // 결과 보여줬으니....이거 홈페이지로 돌아가기 가능? 흠...
                                _showResults();
                                for (int i = 0; i < 4; i++) {
                                  Navigator.pop(context);
                                }

                                //dialog써볼까?
                              }
                            },
                            backgroundColor: currentIndex <
                                    widget.loaded_questions.length - 1
                                ? Colors.green
                                : Color(0xFFFAEA59), //Colors.green, //
                            mini: false,
                            heroTag: null,

                            child: currentIndex <
                                    widget.loaded_questions.length - 1
                                ? Icon(Icons.arrow_forward, color: Colors.white)
                                : Icon(Icons.check,
                                    color: Colors.green /*Colors.white*/),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResults() {
    for (int i = 0; i < widget.loaded_questions.length; i++) {
      print('Question ${i + 1}: ${widget.loaded_questions[i].question}');
      print('Selected Answer: ${userSelections[i]}');
      print('Correct Answer: ${widget.loaded_questions[i].answer}');
      print(
          'Is Correct: ${userSelections[i] == widget.loaded_questions[i].answer}');
    }
  }

  void _Show_HandIn_Dicision_Dialog(
      /*bool GotoResult값을 변동합니다. true로 변동시키고 난 다음엔 UpdateDatabase를 실행할겁니다 */) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
              title: Text('Are you sure you want to submit your answers?'),
              //content: Text('if you submit, you'll see the results'),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context); //다이얼로그 닫고 state관리
                    setState(() {
                      GotoResult = false;
                    });
                  },
                  child: Text(
                    'No',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context); //다이얼로그 닫고 정답창으로 가기위한 state관리
                    setState(() {
                      GotoResult = true;
                      currentIndex = 0;
                    });
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ]);
        });
  }

  void UpdateDatabase() async {
    final db = await SQLiteQuestionModel.OpenDatabaseFrom(widget.dbPath);

    for (int i = 0; i < widget.loaded_questions.length; i++) {
      QuestionModel question = widget.loaded_questions[i];
      String? userAnswer = userSelections[i];
      bool isCorrect = userAnswer != null && userAnswer == question.answer;

      await SQLiteQuestionModel.updateQuizResults(
          db, question.questionNumber, userAnswer ?? '', isCorrect);
    }

    db.close(); // Ensure to close the database after operations
    print('Database updated successfully.');
  }
}
