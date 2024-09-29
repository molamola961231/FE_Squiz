import 'package:flutter/material.dart';

class PdfStudyGPT extends StatefulWidget {
  /* 따로 파일 분리해도 되는페이지.추후 채팅앱 페이지로 내용 교체하면 된다.
  https://pub.dev/packages/read_pdf_text 패키지 이용해서,current page의 text를 추출해  string으로 return하는 클래스인 
  summerizeThis클래스를 만들어두고 리턴값인 string을 prompt입력 내용으로 삽입하는 명령어를 나타내는 "${current페이지} 요약해줘". 
  같은 hint메세지 넣는것도 사용자경험을 개선할 수 있는 방법이다.
    구현 고려사항: 1) 해당 클래스는 로컬데이터베이스에 자동으로 대화를 갱신(저장), 로드해야 한다.
                이는 전송을 누르면 onpressed()안에 setState로 새 입력내용 대화박스에 출력해주고, db에 저장하면 된다.
                
                  2) 해당 pdf를 이미 업로드했었는지 확인하는건 해당 클래스가 아닌 외부 조건식으로 해결한다.
                
                  3) 위사항이 구현되면 homepage에서 굳이 late키워드 없이 불러와도 된다.
   */
  final TextEditingController textEditingController;
  
  PdfStudyGPT({
    required this.textEditingController,
  });

  @override
  _PdfStudyGPTState createState() => _PdfStudyGPTState();
}

class _PdfStudyGPTState extends State<PdfStudyGPT> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pdf Study Chat'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: widget.textEditingController,
              decoration: InputDecoration(
                hintText: 'Enter your message',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
              
                print('하 시발');
                // getPdfText('assets/sample.pdf');
                /*pop되도 late PdfStudyChat형태로 appbar에서 선언되서 삭제 안됨. */
              },
              child: Text('Go back to PDF Viewer'),
            ),
          ],
        ),
      ),
    );
  }
}