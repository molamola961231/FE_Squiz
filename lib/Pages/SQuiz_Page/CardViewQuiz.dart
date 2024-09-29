import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '/Pages/Quiz_Page/DB_SetQuizNumPage.dart';
import 'dart:convert';

class CustomCardWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final String? DB_PDF_NAME;
  final String? dbFullPath;
  final Future<void> Function(String dbName)? onDelete;

  CustomCardWidget({
    this.onTap,
    required this.DB_PDF_NAME,
    this.dbFullPath,
    this.onDelete,
  });

  @override
  _CustomCardWidgetState createState() => _CustomCardWidgetState();
}

class _CustomCardWidgetState extends State<CustomCardWidget> {
  List<Map<String, dynamic>> dataTable = []; // 나중에 이거 전달해주면 되쥬?

  @override
  void initState() {
    super.initState();
    _fetchDataFromDatabase();
  }


  Future<void> _fetchDataFromDatabase() async {
  if (widget.DB_PDF_NAME != null) {
    String dbName = widget.DB_PDF_NAME!;
    Database db = await _openDatabase(dbName);
    List<Map<String, dynamic>> rawData = await db.query('quiz_result');
    List<Map<String, dynamic>> data = rawData.map((data) {
      var decodedOptions = jsonDecode(data['options']) as List<dynamic>;
      return {
        ...data,
        'options': decodedOptions.map((option) => option.toString()).toList(),
      };
    }).toList();
    setState(() {
      dataTable = data;
    });
  }
}

  Future<Database> _openDatabase(String dbName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
                  CREATE TABLE quiz_result (
                    id INTEGER PRIMARY KEY,
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
  }

  @override
  Widget build(BuildContext context) {
    String PDFNAMEOnly = widget.DB_PDF_NAME?.replaceAll('.pdf.db', '') ?? '';
    //이거 쓸까...? String DBNAMEONLY = widget.DB_PDF_NAME?.replaceAll('.db', '') ?? '';
    return InkWell(
      onTap: () {
        print('데이터테이블 로딩 성공확인: \n');
        print('\n\n ${dataTable.length}개의 데이터 확인! \n\n');

        printDataTable();
        if (widget.onTap != null) {
          widget.onTap!();
        }
        /*퀴즈 갯수 정하는 페이지로 이동데스네*/
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MakeQuizFromDB(
                    DB_PDF_NAME: widget.DB_PDF_NAME!,
                    dataTable: dataTable,
                ),
            ),
        );

      },
      child: Container(
        width: 240,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            SizedBox(width: 10),
            Image.asset(
              'images/Card_from_database.png',
              width: 100,
              height: 190,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PDFNAMEOnly,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF629C3B),
                    ),
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10, left: 10),
                      child: InkWell(
                        onTap: () async {
                          if (await showDeleteConfirmDialog(context)) {
                            if (widget.dbFullPath != null) {
                              await widget.onDelete!(widget.dbFullPath!);
                            }
                          }
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
                              color: Color(0xFF686868),
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

  //db내용을 dataTable에 저장함. 이를 확인하기위해 출력하는 함수.
  void printDataTable() {
    dataTable.forEach((row) {
      print(row);
    });
  }

  Future<bool> showDeleteConfirmDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Delete'),
              content: Text('Are you sure you want to delete this database?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Yes'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                TextButton(
                  child: Text('No'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
