import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'QuestionModel.dart';
import 'dart:io';

/* sqlite 기본 설명
내부 저장소에 DB를 생성하는 SQLite 스토리지 클래스(데이터타입)

  - NULL: 값이 없음을 나타냅니다.
  - INTEGER: 부호 있는 정수 값(예: 1, 2, -3)으로 저장됩니다.
  - REAL: 부동 소수점 숫자 값(예: 3.14, -2.0)을 나타냅니다.
  - TEXT: 텍스트 문자열로 저장됩니다. 일반적으로 UTF-8, UTF-16 인코딩을 사용합니다.
  - BLOB: 이진 데이터로 저장되며, 입력된 그대로 저장됩니다
*/
/* 변환 대상 소개
  int id;
  String question;
  List<String> options;
  String answer;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
  });
위 클래스는 json형식의 data를 flutter에서 사용 할 수 있게하는 클래스이다.
*/
/* 데이터테이블과 column설명 
  데이터 베이스는 pdf_squeeze로 설정하고, 해당 db파일에는 퀴즈데이터를 삽입한다. 
  데이터 테이블은 SQLite에 db로 데이터를 저장하기위한 데이터 테이블이다. 
  데이터 테이블의 이름은 quiz_result로 설정한다.
  List<QuestionModel>타입을 해석 대상으로 삼는다...

 questionNumber INTEGER PRIMARY KEY       : 퀴즈의 index.
 question TEXT                : 퀴즈 내용.
 options TEXT                 : 퀴즈 4지선다 옵션(선택지).
 correct_answer TEXT          : 퀴즈 정답.
 user_prev_answer TEXT        : 이전 유저 선택.
 correct_counter INTEGER      
 quiz_counter INTEGER         : quiz_counter는 퀴즈문항 호출 횟수,  correct_counter는 해당 문항 정답 횟수로 
 나중에 두 int val을 이용해 정답률을 설정함.

 */

/*code below*/
class SQLiteQuestionModel {
  /*  DB생성하는 클래스에 접근할 수 있는 모듈화된 Public클래스  */
  static Future<Database> OpenDatabaseFrom(String dbName) async {
    return _OpenDatabase(dbName);
  }

