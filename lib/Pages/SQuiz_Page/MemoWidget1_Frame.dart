import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'CardViewQuiz.dart'; 

class MemoWidget1 extends StatelessWidget {
  final List<String> databaseFiles; // db파일 이름
  final Function(String) onDelete; // arg로 받을삭제 fn
  final Function() onTap; // arg로 받을 onTap함수

  const MemoWidget1({
    Key? key,
    required this.databaseFiles,
    required this.onDelete,
    //    required this.getDataFromDatabase,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/fromDB_Quiz.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            '  Recent Quiz \n',
            textAlign: TextAlign.center,
            style: GoogleFonts.lemon(
              fontSize: 18, color: Color(0xFF5E8E5E),
            ),
          ),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: databaseFiles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomCardWidget(
                    DB_PDF_NAME: databaseFiles[index],
                    dbFullPath: databaseFiles[index],
                    onDelete: (dbPath) => onDelete(dbPath),
                    onTap: () => onTap(),// Argument로 전달된 동작 실행
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
