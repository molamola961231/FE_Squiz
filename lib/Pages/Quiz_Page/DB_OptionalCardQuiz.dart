import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '/Reusables/DefaultAppBar.dart';
import '/Model/SQLiteQuizModel.dart'; // For DB storage.

class DB_OptionalCardQuiz extends StatefulWidget {
  final List<Map<String, dynamic>> dataTable; // Data from database.
  final String dbPath; // Path to the database where quiz data is stored.

  const DB_OptionalCardQuiz(
      {Key? key, required this.dataTable, required this.dbPath})
      : super(key: key);

  @override
  _DB_OptionalCardQuiz createState() => _DB_OptionalCardQuiz();
}

class _DB_OptionalCardQuiz extends State<DB_OptionalCardQuiz> {
  int currentIndex = 0;
  Map<int, String?> userSelections = {};
  bool GotoResult = false;
  List<Widget> optionWidgets = []; // 옵션 위젯 리스트 초기화

  @override
  Widget build(BuildContext context) {
    // Current quiz data from dataTable using currentIndex.
    var currentIndex_Quiz = widget.dataTable[currentIndex];

    return Scaffold(
      appBar: DefaultAppBar(),
      backgroundColor: Color(0xffB77D44),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40),
            Visibility(
              visible: !GotoResult,
              child: Container(
                height: 600,
                width: 320,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/Card_Background.png'),
                    fit: BoxFit.cover,
                  ),
                  color: Colors.white,
                  border: Border.all(width: 4, color: Colors.green),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Container(
                      height: 200,
                      width: 270,
                      decoration: BoxDecoration(
                        color: Color(0xFFE2F0D9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, top: 10.0),
                            child: Text(
                              '${currentIndex + 1}번 문제',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  currentIndex_Quiz['question'],
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Column(
                      children: [
                        for (int i = 0;
                            i < currentIndex_Quiz['options'].length;
                            i++)
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  userSelections[currentIndex] =
                                      currentIndex_Quiz['options'][i];
                                });
                              },
                              child: Container(
                                height: 48,
                                width: 270,
                                decoration: BoxDecoration(
                                  color: userSelections[currentIndex] ==
                                          currentIndex_Quiz['options'][i]
                                      ? Color(0xFFE2F0D9)
                                      : Color(0xFFFFE299),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(currentIndex_Quiz['options'][i]),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            if (currentIndex > 0) {
                              setState(() {
                                currentIndex--;
                              });
                            }
                          },
                          child: Icon(Icons.arrow_back, color: Colors.white),
                          backgroundColor: Colors.green,
                        ),
                        SizedBox(
                          width: 130,
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            if (currentIndex < widget.dataTable.length - 1) {
                              setState(() {
                                currentIndex++;
                              });
                            } else {
                              _Show_HandIn_Dicision_Dialog();
                              print('Popup에서 눌린 값: ${GotoResult}');
                              UpdateDatabase(widget.dbPath);
                              _showResults();
                            }
                          },
                          backgroundColor:
                              currentIndex < widget.dataTable.length - 1
                                  ? Colors.green
                                  : Color(0xFFFAEA59),
                          child: currentIndex < widget.dataTable.length - 1
                              ? Icon(Icons.arrow_forward, color: Colors.white)
                              : Icon(Icons.check, color: Colors.green),
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
                        // widget.dataTable[i]['answer']
                        color: userSelections[currentIndex] ==
                                widget.dataTable[currentIndex]['correct_answer']
                            ? Color(0xFFC4F398)
                            : Color(0xFFFFCEB3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Text(
                          '${currentIndex + 1}번 문제: ${widget.dataTable[currentIndex]['question']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Column(
                      children: [
                        for (int i = 0;
                            i < currentIndex_Quiz['options'].length;
                            i++)
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              height: 48,
                              width: 270,
                              decoration: BoxDecoration(
                                color: userSelections[currentIndex] ==
                                        currentIndex_Quiz['options'][i]
                                    ? Color(0xFFC4F398)
                                    : Color(0xFFFFCEB3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      currentIndex_Quiz['options'][i],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (userSelections[currentIndex] ==
                                      currentIndex_Quiz['options'][i])
                                    Icon(Icons.check, color: Colors.orange),
                                ],
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
                              if (currentIndex < widget.dataTable.length - 1) {
                                setState(() {
                                  currentIndex++;
                                });
                              } else {
                                // 결과 보여줬으니....이거 홈페이지로 돌아가기 가능? 흠...
                                UpdateDatabase(widget.dbPath);
                                _showResults();
                                while (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                                //dialog써볼까?
                              }
                            },
                            backgroundColor:
                                currentIndex < widget.dataTable.length - 1
                                    ? Colors.green
                                    : Color(0xFFFAEA59), //Colors.green, //
                            mini: false,
                            heroTag: null,

                            child: currentIndex < widget.dataTable.length - 1
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
    for (int i = 0; i < widget.dataTable.length; i++) {
      print('Question ${i + 1}: ${widget.dataTable[i]['question']}');
      print('Selected Answer: ${userSelections[i]}');
      print('Correct Answer: ${widget.dataTable[i]['correct_answer']}');
      print(
          'Is Correct: ${userSelections[i] == widget.dataTable[i]['correct_answer']}');
      print(widget.dataTable);
    }
  }

  void _Show_HandIn_Dicision_Dialog() {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
              title: Text('Are you sure you want to submit your answers?'),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
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
                    Navigator.pop(context);
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

  void UpdateDatabase(String dbPath) async {
    print('db open: ${dbPath}');
    dbPath = dbPath.replaceAll('.db', '');
    try {
      final db =
          await SQLiteQuestionModel.OpenDatabaseFrom(dbPath); // 경로 수정하지 않음

      for (int i = 0; i < widget.dataTable.length; i++) {
        Map<String, dynamic> question = widget.dataTable[i];
        int? questionId = question['questionNumber']; // id 값 가져오기...db의 ksy값이 달라 null에러 발행했었음....
        if (questionId == null) {
          print('Question ID is null for question: ${question['question']}');
          continue; // ID가 null이면 건너뛰기
        }
        String? userAnswer = userSelections[i];
        bool isCorrect =
            userAnswer != null && userAnswer == question['correct_answer'];

        await SQLiteQuestionModel.updateQuizResults(
            db, questionId, userAnswer ?? '', isCorrect);
      }

      db.close();
      print('Database updated successfully.');
    } catch (e) {
      print('log from DB_OptionalCardQuiz.dart:\Failed to update database: $e');
    }
  }
}
