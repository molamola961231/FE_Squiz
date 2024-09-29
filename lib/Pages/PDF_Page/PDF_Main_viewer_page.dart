// Syncfusion사용으로 인해 pdfx패키지 미사용으로 업데이트함. 추후 문제가 생길시 롤백 할 것.
// import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:pdfx/pdfx.dart';
// import 'PDF_StudyGPT.dart';

// import '/Pages/Quiz_Page/Make_Quiz_Card.dart';

// class PDFViewerPage extends StatefulWidget {
//   final String FileName;
//   final PlatformFile file;

//   const PDFViewerPage({Key? key, required this.file, required this.FileName}) : super(key: key);

//   @override
//   _PDFViewerPageState createState() => _PDFViewerPageState();
// }

// class _PDFViewerPageState extends State<PDFViewerPage> {
//   late PdfControllerPinch _pdfControllerPinch;
//   int totalPageCount = 0;
//   int currentPage = 1;

//   /* 현재는 PdfStudyChat페이지에서 입력하는 정보를 모두 여기에 setState통해 업데이트해서 저장해 두지만, 나중에는 다른 방식이 필요할듯? */
//   late TextEditingController _tempChatlog;
//   late PdfStudyGPT _PdfStudyGPT;

//   @override
//   void initState() {
//     super.initState();
//     _pdfControllerPinch = PdfControllerPinch(
//       document: PdfDocument.openFile(widget.file.path!),
//     );
//     /*temp 채팅페이지관련 코드*/
//     _tempChatlog = TextEditingController();
//     _PdfStudyGPT = PdfStudyGPT(textEditingController: _tempChatlog,);

//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFF5E8E5E),
//         title:
//         Text(widget.FileName,style: TextStyle(color: Color(0xFFFAEA59)),),//("Study page"),

//          actions: [
//           IconButton(// gpt로딩 페이지
//             icon: Icon(Icons.message),
//             onPressed: () {
//               // 메세지 아이콘 클릭 시 PdfStudyChat 페이지 보여주기
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => _PdfStudyGPT,
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: GestureDetector(
//         /* 여기에 swipe 하면 채팅앱으로 넘어가게끔. 물론 appbar에도 추가하게끔?몰?루 */
//         onHorizontalDragEnd: (details) {
//           if (details.primaryVelocity! > 0) {
//             // Swipe right
//           } else {
//             // Swipe left 하면 채팅방으로 이동하는 코드... 현재 zoom issue.
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => _PdfStudyGPT,
//               ),
//             );
//           }
//         },
//         child: Column(
//           children: [
//             Row(
//               mainAxisSize: MainAxisSize.max,
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text('Total Pages: $totalPageCount'),
//                 SizedBox(width: 10),
//                 Text('Current Page: $currentPage'),
//               ],
//             ),
//             Expanded(
//               child: PdfViewPinch(
//                 scrollDirection: Axis.vertical,
//                 controller: _pdfControllerPinch,
//                 onDocumentLoaded: (PdfDocument document) {
//                   setState(() {
//                     totalPageCount = document.pagesCount;
//                   });
//                 },
//                 onPageChanged: (int page) {
//                   setState(() {
//                     currentPage = page;
//                   });
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),

//       floatingActionButton: floatingButtons(context, widget.FileName),
//       // FloatingActionButton(
//       //   backgroundColor: Color(0xFFE2F0D9), // 버튼 색상 설정
//       //   onPressed: () {
//       //     // 버튼이 클릭될 때 실행될 동작 추가
//       //   },
//       //   child: Icon(Icons.add), // 버튼에 표시될 아이콘
//       // ),

//     );
//   }
// }

// Widget? floatingButtons(BuildContext context, String fileName) {

