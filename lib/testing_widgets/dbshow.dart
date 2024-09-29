import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:google_fonts/google_fonts.dart'; // flutter pub add google_fonts




class DatabaseCheckPage extends StatefulWidget {
  @override
  _DatabaseCheckPageState createState() => _DatabaseCheckPageState();
}

class _DatabaseCheckPageState extends State<DatabaseCheckPage> {
  List<String> _databaseFiles = []; // 해당 리스트는 나중에 _loadDatabaseFiles 통해 dbFiles로 초기화됨.

  @override
  void initState() {
    super.initState();
    _loadDatabaseFiles();
  }

  Future<void> _loadDatabaseFiles() async {
    final directory = await getApplicationDocumentsDirectory(); // 플랫폼 따라 달라짐. 반환값: 해당 앱 내부저장소
    final path = directory.path; // 해당 앱 내부저장소의 주소를 반환.
    final dbFiles = <String>[];

    final files = Directory(path).listSync();
    for (var file in files) { // iterator사용해 내부저장소 모든 요소에 대해
      if (file is File && file.path.endsWith('.db')) { // 디렉토리에서 '.db'가 존재하는 파일에 대해 dbFiles라는 리스트요소에 주소값을 String으로 추가함.
        dbFiles.add(file.path.split('/').last);
      }
    }

    setState(() { // 이후 dbFiles라는 변수에 업데이트함.
      _databaseFiles = dbFiles;
    });
  }

  Future<void> _printDatabaseContent(String dbName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, dbName);
    /* path 설명
    join 메소드는 directory.path/dbname을 반환한다. 
    위의 경우에는 플랫폼에서 어플리케이션의 주소값을 반환한다.
    따라서 위 코드는 dbname파일의 directory를 Path라는 변수로 반환하게 된다.
     */
    final db = await openDatabase(path);
     /* dbName데이터베이스 파일을 불러와 db라는 변수 이름으로 명명함 */
    final List<Map<String, dynamic>> maps = await db.query('quiz_result');
     /*sqlite에서 정의된 method인 query메소드 사용: Future<List<Map<key,value> >를 대상으로 실행됨.
      query에는 argument로 데이터베이스의 TabeleName을 argument로 받는다. 이 경우 SQLiteQuizModel.dart에서 데이터베이스를 생성하기를
      PDF이름으로 db파일을 생성하고, 해당 db의 데이터테이블은 'quiz_result'으로 설정했으니 'quiz_result'의 데이터를 읽어오려면 쿼리문의 argumenr로 'quiz_result'를 설정해야한다.
      db파일을 List-Map형식으로 불러오는 메소드.

      maps에서 특정 인덱스의 데이터를 읽는 방식:
      int currentid = maps[CurrentIndex]['id']; String currentQuestion = map[CurrentIndex]['question'] 
      */

    if (maps.isEmpty) {
      print("No questions found in the database.");
    } else {
      for (var map in maps) {
        print("ID: ${map['id']}, Question: ${map['question']}, Options: ${map['options']}, Correct Answer: ${map['correct_answer']}, User Answer: ${map['user_answer']}, Correct Count: ${map['correct_count']}, Quiz Count: ${map['quiz_count']}");
      }
    }
  }

  Future<void> _deleteDatabaseFile(String dbName) async {
    /* _deleteDatabaseFile(_databaseFiles[index]), 즉 .db로 끝나는 파일이름을 인자로 받아 삭제하는 메소드. */
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, dbName);
    
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      print('$dbName deleted successfully.');

      // 데이터베이스 파일 목록 갱신
      _loadDatabaseFiles();
    } else {
      print('$dbName does not exist.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF5E8E5E),
      body: ListView(  //  ListView 사용해 수직 scroll
        children: [
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/fromDB_Quiz.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start, // Column 전체를 왼쪽 정렬
              children: [
                SizedBox(height: 40),
                Text(
                 '  Recent Quiz',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lemon(
                    fontSize: 18,
                    color: Color(0xFF5E8E5E),
                  ),
                ),

              Container( // ListView.builder를 감싸는 Container 추가
                  height: 200, // 높이 설정
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _databaseFiles.length,//10,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomCardWidget(
                          DB_PDF_NAME: _databaseFiles[index],
                          onTap: () {
                            print('Card $index tapped!');
                          },
                        ),
                      );
                    },
                  ),
              ),

              ],
            ),
          ),
          SizedBox(height: 40),
          Container(
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
                _databaseFiles.isEmpty
                    ? Text('No database files found.')
                    : Expanded( // ListView.builder를 Expanded로 감싸서 Container의 남은 공간을 차지하도록 함
                        child: ListView.builder(
                          itemCount: _databaseFiles.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(_databaseFiles[index]),
                              onTap: () {
                                _printDatabaseContent(_databaseFiles[index]);
                              },
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




class CustomCardWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String? DB_PDF_NAME;

  CustomCardWidget({this.onTap, required this.DB_PDF_NAME});

  @override
  Widget build(BuildContext context) {
    String PDFNAMEOnly =  DB_PDF_NAME?.replaceAll('.pdf.db', '') ?? '';
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 240,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.transparent, // 배경색을 투명색으로 지
        ),
        child: Row(
          children: [
          SizedBox(width: 10),
            Image.asset(
              'images/Card_from_database.png',
              width: 100, // 이미지의 크기를 적절하게 조정
              height: 190,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // 텍스트를 수직으로 가운데 정렬
                crossAxisAlignment: CrossAxisAlignment.start, // 텍스트를 왼쪽 정렬
                children: [
                  Text(
                    '${PDFNAMEOnly}',//'PDFName에서 .pdf.db를 제거한 문자열 가지고옴.',
                    style:  TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF629C3B),
                    ),
                  ),
                  
                  Text( 'category here', style:  TextStyle(fontSize: 12, color: Color(0xFF686868),),),

                  Spacer(),

                  Align(
                    alignment: Alignment.bottomLeft, // Directly align to bottom left
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10, left: 10), // Add padding for positioning
                      child: InkWell(
                        onTap: () {
                          print('삭제'); // _deleteDatabaseFile(_databaseFiles[index]);
                        },
                        child: Row(
                          children: [
                            Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF686868),
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.delete,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

