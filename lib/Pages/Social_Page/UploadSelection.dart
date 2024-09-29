import 'dart:io'; // for "File keyword"
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Alert 형식 통일
import 'package:get/get.dart';
import '/Model/StateManaging.dart';
import 'package:sqflite/sqflite.dart'; // for DB
import 'package:path_provider/path_provider.dart'; // For DB Path
import 'package:path/path.dart'; // for DB path
import 'dart:convert'; // json Convert
import 'package:http/http.dart' as http; // api통신(엔드포인트) 위해.

class UploadSelection extends StatefulWidget {
  final Function externalFunction;

  UploadSelection({required this.externalFunction});

  @override
  _UploadSelectionState createState() => _UploadSelectionState();
}

class _UploadSelectionState extends State<UploadSelection> {
  List<String> _databaseFiles = [];
  String? _selectedDatabaseFile;
  TextEditingController _quizTitleController = TextEditingController();
  bool isFirstPage = true; // 초기 페이지 상태
  String? selectedSubject;
  String subjectCode = '';
  String QuizName = '';
  String JsonRequestBody = '';

  @override
  void initState() {
    super.initState();
    _loadDatabaseFiles();
  }

  Future<void> _loadDatabaseFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final dbFiles = <String>[];
    final files = Directory(path).listSync();
    for (var file in files) {
      if (file is File && file.path.endsWith('.pdf.db')) {
        dbFiles.add(file.path.split('/').last);
      }
    }
    setState(() {
      _databaseFiles = dbFiles;
    });
  }

  Future<List<Map<String, dynamic>>> getDataFromDatabase(String dbName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, dbName);
    final db = await openDatabase(path);
    final List<Map<String, dynamic>> maps = await db.query('quiz_result');
    print('Total quiz items fetched: ${maps.length}'); // 디버깅용

    await db.close();
    return maps;
  }

  String _getDisplayName(String dbName) {
    return dbName.replaceAll('.db', ' Quiz');
  }

  void _onSubjectTap(String name, String code) {
    setState(() {
      selectedSubject = name;
      subjectCode = code;
    });
    print('Selected Subject Code: $subjectCode');
  }

  Future<void> _loadAndPrintDatabaseContent() async {
    print('Loading and printing database content...');

    if (_selectedDatabaseFile != null) {
      final data = await getDataFromDatabase(_selectedDatabaseFile!);
      List<Map<String, dynamic>> modifiedData = [];

      for (var entry in data) {
        // 'options' 필드를 배열로 변환
        var modifiedEntry = Map<String, dynamic>.from(entry);
        modifiedEntry['options'] = jsonDecode(entry['options']);
        modifiedData.add(modifiedEntry);
      }

      var jsonData = jsonEncode(modifiedData);
      jsonData = jsonData.replaceAll(RegExp(r'"user_answer":".*?",'), '');
      jsonData = jsonData.replaceAll(RegExp(r'"correct_count":\d+,'), '');
      jsonData = jsonData.replaceAll(RegExp(r'"quiz_count":\d+,'), '');
      jsonData = jsonData.replaceAll('"correct_answer"', '"answer"');

      setState(() {
        JsonRequestBody = "\"quizesFromGpt\":" + jsonData;
      });

      print(jsonData);
      print('\n변환후\n');
      print(JsonRequestBody);
    } else {
      print('No database file selected.');
    }
  }

  void _updateQuizNameAndPrint() {
    setState(() {
      QuizName = _quizTitleController.text;
    });

    if (QuizName.isNotEmpty) {
      print(QuizName);
    }
  }

  final List<Map<String, String>> subjects = [
    {'name': 'Agricultural Studies', 'code': 'AGRI'},
    {'name': 'Legal Studies', 'code': 'LEGL'},
    {'name': 'Architecture Design', 'code': 'ARCH'},
    {'name': 'Mechanical and Electrical Repair', 'code': 'MECH'},
    {'name': 'Biological Sciences', 'code': 'BIO_'},
    {'name': 'Media Related Communication', 'code': 'MEDI'},
    {'name': 'Business Management', 'code': 'BUSI'},
    {'name': 'Physical Science', 'code': 'PHYS'},
    {'name': 'Computer Science', 'code': 'COMP'},
    {'name': 'Psychology', 'code': 'PSYC'},
    {'name': 'Culinary and Cosmetic Services', 'code': 'CULI'},
    {'name': 'School Administration', 'code': 'SCHL'},
    {'name': 'Engineering', 'code': 'ENGR'},
    {'name': 'The Visual and Performing Arts', 'code': 'ARTS'},
    {'name': 'Health Professions and Medical Services', 'code': 'HLTH'},
    {'name': 'Transportation and Distribution Services', 'code': 'TRAN'},
    {'name': 'Humanities and Liberal Arts', 'code': 'HUMN'},
    {'name': 'ETC', 'code': 'MISC'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 첫 번째 페이지
        Visibility(
            visible: isFirstPage,
            child: Column(children: [
              Container(
                // 장식
                width: double.infinity,
                height: 43,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'images/Memo_Container_Background_image.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 407,
                width: double.infinity,
                decoration: BoxDecoration(color: Color(0xFFFFFDE2)),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              widget.externalFunction();
                            },
                            icon: Icon(Icons.close)),
                        Spacer(),
                        Visibility(
                          visible: (_selectedDatabaseFile != null),
                          child: IconButton(
                            onPressed: () async {
                              print(
                                  'Selected Database File: $_selectedDatabaseFile');
                              print(
                                  'Modified Hint Text: ${_selectedDatabaseFile != null ? _getDisplayName(_selectedDatabaseFile!) : 'Select a database file'}');

                              await _loadAndPrintDatabaseContent();
                              _updateQuizNameAndPrint();
                              setState(() {
                                isFirstPage = false; // 다음 페이지로 이동
                              });
                              print(
                                  'Visibility Check: ${_selectedDatabaseFile != null}');
                            },
                            icon: Icon(Icons.arrow_forward),
                          ),
                        )
                      ],
                    ),
                    Container(
                      height: 250,
                      width: 360,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFAFAEAA), width: 1),
                      ),
                      child: ListView.builder(
                        itemCount: _databaseFiles.length,
                        itemBuilder: (context, index) {
                          final dbName = _databaseFiles[index];
                          final displayName = _getDisplayName(dbName);
                          final isSelected = dbName == _selectedDatabaseFile;
                          return ListTile(
                            title: Text(
                              displayName,
                              style: TextStyle(
                                color: isSelected
                                    ? Color(0xFF3E6426)
                                    : Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                if (_selectedDatabaseFile == dbName) {
                                  _selectedDatabaseFile = null;
                                  _quizTitleController.clear();
                                } else {
                                  _selectedDatabaseFile = dbName;
                                  _quizTitleController.text =
                                      _getDisplayName(dbName);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 350,
                      child: TextField(
                        controller: _quizTitleController,
                        decoration: InputDecoration(
                          labelText: 'Quiz Title',
                          hintText: _selectedDatabaseFile != null
                              ? _getDisplayName(_selectedDatabaseFile!)
                              : 'Select a database file',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ])),
        // 두 번째 페이지
        Visibility(
          visible: !isFirstPage,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 43,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'images/Memo_Container_Background_image.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 407,
                width: double.infinity,
                decoration: BoxDecoration(color: Color(0xFFFFFDE2)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                isFirstPage =
                                    true; // Use this if needed to go back to the first page
                              });
                            },
                            icon: Icon(Icons.arrow_back)),
                        Spacer(),
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: (subjectCode.isNotEmpty)
                              ? () {
                                  showCupertinoDialogFunction(
                                      context,
                                      QuizName,
                                      subjectCode,
                                      JsonRequestBody,
                                      widget.externalFunction);
                                }
                              : null,
                          icon: Icon(Icons.upload),
                          color: (subjectCode.isNotEmpty)
                              ? Color(0XFF5E8E5E)
                              : Colors.grey,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 250,
                      width: 360,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFAFAEAA), width: 1),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 2열로 배치
                                mainAxisSpacing: 10.0, // 세로 간격
                                crossAxisSpacing: 10.0, // 가로 간격
                                childAspectRatio: 3, // 아이템 높이 조절
                              ),
                              itemCount: subjects.length,
                              itemBuilder: (context, index) {
                                String name = subjects[index]['name']!;
                                String code = subjects[index]['code']!;
                                return GestureDetector(
                                  onTap: () => _onSubjectTap(name, code),
                                  child: Container(
                                    color: selectedSubject == name
                                        ? Colors.transparent
                                        : Colors.transparent,
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        color: selectedSubject == name
                                            ? Color(0xFF3E6426)
                                            : Colors.black,
                                        fontWeight: selectedSubject == name
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void showCupertinoDialogFunction(BuildContext context, String Title,
    String QuizCategory, String RequestBody, Function externalFunction) {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text('Upload Alrert'),
        content: Text('Are you sure to upload the quiz?'),
        actions: [
          CupertinoDialogAction(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () {
              UploadRequest(Title, QuizCategory, RequestBody, externalFunction);
              Navigator.of(context).pop();
              //RequestFormat(Title, QuizCategory, RequestBody);
            },
          ),
        ],
      );
    },
  );
}