//     return SpeedDial(
//       animatedIcon: AnimatedIcons.menu_close,
//       visible: true,
//       curve: Curves.bounceIn,
//       backgroundColor: Color(0xFF5E8E5E),
//       buttonSize: Size(62,62),
//       children: [
//         SpeedDialChild(
//             shape:CircleBorder(),
//             child: Container(
//               width: 28, // 너비 설정
//               height: 28, // 높이 설정
//               child: Image.asset('images/FloatingButton_Icon_Quiz.png',fit: BoxFit.contain,),
//               ),
//             //const Icon(Icons.settings_sharp, color: Colors.white),
//             label: "Make Quiz",
//             labelStyle: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFFFFB800),
//                 fontSize: 13.0),
//             backgroundColor: Color(0xFF5E8E5E),
//             labelBackgroundColor: Color(0xFF5E8E5E),
//             onTap: () {
//               /*  1. 해당 pdf에서 txt추출한 것을 gpt로 전송해야 함.
//                   2. 이후 MakeQuizCard로 이동시켜야함. 현재는 이것만 구현해두었음.  */
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => MakeQuizCard(FileName: fileName),
//                 ),
//               );
//             }
//             ),
//         SpeedDialChild( /* 2학기때 추가할 기능입니다.
//                           버튼 클릭시 bottomsheet에서 해당pdf의 해당페이지에 해당하는 메모를 로컬에서 불러오는 기능입니다.
//                           과금시 계정에서 동기화 할 수 있도록 디자인합니다.
//                            */
//           shape:CircleBorder(),
//           child: Container(
//               width: 26, // 너비 설정
//               height: 26, // 높이 설정
//               child: Image.asset('images/FloatingButton_Icon_Open_Memo.png',fit: BoxFit.contain,),
//               ),
//             //const Icon(Icons.settings_sharp, color: Colors.white),
//             label: "Memo",
//             labelStyle: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFFFFB800),
//                 fontSize: 13.0),
//             backgroundColor: Color(0xFF5E8E5E),
//             labelBackgroundColor: Color(0xFF5E8E5E),
//             onTap: () {}
//             ),

//       ],
//     );
//   }

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io'; // 파일 키워드 사용

import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:get/get.dart';
import '/Model/StateManaging.dart';
import '/Pages/Chat_Page/Chat_Main_Page.dart';
import '/Pages/Memo_Page/Memo_Main_Page.dart';

class PDFViewerPage extends StatefulWidget {
  final String FileName;
  final PlatformFile file;