  /* DB를 생성하고 sqlite db를 열어 작업하는 private클래스. 가장 먼저 호출해야되며, 삭제작업 실행시 close해줘야 반영된다. */
  static Future<Database> _OpenDatabase(String dbName) async {
    // 없으면 db생성하고 파일을 열고, 있다면 기존db를 열고 db실행 플러그인 반환.
    final documentsDirectory =
        await getApplicationDocumentsDirectory(); // 앱 내부 디렉토리
    final path = join(documentsDirectory.path, '$dbName.db'); //  db의 디렉토리
    final dbFile = File(path); // db디렉토리에서 실제 파일을 지칭
    final dbExists = await dbFile.exists(); // db디렉토리에서 실제 파일의 존재여부 반환

    if (!dbExists) {
      //  db파일 존재하지 않는경우에만 생성하는 메커니즘. log출력 먼저.
      print('');
      print('');
      print(
          '\nNo Existing Database Found: Creating DatabaseFile: $dbName on $path.\n');
      print('Creating Now $dbName Database on $path ');
      print('Log from SQLiteQuizModel.dart');
      print('');
      print('');
      return openDatabase(
        //  스키마에의해 db를 저장하는 메커니즘. "새로 생성된 db" 반환
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
              CREATE TABLE quiz_result (
                questionNumber INTEGER PRIMARY KEY,
                question TEXT,
                options TEXT,
                correct_answer TEXT,
                user_answer TEXT,
                correct_count INTEGER,
                quiz_count INTEGER
              )
              ''');
        },
      );
    } else {
      // 이미 존재하는 경우에는 log 출력후 "기존 데이터베이스"를 반환
      print('');
      print('');
      print(
          '\nDatabase file already exists: $dbName on $path. Opened Database: $dbName');
      print('Log from SQLiteQuizModel.dart');
      print('');
      print('');
      return openDatabase(path);
    }
  }

  /* Log출력 code: db 테이블 요소 모두 출력하는 함수 */
  static Future<void> printAllQuestions(String PDFName) async {
    // db 테이블 요소 모두 출력하는 함수
    final db = await _OpenDatabase(PDFName);
    final List<Map<String, dynamic>> maps = await db.query('quiz_result');
    if (maps.isEmpty) {
      print("No questions found in the database.");
    } else {
      print("Log from SQLiteQuizModel");
      for (var map in maps) {
        print(
            "ID: ${map['questionNumber']}, Question: ${map['question']}, Options: ${map['options']}, Correct Answer: ${map['correct_answer']}, User Answer: ${map['user_answer']}, Correct Count: ${map['correct_count']}, Quiz Count: ${map['quiz_count']}");
      }
    }
  }

  /* [C]rud: Create... Fn(Target, To) */
  static Future<void> saveItToDatabase(
      List<QuestionModel> questions, String PDFName) async {
    final db = await _OpenDatabase(PDFName); //db 실행.

    // 데이터베이스 파일이 성공적으로 만둘어졌는지 확인
    final dbExists = await db.isOpen;

    if (dbExists) {
      //db정상존재 출력log
      print('Database file Successfully Loaded $PDFName');
      print('Log from SQLiteQuizModel.dart');
      print('');
      print('');
    } else {
      print('Something is Wrong: Error Loading $PDFName');
      print('Log from SQLiteQuizModel.dart');
      print('');
      print('');
    }

    // 현재 데이터베이스에서 가장 높은 questionNumber 값을 찾습니다.
    final List<Map<String, dynamic>> maxQuestionNumberResult =
        await db.rawQuery(
            'SELECT MAX(questionNumber) as maxQuestionNumber FROM quiz_result');
    int currentMaxQuestionNumber =
        maxQuestionNumberResult[0]['maxQuestionNumber'] ?? 0;

    // 데이터베이스 테이블에 List<Question>형태의 데이터를 추가
    for (var question in questions) {
      currentMaxQuestionNumber++; // 새로운 질문 번호로 설정

      // 새로운 문제를 데이터베이스에 추가
      await db.insert(
        'quiz_result',
        {
          'questionNumber': currentMaxQuestionNumber,
          'question': question.question,
          'options': jsonEncode(question.options),
          'correct_answer': question.answer,
          'user_answer': '',
          'correct_count': 0,
          'quiz_count': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  /* cru[D]: Delete... Fn(Target) */
  static Future<void> deleteDatabaseFile(String dbName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, dbName);
    final db = await openDatabase(path);

    // 데이터베이스 파일을 사용하고 있는 연결을 닫아야 나중에 동일이름의 db를 생성가능하다.
    // 그렇지 않으면 파일이 사용 중이라는 오류가 발생할 수 있으며, 이는 파일 삭제를 방해할 수 있다.
    await db.close();

    final file = File(path);
    if (await file.exists()) {
      try {
        await file.delete();
        print('$dbName deleted successfully.');
      } catch (e) {
        print('Error deleting $dbName: $e');
      }
    } else {
      print('$dbName does not exist.');
    }
  }

  /* cr[U]de: Update... Fn(To, Target_1,Target_2,Target_3) */
  static Future<void> updateQuizResults(
      Database db, int questionId, String userAnswer, bool isCorrect) async {
    final record = await db.query(
      //테이블중에 id값이 존재하는 테이블에  대해 업데이트.
      'quiz_result',
      where: 'questionNumber = ?',
      whereArgs: [questionId],
    );

    if (record.isNotEmpty) {
      /* 퀴즈 카운트 오류 수정...2024.09.01 */
      int correctCount = (record.first['correct_count'] as int?) ?? 0;
      int quizCount = (record.first['quiz_count'] as int?) ?? 0;
      await db.update(
        'quiz_result',
        {
          'user_answer': userAnswer,
          'correct_count': correctCount + (isCorrect ? 1 : 0),
          // 해당 코드는 null에러 존재할 수 있다. (record.first['correct_count'] as int) + (isCorrect ? 1 : 0),
          'quiz_count': quizCount + 1,
          //해당 코드는 null에러 존재할 수 있다. (record.first['quiz_count'] as int) + 1,
        },
        where: 'questionNumber = ?',
        whereArgs: [questionId],
      );
    } else {
      await db.insert(
        'quiz_result',
        {
          'questionNumber': questionId,
          'question': '',
          'options': '',
          'correct_answer': '',
          'user_answer': userAnswer,
          'correct_count': isCorrect ? 1 : 0,
          'quiz_count': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /* [CR][U]de: Create & Update... Fn(To, Target_1,Target_2,Target_3) */
  static Future<void> CreateOrupdateQuizFromtheServer(Database db,
      QuestionModel quizData, String? userAnswer, bool isCorrect) async {
    final record = await db.query(
      //테이블중에 id값이 존재하는 테이블에  대해 업데이트.
      'quiz_result',
      where: 'questionNumber = ?',
      whereArgs: [quizData.questionNumber],
    );

    if (record.isNotEmpty) {
      await db.update(
        'quiz_result',
        {
          'user_answer': userAnswer,
          'correct_count':
              (record.first['correct_count'] as int) + (isCorrect ? 1 : 0),
          'quiz_count': (record.first['quiz_count'] as int) + 1,
        },
        where: 'questionNumber = ?',
        whereArgs: [quizData.questionNumber],
      );
    } else {
      print('SQLiteQuizModel_\nDB created:${quizData.questionNumber}');
      await db.insert(
        'quiz_result',
        {
          'questionNumber': quizData.questionNumber,
          'question': quizData.question,
          'options': jsonEncode(quizData.options),
          'correct_answer': quizData.answer,
          'user_answer': userAnswer,
          'correct_count': isCorrect ? 1 : 0,
          'quiz_count': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
