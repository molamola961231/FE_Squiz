import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/Model/QuestionModel.dart';
import '/Reusables/DefaultAppBar.dart';
import '/Model/SQLiteQuizModel.dart'; // Import SQLiteQuestionModel for database operations

class SocialCardQuiz extends StatefulWidget {
  final List<Map<String, dynamic>> QuizContents;
  final String QuizName;
  const SocialCardQuiz(
      {Key? key, required this.QuizContents, required this.QuizName})
      : super(key: key);

  @override
  _SocialCardQuiz createState() => _SocialCardQuiz();
}

class _SocialCardQuiz extends State<SocialCardQuiz> {
  int currentIndex = 0;
  Map<int, String?> userSelections = {};
  bool GotoResult = false;

  List<QuestionModel> loaded_questions = [];

  @override
  void initState() {
    super.initState();
    loaded_questions = widget.QuizContents.map((q) => QuestionModel(
        questionNumber: q['questionNumber'],
        question: q['question'],
        options: List<String>.from(q['options']),
        answer: q['answer'])).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex_Quiz = loaded_questions[currentIndex];

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
                                  currentIndex_Quiz.question,
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
                            i < currentIndex_Quiz.options.length;
                            i++)
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  userSelections[currentIndex] =
                                      currentIndex_Quiz.options[i];
                                });
                              },
                              child: Container(
                                height: 48,
                                width: 270,
                                decoration: BoxDecoration(
                                  color: userSelections[currentIndex] ==
                                          currentIndex_Quiz.options[i]
                                      ? Color(0xFFE2F0D9)
                                      : Color(0xFFFFE299),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(currentIndex_Quiz.options[i]),
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
                            onPressed: () {
                              if (currentIndex < loaded_questions.length - 1) {
                                setState(() {
                                  currentIndex++;
                                });
                              } else {
                                _Show_HandIn_Dicision_Dialog();
                                UpdateDatabase();
                                _showResults();
                              }
                            },
                            backgroundColor:
                                currentIndex < loaded_questions.length - 1
                                    ? Colors.green
                                    : Color(0xFFFAEA59),
                            mini: false,
                            heroTag: null,
                            child: currentIndex < loaded_questions.length - 1
                                ? Icon(Icons.arrow_forward, color: Colors.white)
                                : Icon(Icons.check, color: Colors.green),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: GotoResult,
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
                      height: 200,
                      width: 270,
                      decoration: BoxDecoration(
                        color: userSelections[currentIndex] ==
                                loaded_questions[currentIndex].answer
                            ? Color(0xFFC4F398)
                            : Color(0xFFFFCEB3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Text(
                          '${currentIndex + 1}번 문제: ${loaded_questions[currentIndex].question}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Column(
                      children:
                          loaded_questions[currentIndex].options.map((option) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: 48,
                            width: 270,
                            decoration: BoxDecoration(
                              color: option ==
                                      loaded_questions[currentIndex].answer
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
                            onPressed: () {
                              if (currentIndex < loaded_questions.length - 1) {
                                setState(() {
                                  currentIndex++;
                                });
                              } else {
                                _showResults();
                                Navigator.pop(context);
                                // for (int i = 0; i < 4; i++) {
                                //   Navigator.pop(context);
                                // }
                              }
                            },
                            backgroundColor:
                                currentIndex < loaded_questions.length - 1
                                    ? Colors.green
                                    : Color(0xFFFAEA59),
                            mini: false,
                            heroTag: null,
                            child: currentIndex < loaded_questions.length - 1
                                ? Icon(Icons.arrow_forward, color: Colors.white)
                                : Icon(Icons.check, color: Colors.green),
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
    // for (int i = 0; i < 2; i++) {
    //   Navigator.pop(context);
    // }
    setState(() {
      GotoResult = true;
      currentIndex = 0;
    });
  }

  void _Show_HandIn_Dicision_Dialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("퀴즈 제출"),
          content: Text("정말 퀴즈를 제출하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/QuizList');
              },
              child: Text("예"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("아니오"),
            ),
          ],
        );
      },
    );
  }

  void UpdateDatabase() async {
    final databaseName = '${widget.QuizName}.pdf';
    final db = await SQLiteQuestionModel.OpenDatabaseFrom(databaseName);

    for (int i = 0; i < loaded_questions.length; i++) {
      QuestionModel question = loaded_questions[i];
      String? userAnswer = userSelections[i];
      bool isCorrect = userAnswer != null && userAnswer == question.answer;

      // await SQLiteQuestionModel.updateQuizResults(
      //     db, question.questionNumber, userAnswer ?? '', isCorrect);
      await SQLiteQuestionModel.CreateOrupdateQuizFromtheServer(db, loaded_questions[i], userAnswer, isCorrect);
    }

    db.close(); // Ensure to close the database after operations
    print('Database updated successfully.');
  }
}