  const PDFViewerPage({Key? key, required this.file, required this.FileName})
      : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  late PdfViewerController _pdfController;
  int totalPageCount = 0;
  int currentPage = 1;
  bool isContextProvided = false;
  final ContextController contextController =
      Get.put(ContextController()); // 추출한 context 넘겨주기 위한 컨트롤러추가
  final QuizHandlingController summeryController =
      Get.put(QuizHandlingController()); // 요약한 context를 넘겨주기 위한 컨트롤러 추가

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5E8E5E),
        title: Text(
          widget.FileName,
          style: TextStyle(color: Color(0xFFFAEA59)),
        ),
        actions: [
          Visibility(
            visible: isContextProvided,
            child: IconButton(
              icon: Icon(Icons.message, color: Color(0xFFFFB800)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Chat_Main_Page(
                        FileName: widget.FileName,
                        contextText_for_GPT:
                            contextController.recentPDFContextForGPT.value),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (isContextProvided) {
            if (details.primaryVelocity! > 0) {
              // Swipe right
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Chat_Main_Page(
                      FileName: widget.FileName,
                      contextText_for_GPT:
                          contextController.recentPDFContextForGPT.value),
                ),
              );
            }
          }
        },
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Total Pages: $totalPageCount'),
                SizedBox(width: 10),
                Text('Current Page: $currentPage'),
              ],
            ),
            Expanded(
              child: SfPdfViewer.file(
                File(widget.file.path!),
                controller: _pdfController,
                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  setState(() {
                    totalPageCount = details.document.pages.count;
                  });
                },
                onPageChanged: (PdfPageChangedDetails details) {
                  setState(() {
                    currentPage = details.newPageNumber;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          floatingButtons(context, widget.FileName, isContextProvided),
    );
  }

  Widget? floatingButtons(
      BuildContext context, String fileName, bool isContextProvided) {
    String withoutExtension = fileName.replaceAll('.pdf', '');
    String transformedFileName = 'MEMO_' + withoutExtension;
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      backgroundColor: Color(0xFF5E8E5E),
      buttonSize: Size(62, 62),
      children: [
        SpeedDialChild(
          shape: CircleBorder(),
          child: Container(
            width: 26,
            height: 26,
            child: Image.asset(
              'images/Icon_squiz_context.png',
              fit: BoxFit.contain,
            ),
          ),
          label: isContextProvided ? "Get next Context !" : "Squeeze the PDF !",
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFFFFB800),
              fontSize: 13.0),
          backgroundColor: Color(0xFF5E8E5E),
          labelBackgroundColor: Color(0xFF5E8E5E),
          onTap: () {
            showPageInputDialog(context, _pdfController, widget.file);
          },
        ),
        SpeedDialChild(
          // 메모기능 추가코드... visibile옵션으로 컨트롤.
          visible: true,
          shape: CircleBorder(),
          child: Container(
            width: 26,
            height: 26,
            child: Image.asset(
              'images/FloatingButton_Icon_Open_Memo.png',
              fit: BoxFit.contain,
            ),
          ),
          label: "  Memo  ",
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFFFFB800),
              fontSize: 13.0),
          backgroundColor: Color(0xFF5E8E5E),
          labelBackgroundColor: Color(0xFF5E8E5E),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MemoMainPage(dbName: transformedFileName),
                ));
          },
        ),
        SpeedDialChild(
          visible: isContextProvided,
          shape: CircleBorder(),
          child: Container(
            width: 26,
            height: 26,
            child: Image.asset(
              'images/FloatingButton_Icon_Open_Chat.png',
              fit: BoxFit.contain,
            ),
            /* 아래는 아이콘 */
            // Icon(
            //   Icons.message,
            //   color: Color(0xFFFFB800),
            // ),
          ),
          label: "AI tutor",
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFFFFB800),
              fontSize: 13.0),
          backgroundColor: Color(0xFF5E8E5E),
          labelBackgroundColor: Color(0xFF5E8E5E),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Chat_Main_Page(
                    FileName: widget.FileName,
                    contextText_for_GPT:
                        contextController.recentPDFContextForGPT.value),
              ),
            );
          },
        )
      ],
    );
  }

  void showPageInputDialog(BuildContext context,
      PdfViewerController pdfController, PlatformFile file) {
    final TextEditingController fromPageController = TextEditingController();
    final TextEditingController toPageController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Enter Page Range"),
          content: Column(
            children: [
              SizedBox(height: 20, width: 200),
              Row(
                children: [
                  Text('From : '),
                  Spacer(),
                  Container(
                    width: 100,
                    child: CupertinoTextField(
                      controller: fromPageController,
                      keyboardType: TextInputType.number,
                      placeholder: "Page Number",
                      textAlign: TextAlign.center,
                      decoration: BoxDecoration(color: Colors.transparent),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('To : '),
                  Spacer(),
                  Container(
                    width: 100,
                    child: CupertinoTextField(
                      controller: toPageController,
                      keyboardType: TextInputType.number,
                      placeholder: "Page Number",
                      textAlign: TextAlign.center,
                      decoration: BoxDecoration(color: Colors.transparent),
                    ),
                  )
                ],
              )
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                "CANCEL",
                style: TextStyle(color: Color(0xFF424242)),
              ),
              onPressed: () {
                contextController
                    .clearContext(); // Cancel일경우 새 context받아야 하기에...ecentPDFContextForGPT초기화
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text("OK", style: TextStyle(color: Colors.black)),
              onPressed: () async {
                int fromPage = int.parse(fromPageController.text);
                int toPage = int.parse(toPageController.text);
                if (/* 페이지 입력값이 정상일 경우 */ //||\\======> 페이지 구분하는거.
                    fromPage > 0 &&
                        toPage > 0 &&
                        fromPage <= pdfController.pageCount &&
                        toPage <= pdfController.pageCount &&
                        fromPage <= toPage) {
                  pdfController.jumpToPage(fromPage);
                  String contextText =
                      ''; // Initialize context to store extracted text
                  for (int i = fromPage; i <= toPage; i++) {
                    contextText += await extractTextFromPage(file.path!, i);
                  }
                  print('Extracted text from pages $fromPage to $toPage:');
                  print(contextText);
                  contextController
                      .updateContext(contextText); // Update context
                  print('Context aquired');
                  setState(() {
                    isContextProvided = true;
                  });
                } else {
                  contextController
                      .clearContext(); // 입력값이 잘못되도 recentPDFContextForGPT초기화
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Invalid page number. Please try again.')),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> extractTextFromPage(String filePath, int pageNumber) async {
    final QuizHandlingController summeryController =
        Get.put(QuizHandlingController()); // 요약한 context를 넘겨주기 위한 컨트롤러 추가

    // Load the PDF document
    PdfDocument document =
        PdfDocument(inputBytes: File(filePath).readAsBytesSync());

    // Get the specific page
    PdfPage page = document.pages[pageNumber - 1];

    // Extract text from the page
    String extractedText = PdfTextExtractor(document).extractText(
        startPageIndex: pageNumber - 1, endPageIndex: pageNumber - 1);
    extractedText += '  [Page $pageNumber end]  '; // 페이지 구분
    // Dispose the document
    document.dispose();
    String cleanedText = extractedText
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s(?=\s)'), '');
    summeryController.clearSummarizedContext; // 이전 summery 제거
    return cleanedText;
  }
}