void showUploadResult(BuildContext context, bool isSucceeded) {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text('Upload Result'),
        content: isSucceeded
            ? Text('Quiz Successfully Uploaded!')
            : Text('Upload failed.'),
      );
    },
  );
}

void RequestFormat(String Title, String QuizCategory, String RequestBody) {
  final AccountController _accountController = Get.put(AccountController());
  String UntouchedJsonForm = '';
  String FinalJsonForm = '';
  //임시 퀴즈코드
  int code = 0031;
  String QuizID = ('#' + QuizCategory + code.toString());
  String UserNickname = _accountController.getUserNickname();
  UntouchedJsonForm = jsonEncode('{' +
      '\"userId\": ' +
      '${_accountController.getUserCode()}' +
      ',' +
      '\"title\": ' +
      '\"$Title\ $QuizID"' +
      ',' +
      '\"category\": ' +
      '\"$QuizCategory\"' +
      ',' +
      '\"uploader\": ' +
      '\"$UserNickname\"' +
      ',' +
      RequestBody +
      '}');
  FinalJsonForm = UntouchedJsonForm.replaceAll(r'\', '');
  print(FinalJsonForm);
}

Future<void> UploadRequest(String Title, String QuizCategory,
    String RequestBody, Function externalFunction) async {
  print('Upload Started...');
  final String url = 'http://13.209.134.75:8080/social/uploadQuiz';
  final headers = {
    'Content-Type': 'application/json',
  };
  final AccountController _accountController = Get.put(AccountController());

  try {
    // 임시 퀴즈코드
    int code = 1; // 백엔드에서 순서대로로 알아서 정해짐
    String QuizID = ('#' + QuizCategory + code.toString());
    String UserNickname = _accountController.getUserNickname();

    // 전체 JSON 데이터 구성 (이중 인코딩 없이 직접 삽입)
    String fullRequestBody = '''
    {
      "userId": ${_accountController.getUserCode()},
      "title": "$Title $QuizID",
      "category": "$QuizCategory",
      "uploader": "$UserNickname",
      $RequestBody
    }
    ''';

    print('Final Encoded RequestBody: $fullRequestBody');

    final response = await http.post(Uri.parse(url),
        headers: headers, body: fullRequestBody);
    if (response.statusCode == 200) {
      print('Successfully Uploaded');
      externalFunction();
    } else {
      print('Error occurred: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Upload Failed: $e');
  }
}
