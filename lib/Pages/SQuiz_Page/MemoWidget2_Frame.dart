import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart'; // Alert 형식 통일
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class MemoWidget2 extends StatefulWidget {
  final List<String> databaseFiles;
  final Future<List<Map<String, dynamic>>> Function(String) getDataFromDatabase;
  final Future<void> Function(String dbName, Map<String, dynamic> quizData)
      updateQuizData;
  final Future<void> Function(int quiznum, String dbName)
      DeleteAndSort;
  const MemoWidget2({
    Key? key,
    required this.databaseFiles,
    required this.getDataFromDatabase,
    required this.updateQuizData,
    required this.DeleteAndSort
  }) : super(key: key);

  @override
  _MemoWidget2State createState() => _MemoWidget2State();
}

class _MemoWidget2State extends State<MemoWidget2> {
  List<Map<String, dynamic>> _dataTable = []; // db의 데이터테이블 내용 저장요소
  String? _selectedDatabaseFile; // 선택된 데이터베이스 파일

  String getOrdinalSuffix(int id) {
    // 일반적으로 사용되는 영어 서수 접미사 규칙 적용
    if (id % 100 >= 11 && id % 100 <= 13) {
      return 'th';
    }
    switch (id % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

/**텍스트 에디팅 에디터*/
  TextEditingController questionController = TextEditingController();
  TextEditingController option1Controller = TextEditingController();
  TextEditingController option2Controller = TextEditingController();
  TextEditingController option3Controller = TextEditingController();
  TextEditingController option4Controller = TextEditingController();
  TextEditingController correctAnswerController = TextEditingController();
/**텍스트 에디팅 에디터*/

  /*삭제 다이얼로그 코드*/
  void _DeleteDialog(int quiznum) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Quiz no.${quiznum}"),
          content: Text("Are you sure you want to delete this Quiz Data?"),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close the dialog
                      /* await _DeleteAndSort(quiznum, _selectedDatabaseFile!); */
                      await widget.DeleteAndSort(quiznum,_selectedDatabaseFile!);
                      Navigator.of(context).pop(); // Close everything
                      //이후 db에서 삭제
                      print('delete completed');
                    },
                    child: Text(
                      "Yes",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 60),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                      "No",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _SaveDialog(int quiznum) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Quiz no.${quiznum}"),
          content: Text("Are you sure you want to update Quiz Data?"),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      result = true;
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                      "Yes",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 60),
                  TextButton(
                    onPressed: () {
                      result = false;
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                      "No",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
    return result;
  }

  void _showBottomSheet(BuildContext context, Map<String, dynamic> quizData) {
    bool WillyouUpdate = false;
    int QuizID = quizData['questionNumber'];
    String IDMethod = getOrdinalSuffix(QuizID);
    String CleanOptions = quizData['options'].replaceAll(RegExp(r'[\[\]]'), '');
    List<String> options = CleanOptions.split(',');
    List<String> cleanedOptionsList = options
        .map((option) => option.trim().replaceAll(RegExp(r'^"|"$'), ''))
        .toList();
    /*초기 컨트롤러 값 설정*/
    questionController.text = quizData['question'];
    option1Controller.text = cleanedOptionsList[0];
    option2Controller.text = cleanedOptionsList[1];
    option3Controller.text = cleanedOptionsList[2];
    option4Controller.text = cleanedOptionsList[3];
    correctAnswerController.text = quizData['correct_answer'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Color(0xFFFDE599),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: controller,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(width: 60),
                        Flexible(
                          child: Text(
                            '퀴즈 $QuizID$IDMethod 수정',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 60),
                        IconButton(
                          icon: Icon(Icons.save),
                          onPressed: () async {
                            // 포멧변환으로 다시 포멧에 맞춘다.
                            String questionText = '${questionController.text}';
                            List<String> UpdatedOptionList = [
                              option1Controller.text,
                              option2Controller.text,
                              option3Controller.text,
                              option4Controller.text
                            ].toList(); //[option1Text,option2Text,option3Text,option4Text];
                            String correctAnswerText =
                                '${correctAnswerController.text}';
                            WillyouUpdate = await _SaveDialog(QuizID);
                            /* 실제 업데이트 구현 */
                            if (WillyouUpdate) {
                              await widget
                                  .updateQuizData(_selectedDatabaseFile!, {
                                'questionNumber': QuizID,
                                'question': questionText,
                                'options': UpdatedOptionList,
                                'correct_answer': correctAnswerText,
                              });
                            }
                            /* 업데이트 종료 */
                            print('퀴즈 ID: $QuizID');
                            print('질문: $questionText');
                            print('선택지: $UpdatedOptionList');
                            print('정답: $correctAnswerText');
                            Navigator.of(context).pop(); // 바텀 시트 닫기
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: '질문',
                      ),
                      controller: questionController,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: '선택지 1',
                              prefixText: '${cleanedOptionsList[0]} → ',
                              prefixStyle: TextStyle(
                                color: Color(0xFF5E8E5E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            controller: option1Controller,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: '선택지 2',
                              prefixText: '${cleanedOptionsList[1]} → ',
                              prefixStyle: TextStyle(
                                color: Color(0xFF5E8E5E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            controller: option2Controller,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: '선택지 3',
                              prefixText: '${cleanedOptionsList[2]} → ',
                              prefixStyle: TextStyle(
                                color: Color(0xFF5E8E5E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            controller: option3Controller,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: '선택지 4',
                              prefixText: '${cleanedOptionsList[3]} → ',
                              prefixStyle: TextStyle(
                                color: Color(0xFF5E8E5E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            controller: option4Controller,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: '정답',
                        prefixText: '${quizData['correct_answer']} → ',
                        prefixStyle: TextStyle(
                          color: Color(0xFF5E8E5E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      controller: correctAnswerController,
                    ),
                    SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: () =>
                          _DeleteDialog(quizData['questionNumber']),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Color(0xFFFFB800),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('삭제', style: TextStyle(color: Colors.black)),
                          SizedBox(width: 10),
                          Icon(Icons.delete, size: 30, color: Colors.black),
                        ],
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/fromDB_Quiz_2.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 60),
          // 선택된 데이터베이스 파일이 없으면 ''를 표시하고,
          // 선택된 데이터베이스 파일이 있으면 해당 데이터를 표시합니다.
          _selectedDatabaseFile == null
              ? Align(
                  /*공통으로 dp할 부분*/
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '   Quiz history  \n',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lemon(
                      fontSize: 18,
                      color: Color(0xFF5E8E5E),
                    ),
                  ))
              : Visibility(
                  // 데이터베이스를 선택하면 해당화면이 보인다.
                  visible: _selectedDatabaseFile != null,
                  child: Expanded(
                    child: ListView.builder(
                      itemCount: _dataTable.length,
                      itemBuilder: (context, index) {
                        return Container(
                            child: Column(
                          children: [
                            Row(
                              // db수정 버튼 +  뒤로가기 버튼
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  //id에 해당하는 퀴즈 수정하는 버튼. bottom sheet 띄울것.
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('edit'),
                                      SizedBox(width: 10),
                                      Icon(Icons.edit),
                                      SizedBox(width: 30),
                                    ],
                                  ),
                                  onTap: () {
                                    // bottom sheet 띄워 수정할 수 있게 구현할것.
                                    print(
                                        '${_dataTable[index]['questionNumber']}');
                                    Map<String, dynamic> quizData =
                                        _dataTable[index];
                                    _showBottomSheet(context, quizData);
                                  },
                                ),
                                InkWell(
                                  //뒤로가기 X버튼: 모든 퀴즈내용 공통.
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('Close'),
                                      SizedBox(width: 10),
                                      Icon(Icons.close),
                                      SizedBox(width: 30),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedDatabaseFile = null;
                                      _dataTable = [];
                                    });
                                  },
                                ),
                              ],
                            ),
                            ListTile(
                              // DB파일 내용
                              /* DB파일 내용 */
                              title: SelectableText(
                                  '\nQuiz No: ${_dataTable[index]['questionNumber']}\nQuestion: ${_dataTable[index]['question']}\n${_dataTable[index]['options']}\nCorrect Answer: ${_dataTable[index]['correct_answer']} \nYour Answer: ${_dataTable[index]['user_answer']}\nCorrect Rate: ${(_dataTable[index]['correct_count'] * 100 / _dataTable[index]['quiz_count']).toStringAsFixed(2)}%, ${_dataTable[index]['quiz_count']}times \n\n'
                                  //_dataTable[index].toString()
                                  ),
                            ),
                            SizedBox(height: 20)
                          ],
                        ));
                      },
                    ),
                  ),
                ),

          // 데이터베이스 파일을 선택할 수 있는 리스트
          Visibility(
            //default로 보이는 텍스트이다.
            visible: _selectedDatabaseFile == null,
            child: Expanded(
              child: ListView.builder(
                itemCount: widget.databaseFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.databaseFiles[index]),
                    // 데이터베이스 파일을 탭하면 해당 데이터베이스 파일의 데이터를 가져와서 표시합니다.
                    onTap: () async {
                      List<Map<String, dynamic>> dataTable = await widget
                          .getDataFromDatabase(widget.databaseFiles[index]);
                      setState(() {
                        _selectedDatabaseFile = widget.databaseFiles[index];
                        _dataTable = dataTable;
                      });
                      print("\n\n\n 저장된 ${_dataTable.length}개 데이터:");
                      print(_dataTable);
                      print("\n\n\n");
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
