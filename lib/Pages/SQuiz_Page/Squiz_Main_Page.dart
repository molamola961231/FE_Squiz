import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'MemoWidget1_Frame.dart';
import 'MemoWidget2_Frame.dart';
import 'dart:convert';

class DatabaseCheckPage extends StatefulWidget {
  @override
  DatabaseCheckPageState createState() => DatabaseCheckPageState();
}

class DatabaseCheckPageState extends State<DatabaseCheckPage> {
  List<String> _databaseFiles =
      []; // 해당 리스트는 나중에 _loadDatabaseFiles 통해 dbFiles로 초기화됨.

  @override
  void initState() {
    super.initState();
    _loadDatabaseFiles();
  }

  Future<void> _loadDatabaseFiles() async {
    //전체 db파일 로드.
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

  Future<void> _printDatabaseContent(String dbName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, dbName);
    final db = await openDatabase(path);
    final List<Map<String, dynamic>> maps = await db.query('quiz_result');
    if (maps.isEmpty) {
      print("No questions found in the database.");
    } else {
      for (var map in maps) {
        print(
            "ID: ${map['id']}, Question: ${map['question']}, Options: ${map['options']}, Correct Answer: ${map['correct_answer']}, User Answer: ${map['user_answer']}, Correct Count: ${map['correct_count']}, Quiz Count: ${map['quiz_count']}");
      }
    }
  }

  /*  SQLiteQuizModel의 CRU[D]를 사용하면 Memo에서 delete에 대한 UI반영이 안되기에 여기서 직접 구현했다. */
  Future<void> _deleteDatabaseFile(String dbName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, dbName);
    final db = await openDatabase(path);
    await db.close();
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      print('$dbName deleted successfully.');
      _loadDatabaseFiles();
    } else {
      print('$dbName does not exist.');
    }
  }

Future<void> DeleteAndSort(int quiznum, String dbName) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = join(directory.path, dbName);
  final db = await openDatabase(path);

  try {
    // 'quiznum'에 해당하는 모든 데이터를 삭제
    await db.delete(
      'quiz_result',
      where: 'questionNumber = ?',
      whereArgs: [quiznum],
    );

    // 삭제 후 남은 데이터를 가져옴
    final List<Map<String, dynamic>> remainingQuizzes = await db.query(
      'quiz_result',
      orderBy: 'questionNumber ASC',
    );

    // 기존 테이블 완전히 비우기
    await db.delete('quiz_result');

    // 새로운 questionNumber를 1부터 재할당하며 데이터를 삽입
    for (int i = 0; i < remainingQuizzes.length; i++) {
      int newQuestionNumber = i + 1; // 새로운 questionNumber는 1부터 시작

      // 남은 퀴즈 데이터를 새로운 questionNumber로 삽입
      await db.insert(
        'quiz_result',
        {
          'questionNumber': newQuestionNumber,
          'question': remainingQuizzes[i]['question'],
          'options': remainingQuizzes[i]['options'],
          'correct_answer': remainingQuizzes[i]['correct_answer'],
          'user_answer': remainingQuizzes[i]['user_answer'],
          'correct_count': remainingQuizzes[i]['correct_count'],
          'quiz_count': remainingQuizzes[i]['quiz_count'],
        },
      );
    }
  } catch (e) {
    print('Error during DeleteAndSort: $e');
  } finally {
    // 데이터베이스 닫기
     db.close(); // 09.24 추가....
    await db.close();
  }
}



  Future<List<Map<String, dynamic>>> getDataFromDatabase(String dbName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, dbName);
    final db = await openDatabase(path);
    final List<Map<String, dynamic>> maps = await db.query('quiz_result');
    if (maps.isEmpty) {
      print("No questions found in the database.");
    } else {
      print('데이터 로드 성공: $dbName \n--Log from Squiz_MainPage.dart--');
    }
    await db.close();
    return maps;
  }

  /** 업데이트퀴즈데이터 **/
  Future<void> updateQuizData(
      String dbName, Map<String, dynamic> quizData) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, dbName);
    final db = await openDatabase(path, version: 1);

    // Format the options list into a JSON array string
    List<String> options = quizData['options'];
    String formattedOptions = jsonEncode(options);

    // Update the quiz data in the database
    await db.update(
      'quiz_result',
      {
        'question': quizData['question'],
        'options': formattedOptions,
        'correct_answer': quizData['correct_answer'],
      },
      where: 'id = ?',
      whereArgs: [quizData['id']],
    );

    await db.close();
  }

  /** */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB77D44),
      body: ListView(
        children: [
          MemoWidget1(
            databaseFiles: _databaseFiles,
            onDelete: _deleteDatabaseFile,
            onTap: () {
              print('Quiz card tapped!');
            },
          ),
          SizedBox(height: 40),
          MemoWidget2(
            databaseFiles: _databaseFiles,
            getDataFromDatabase: getDataFromDatabase,
            updateQuizData: updateQuizData,
            DeleteAndSort: DeleteAndSort,
          ),
        ],
      ),
    );
  }
}
