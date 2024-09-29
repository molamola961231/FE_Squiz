import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // flutter pub add google_fonts
import 'package:file_picker/file_picker.dart';
import 'PDF_Main_viewer_page.dart';
import 'package:get/get.dart';
import '/Model/StateManaging.dart';

/*file picker를 사용해 내부 저장소에 접근하는 페이지입니다.*/
class StorageAccessPage extends StatefulWidget {
  @override
  _StorageAccessPageState createState() => _StorageAccessPageState();
}

class _StorageAccessPageState extends State<StorageAccessPage> {
  List<String> pdfPaths = [];

  // @override
  // void initState() {
  //   super.initState();
  //   _findPdfFiles();
  // }

  /*실질적으로 file picker패키지의 UI를 불러오는 함수.*/
  Future<void> _findPdfFiles() async {
    try {
      /* - file picker패키지에서 file선택하는 경우의 코드.
             - extension필터를 적용했으며, 선택한 파일은 result에 저장합니다.
             - pickFiles이라는 메소드에 대한 설명은 패키지의 filepicker.dart파일에 정의되어있습니다.
           */
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      /* - 선택파일이 존재한다면 실행할 코드(on tap으로 선택처리)
             - path(str), name, size가 존재하는 Platform형식의 file이라는 변수로 저장합니다.
             - Platform형식의 list인 files에서 첫번째 요소(구현상 첫번째 요소밖에 없지만)를 file이라는 이름의 변수로 동기화시킵니다.
             - 이후, PDF뷰어페이지로 넘어갑니다.
           */
      if (result != null) {
        PlatformFile file = result.files.first;
        print('Selected file: ${file.path}');
        print('${file.name}');

        Navigator.push(
          /* PDFViewerPage로 넘감 */
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerPage(
              file: file,
              FileName: file.name,
            ),
          ),
        );
      } else {
        /* 클릭 취소시 */
        print('File selection cancelled');
      }
    } catch (e) {
      print('Error picking PDF file: $e');
    }
  }

  final ContextController contextController =
      Get.put(ContextController()); // 전역변수인 recentPDFContextForGPT를 컨트롤하는 컨트롤러ContextController추가.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Storage Access Example'),
      // ),
      body: Container(
        color: Color(0xFF92BE87),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  contextController.clearContext(); // 파일 선택 이전 전역변수 recentPDFContextForGPT초기화
                  _findPdfFiles();
                },
                child: Image.asset('images/File_Browser_link_Image.png'),
              ),
              SizedBox(height: 20),
              Text(
                'Welcome to S’quiz!\nClick lemon\nTo squeeze your PDF',
                textAlign: TextAlign.center,
                style: GoogleFonts.lemon(
                  fontSize: 24,
                  color: Color(0xFFFDE599),
                ),
              ),
              SizedBox(height: 20),
              if (pdfPaths.isNotEmpty) ...[
                Text('Found ${pdfPaths.length} PDF Files:'),
                Expanded(
                  child: ListView.builder(
                    itemCount: pdfPaths.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(pdfPaths[index]),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
