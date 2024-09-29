// import 'package:flutter/material.dart';
// import 'dart:convert'; // String타입으로 불러온 json을 Map으로 pharsing
// import 'package:flutter/services.dart'; // decode: rootBundle.loadString 사용
// import '/Model/QuestionModel.dart'; //
// import '/Model/SQLiteQuizModel.dart'; // db저장을 위해.
// import 'dart:io'; //file키워드 사용
// import 'OptionalCardQuiz.dart';
// import 'EssayCardsQuiz.dart';
// import '/Pages/Chat_Page/Chat_main_Page.dart'; // OpenAI api key val등.

// class MakeQuizCard extends StatefulWidget {
//   final String FileName;
//   String ExtractedContextforGPT; // 추후 이걸 GPT한테 Context로 줘야한다.
//   MakeQuizCard({Key? key, required this.FileName, required this.ExtractedContextforGPT}) : super(key: key);

//   @override
//   _MakeQuizCardState createState() => _MakeQuizCardState();
// }

// class _MakeQuizCardState extends State<MakeQuizCard> {
//   bool? isMultipleChoiceSelected;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xffB77D44),
//       appBar: AppBar(
//         backgroundColor: Color(0xFF5E8E5E),
//         title: Text("Generate Quiz"),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           // 입력때문에 자식 위젯이 화면에 표시될 때 화면의 크기를 벗어나게 된다.
//           child: Container(
//             // 카드 서식
//             height: 600,
//             width: 320,
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("images/Card_Background.png"),
//                 fit: BoxFit.cover,
//               ),
//               color: Colors.white,
//               border: Border.all(width: 4, color: Colors.green),
//               borderRadius: BorderRadius.circular(20),
//             ),

//             child: Column(
//               /* Container의 child인 contents: 퀴즈타입 + 2가지 네비게이션 버튼 */
//               // 여기에 QuizType설정
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(height: 10),
//                 Text(
//                   // 퀴즈타입 텍스트
//                   ' Quiz type ',
//                   style: TextStyle(
//                     fontSize: 20,
//                     color: Colors.black, // 텍스트 색상을 검은색으로 지정
//                   ),
//                 ),
//                 SizedBox(height: 60),
//                 ElevatedButton(
//                   /* 선다형: 눌리면 MultipleChoiceSelected를 업데이트하고 새로 반영사항 렌더링. 이후(context)부여해 _navigateToQuizNumberScreen 실행 */
//                   onPressed: () {
//                     setState(() {
//                       isMultipleChoiceSelected = true;
//                     });
//                     _navigateToQuizNumberScreen(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF6BA16A), // 버튼 배경색 변경
//                   ),
//                   child: Text(
//                     'Multiple Choice',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),

//                 SizedBox(height: 80), // 버튼간 간격

//                 ElevatedButton(
//                   /* 주관식: 눌리면 MultipleChoiceSelected를 업데이트하고 새로 반영사항 렌더링. 이후(context)부여해 _navigateToQuizNumberScreen 실행 */
//                   onPressed: () {
//                     setState(() {
//                       isMultipleChoiceSelected = false;
//                     });
//                     _navigateToQuizNumberScreen(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF6BA16A), // 버튼 배경색 변경
//                   ),
//                   child: Text(
//                     'Essay',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _navigateToQuizNumberScreen(BuildContext context) {
//     /* 해당 함수는 부여받은 context로 새 화면을 만들어 얹습니다. */
//     Navigator.push(
//       /* Navigator에 push로 MaterialPageRoute() 안에서 context를 이용해 이동할 새 페이지를 생성합니다. */
//       context,
//       MaterialPageRoute(
//         builder: (context) => QuizNumberScreen(
//           isMultipleChoiceSelected: isMultipleChoiceSelected!,
//           fileName: widget.FileName, // 파일명 전달
//         ),
//       ),
//     );
//   }
// }

// class QuizNumberScreen extends StatefulWidget {
//   final bool isMultipleChoiceSelected;
//   final String fileName;

//   const QuizNumberScreen(
//       {Key? key,
//       required this.isMultipleChoiceSelected,
//       required this.fileName})
//       : super(key: key);

//   @override
//   _QuizNumberScreenState createState() => _QuizNumberScreenState();
// }

// class _QuizNumberScreenState extends State<QuizNumberScreen> {
//   /* 퀴즈 갯수를 정한 다음 이를 통해 새 화면으로 전환합니다 */
//   /* 퀴즈의 갯수를 정하면 로컬파일에서 json파일을 파싱해 불러와 선다형에 뿌려주는 함수_loadQuestions를 정의해야 합니다.  */
//   int numberOfQuizzes = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xffB77D44),
//       appBar: AppBar(
//         // 선택에 따라 객관식 /주관식으로 나뉨.
//         backgroundColor: Color(0xFF6BA16A),
//         title: Text(widget.isMultipleChoiceSelected
//             ? 'Quiz type: Multiple Choice'
//             : 'Quiz type: Essay'),
//         //해당 Scaffold는 Navigator.push()와 MaterialPageRoute()를 통해 생성되었기에 뒤로가기로 이전화면으로 갈 수 있습니다(Stack에서 pop됩니다)
//       ),
//       body: GestureDetector(
//         onTap: () {
//           // 키보드가 열려 있을 때 외부 영역 탭하면 포커스를 해제하고 키보드를 숨깁니다.
//           FocusScope.of(context).requestFocus(FocusNode());
//         },
//         child: Center(
//           child: SingleChildScrollView(
//             // 입력때문에 자식 위젯이 화면에 표시될 때 화면의 크기를 벗어나게 된다.
//             child: Container(
//               //카드 서식
//               height: 600,
//               width: 320,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage("images/Card_Background.png"),
//                   fit: BoxFit.cover,
//                 ),
//                 color: Colors.white,
//                 border: Border.all(width: 4, color: Colors.green),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     // 입력창 서식.
//                     width: 270,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       // 입력창 장식
//                       color: Color(0xFFFFE299), // Box의 배경색
//                       borderRadius:
//                           BorderRadius.circular(10), // Box의 모서리를 둥글게 설정
//                     ),
//                     child: TextField(
//                       //입력창 영역. 숫자만 입력가능합니다.
//                       textAlign: TextAlign.center,
//                       keyboardType: TextInputType
//                           .number, //숫자만 입력하게 설정하며, 숫자가 아니라면 error처리됨.
//                       onChanged: (value) {
//                         //입력값이 변경될때마다 콜백되는 함수. 자연수인지를 검산합니다.
//                         setState(() {
//                           numberOfQuizzes = int.tryParse(value) ??
//                               0; // => 입력된 값이 정수로 변환될 수 있다면 해당 값을 numberOfQuizzes에 저장하고, 변환할 수 없는 경우 기본값으로 0을 사용
//                         });
//                       },
//                       decoration: InputDecoration(
//                         // 텍스트필드의 힌트가 되는 텍스트입니다.
//                         hintText: numberOfQuizzes > 0
//                             ? 'How many Quiz Questions?'
//                             : 'Please type Right numbers',
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 60),
//                   ElevatedButton(
//                     // 입력값을 제출하는 버튼입니다. 0보다 작다면 콜백함수의 내용으로 _navigateToQuizScreen(context)가 설정되고, 아니면 null로서 클릭이 불가능합니다.
//                     onPressed: numberOfQuizzes > 0 && numberOfQuizzes <= 10
//                         ? () {
//                             _navigateToQuizScreen(context, numberOfQuizzes);
//                           }
//                         : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF6BA16A),
//                     ),
//                     child: Text(
//                       'Start Quiz!',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _navigateToQuizScreen(BuildContext context, int numQuiz) async {
//     try {
//       // 만일 로컬에서 json 찾았다면 실행할 코드
//       if (widget.isMultipleChoiceSelected) {
//         // 만일 선다형이라면 MaterialPageRoute로 SelectiveCardsQuiz 페이지를 생성하며, 이때 numberOfQuizzes를 넘겨줍니다.
//         /* 비동기로(요청 발생시만 작동) json에서 데이터 가져옴.. */
//         String jsonString =
//             await rootBundle.loadString('lib/data/Questions.json');
//         /* ↑ json을 String으로 변형. 이후 다시 Map객체로 변환함. 쓸데없는 "questions" 떼내기 위해. */
//         Map<String, dynamic> jsonData = json.decode(jsonString);
//         /* ↑ json.decode 통해 String을 Map형식으로 재가공해 {"key", [{},{},...{},...{}] }로 쪼갠다.*/
//         List<dynamic> questionsData = jsonData['questions'];
//         /* ↑ value에 해당하는 [{},{},...{},...{}]를 분리해낸다. 쓸데없는 "questions" 가 떨어져나갔다.*/
//         List<QuestionModel> questions = [];
//         /* ↑ 리스트 요소{}들을 QuestionModel로 변형해 집어넣을 새 리스트 선언. */

//         questions = questionsData.map((questionData) {
//           /* map함수로 questionData라는 element에 대해   QuestionModel객체로 반환합니다. */
//           /* map함수 이용하기 tip:
//                 - Itrable.map((Target_element_of_Itatable)=> 실행내용 ) 혹은
//                 - Itrable.map((Target_element_of_Itatable) return func(Target_element_of_Itatable) )
//               */
//           return QuestionModel.fromJson(questionData);
//         }).toList();
//         print('Saving Questions to the database...');
//         /* db에 저장
//         await SQLiteQuestionModel.saveItToDatabase(questions, widget.fileName);
//         */
//         // 데이터베이스 파일이 존재하는지 확인
//         final dbFilePath = '${widget.fileName}.db';
//         final dbFile = File(dbFilePath);
//         final dbExists = await dbFile.exists();

//         if (dbExists) {
//           // 데이터베이스 파일이 이미 존재한다면 삭제
//           await dbFile.delete();
//           print('Deleted previous database file: $dbFilePath');
//         }

//         // 새로운 데이터베이스 생성 및 저장
//         await SQLiteQuestionModel.saveItToDatabase(questions, widget.fileName);
//         final dbCheck = File(dbFilePath);
//         final dbCheckExists = await dbCheck.exists();
//         print(
//             'Database file exists after saving: $dbCheckExists\n--Log from Make_Quiz_Card.dart--');

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             // MaterialPageRoute를 통해 새로운 경로를 생성합니다. 이 경로는 QuizScreen 위젯을 빌드합니다.
//             builder: (context) => OptionalCardQuiz(
//               // QuizScreen 생성자에 'loaded_questions'인자를 전달합니다.
//               loaded_questions: questions.take(numQuiz).toList(),
//               // 'loaded_questions'에 대해 'questions' 리스트에서 'numQuestions' 만큼의 요소만 리스트로 추출하여 전달합니다.
//               // OptionalCardQuiz에 db경로를 전달해줍니다.
//               dbPath: dbFilePath.replaceAll('.db', ''),
//             ),
//           ),
//         );
//       } else {
//         // 만일 선다형이 아니라면 MaterialPageRoute로 EssayCardsQuiz 페이지를 생성하며, 이때 numberOfQuizzes를 넘겨줍니다.
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => EssayCardsQuiz(
//               numberOfCards: numberOfQuizzes,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       _showErrorDialog(
//           context, 'An error occurred while loading questions: $e');
//     }
//   }

//   void _showErrorDialog(BuildContext context, String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Error'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert'; // String타입으로 불러온 json을 Map으로 pharsing
import 'package:flutter/services.dart'; // decode: rootBundle.loadString 사용
import '/Model/QuestionModel.dart'; //
import '/Model/SQLiteQuizModel.dart'; // db저장을 위해.
import 'dart:io'; //file키워드 사용
import 'OptionalCardQuiz.dart';
import 'EssayCardsQuiz.dart';
import 'package:http/http.dart' as http; // api통신(엔드포인트) 위해.
import '/Pages/Chat_Page/Const_for_chat.dart'; // OpenAI api key val등.
import 'package:get/get.dart';
import '/Model/StateManaging.dart'; // GPT 퀴즈 데이터 가공을 위해.

String apiKey = ConstForChat.OPEN_AI_KEY;
String OPEN_AI_ORGANIZATION = ConstForChat.OPEN_AI_ORGANIZATION_addr;
String API_URL = ConstForChat.GPT_API_URL;
final AccountController accountController = Get.put(AccountController());

class MakeQuizCard extends StatefulWidget {
  final String FileName;
  String ExtractedContextforGPT; // 추후 이걸 GPT한테 Context로 줘야한다.
  MakeQuizCard(
      {Key? key, required this.FileName, required this.ExtractedContextforGPT})
      : super(key: key);

  @override
  _MakeQuizCardState createState() => _MakeQuizCardState();
}

class _MakeQuizCardState extends State<MakeQuizCard> {
  bool? isMultipleChoiceSelected;
  List<QuestionModel> quizQuestions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffB77D44),
      appBar: AppBar(
        backgroundColor: Color(0xFF5E8E5E),
        title: Text("Generate Quiz"),
      ),
      body: Center(
        child: SingleChildScrollView(
          // 입력때문에 자식 위젯이 화면에 표시될 때 화면의 크기를 벗어나게 된다.
          child: Container(
            // 카드 서식
            height: 600,
            width: 320,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Card_Background.png"),
                fit: BoxFit.cover,
              ),
              color: Colors.white,
              border: Border.all(width: 4, color: Colors.green),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(
              /* Container의 child인 contents: 퀴즈타입 + 2가지 네비게이션 버튼 */
              // 여기에 QuizType설정
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Text(
                  // 퀴즈타입 텍스트
                  ' Quiz type ',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black, // 텍스트 색상을 검은색으로 지정
                  ),
                ),
                SizedBox(height: 60),
                ElevatedButton(
                  /* 선다형: 눌리면 MultipleChoiceSelected를 업데이트하고 새로 반영사항 렌더링. 이후(context)부여해 _navigateToQuizNumberScreen 실행 */
                  onPressed: () {
                    setState(() {
                      isMultipleChoiceSelected = true;
                    });
                    _navigateToQuizNumberScreen(
                        context, widget.ExtractedContextforGPT);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6BA16A), // 버튼 배경색 변경
                  ),
                  child: Text(
                    'Multiple Choice',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                SizedBox(height: 80), // 버튼간 간격
                /*  주관식은 일단 봉인  */
                // ElevatedButton(
                //   /* 주관식: 눌리면 MultipleChoiceSelected를 업데이트하고 새로 반영사항 렌더링. 이후(context)부여해 _navigateToQuizNumberScreen 실행 */
                //   onPressed: () {
                //     setState(() {
                //       isMultipleChoiceSelected = false;
                //     });
                //     _navigateToQuizNumberScreen(
                //         context, widget.ExtractedContextforGPT);
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Color(0xFF6BA16A), // 버튼 배경색 변경
                //   ),
                //   child: Text(
                //     'Essay',
                //     style: TextStyle(color: Colors.white),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToQuizNumberScreen(
      BuildContext context, String extractedContext) {
    /* 해당 함수는 부여받은 context로 새 화면을 만들어 얹습니다. */
    Navigator.push(
      /* Navigator에 push로 MaterialPageRoute() 안에서 context를 이용해 이동할 새 페이지를 생성합니다. */
      context,
      MaterialPageRoute(
        builder: (context) => QuizNumberScreen(
            isMultipleChoiceSelected: isMultipleChoiceSelected!,
            fileName: widget.FileName,
            extractedContext: widget.ExtractedContextforGPT // 파일명 전달
            ),
      ),
    );
  }
}

class QuizNumberScreen extends StatefulWidget {
  final bool isMultipleChoiceSelected;
  final String fileName;
  final String extractedContext;
  const QuizNumberScreen(
      {Key? key,
      required this.isMultipleChoiceSelected,
      required this.fileName,
      required this.extractedContext})
      : super(key: key);

  @override
  _QuizNumberScreenState createState() => _QuizNumberScreenState();
}

class _QuizNumberScreenState extends State<QuizNumberScreen> {
  /* 퀴즈 갯수를 정한 다음 이를 통해 새 화면으로 전환합니다 */
  /* 퀴즈의 갯수를 정하면 로컬파일에서 json파일을 파싱해 불러와 선다형에 뿌려주는 함수_loadQuestions를 정의해야 합니다.  */
  int numberOfQuizzes = 0;
  bool isError = false;
  bool notyetClicked = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffB77D44),
      appBar: AppBar(
        // 선택에 따라 객관식 /주관식으로 나뉨.
        backgroundColor: Color(0xFF6BA16A),
        title: Text(widget.isMultipleChoiceSelected
            ? 'Quiz type: Multiple Choice'
            : 'Quiz type: Essay'),
        //해당 Scaffold는 Navigator.push()와 MaterialPageRoute()를 통해 생성되었기에 뒤로가기로 이전화면으로 갈 수 있습니다(Stack에서 pop됩니다)
      ),
      body: GestureDetector(
        onTap: () {
          // 키보드가 열려 있을 때 외부 영역 탭하면 포커스를 해제하고 키보드를 숨깁니다.
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Center(
          child: SingleChildScrollView(
            // 입력때문에 자식 위젯이 화면에 표시될 때 화면의 크기를 벗어나게 된다.
            child: Container(
              //카드 서식
              height: 600,
              width: 320,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/Card_Background.png"),
                  fit: BoxFit.cover,
                ),
                color: Colors.white,
                border: Border.all(width: 4, color: Colors.green),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    // 입력창 서식.
                    width: 270,
                    height: 48,
                    decoration: BoxDecoration(
                      // 입력창 장식
                      color: Color(0xFFFFE299), // Box의 배경색
                      borderRadius:
                          BorderRadius.circular(10), // Box의 모서리를 둥글게 설정
                    ),
                    child: TextField(
                      //입력창 영역. 숫자만 입력가능합니다.
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType
                          .number, //숫자만 입력하게 설정하며, 숫자가 아니라면 error처리됨.
                      onChanged: (value) {
                        //입력값이 변경될때마다 콜백되는 함수. 자연수인지를 검산합니다.
                        setState(() {
                          numberOfQuizzes = int.tryParse(value) ??
                              0; // => 입력된 값이 정수로 변환될 수 있다면 해당 값을 numberOfQuizzes에 저장하고, 변환할 수 없는 경우 기본값으로 0을 사용
                        });
                      },
                      decoration: InputDecoration(
                        // 텍스트필드의 힌트가 되는 텍스트입니다.
                        hintText: numberOfQuizzes > 0
                            ? 'How many Quiz Questions?'
                            : 'Please type Right numbers',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  ElevatedButton(
                    // 입력값을 제출하는 버튼입니다. 0보다 작다면 콜백함수의 내용으로 _navigateToQuizScreen(context)가 설정되고, 아니면 null로서 클릭이 불가능합니다.
                    onPressed: notyetClicked &&
                            numberOfQuizzes > 0 &&
                            numberOfQuizzes <= 30
                        ? () {
                            setState(() {
                              notyetClicked = false;
                            });
                            _navigateToQuizScreen(context, numberOfQuizzes,
                                widget.extractedContext);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6BA16A),
                    ),
                    child: Text(
                      'Start Quiz!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // void _navigateToQuizScreen(
  //     BuildContext context, int numQuiz, String extractedContext) async {
  //   final QuizHandlingController GeneratedQuizHandler =
  //       Get.put(QuizHandlingController());
  //   try {
  //     if (widget.isMultipleChoiceSelected) {
  //       List<QuestionModel> questions = [];
  //       String jsonString;
  //       // 만일 선다형이라면 MaterialPageRoute로 SelectiveCardsQuiz 페이지를 생성하며, 이때 numberOfQuizzes를 넘겨줍니다.
  //       String prompt =
  //           'Generate a JSON array object named QuizesFromGPT containing $numQuiz quiz questions based on the given context: $extractedContext. Each element in the array should be an individual quiz question object. Each question object must have a unique questionNumber, a question field containing the question text, an options field containing an array of answer choices, and an answer field containing the correct answer. All options in the options field should be limited to a maximum of 2 words. → JSON array object Reference: {"QuizesFromGPT": [{\"questionNumber\":1, \"question\": \"What type of graph has all vertices connected to each other?\",\"options\": [\"Complete graph\", \"Dense graph\", \"Sparse graph\", \"Directed graph\"],\"answer\": \"Dense graph\"},{\"questionNumber\":2, \"question\": \"Which data structure uses sequential access for retrieving data?\",\"options\": [\"Arrays\", \"Linked lists\", \"Stacks\", \"Queues\"],\"answer\": \"Linked lists\"}]}';
  //       /* GPT 프롬프트를 GPT에게 전달합니다*/
  //       Map<String, dynamic> body = {
  //         "model": 'gpt-3.5-turbo-instruct', // 해당 모델은 추후 fine tune된 모델로 대체할 것.
  //         "prompt": prompt.replaceAll(r'\', ''),
  //         "max_tokens": 2000,
  //         "temperature": 0.7,
  //         "top_p": 1.0 // 응답의 질을 조정 (0.0 - 1.0)
  //       };

  //       String encodedBody;
  //       try {
  //         encodedBody = json.encode(body); /*json 형식으로 encode*/
  //         print('Request body successfully encoded: $encodedBody');
  //       } catch (e) {
  //         print('Failed to encode request body: $e');
  //         return;
  //       }
  //       print('Sending request to GPT for Generating Quiz...');
  //       try {
  //         /* GPT로 메시지 송신. */
  //         final response = await http.post(
  //           Uri.parse("https://api.openai.com/v1/completions"),
  //           /*gpt3.5 사용 시 endpoint 주소. 모델별로 해당 주소 상이함.*/
  //           headers: {
  //             'Authorization': 'Bearer $apiKey',
  //             "Content-Type": "application/json",
  //             'OpenAI-Organization': OPEN_AI_ORGANIZATION,
  //           },
  //           body: encodedBody,
  //         );

  //         print('Response status: ${response.statusCode}');
  //         print(
  //             'Response body: ${utf8.decode(response.bodyBytes)}'); // 응답을 UTF-8로 디코딩하여 출력하지 않으면 에러가 뜸
  //         if (response.statusCode == 200) {
  //           final responseBody = json
  //               .decode(utf8.decode(response.bodyBytes)); // 응답을 UTF-8로 디코딩하여 파싱
  //           final gptResponse = responseBody['choices'][0]['text'].trim();
  //           print('GPT Response: $gptResponse');
  //           print(
  //               responseBody['choices'][0]['finish_reason'].trim().toString() ==
  //                   'stop'); // true

  //           //gptResponse를 QuizRowData에 저장하고 나중에 이걸 정리하는 함수 만들자.
  //           GeneratedQuizHandler.updateQuizRowData(
  //               gptResponse); // 이제 GeneratedQuizHandler.QuizRowData.value에 GPT의 응답이 들어가있다.
  //           print('\n\nResponse Handle Finished\n\n');
  //           print('\n==\n');
  //           print(GeneratedQuizHandler.QuizRowData.value);
  //           print('\nStart Parsing JSON TO QUIZ\n');

  //           /* JSON객체를 이용해 퀴즈데이터를 만듭니다. */
  //           jsonString = GeneratedQuizHandler.QuizRowData.value;
  //           /* ↑ json을 String으로 변형. 이후 다시 Map객체로 변환함. 우선적으로 "QuizesFromGPT" 떼내기 위해. */
  //           print('\n\n==\nTrimmed json: $jsonString');
  //           print('\n.\n.\n.\n.');
  //           Map<String, dynamic> jsonData = json.decode(jsonString);
  //           /* ↑ json.decode 통해 String을 Map형식으로 재가공해 {"key", [{},{},...{},...{}] }로 쪼갠다.*/
  //           List<dynamic> questionsData = jsonData["QuizesFromGPT"];
  //           /* ↑ value에 해당하는 [{},{},...{},...{}]를 분리해낸다. 쓸데없는 "QuizesFromGPT" 가 떨어져나갔다.*/
  //           questions = questionsData.map((questionData) {
  //             /* map함수로 questionData라는 element에 대해   QuestionModel객체로 반환합니다. */
  //             /* map함수 이용하기 tip:
  //                   - Itrable.map((Target_element_of_Itatable)=> 실행내용 ) 혹은
  //                   - Itrable.map((Target_element_of_Itatable) return func(Target_element_of_Itatable) )
  //                 */
  //             return QuestionModel.fromJson(questionData);
  //           }).toList();
  //         }
  //       } catch (e) {
  //         /* 위 try-catch는 동기이므로 에러핸들링이 안됨. 비동기로 업데이트할것. */
  //         if (e != null) {
  //           showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return AlertDialog(
  //                 title: Text(
  //                     "overflow error: Token exceeded it's limit. please adjust range shorter."),
  //               );
  //             },
  //           );
  //           Navigator.pop(context);
  //         }
  //         print('Error occurred while interacting with GPT: $e');
  //       }

  //       print('Saving Questions to the database...');
  //       /* db에 저장
  //       await SQLiteQuestionModel.saveItToDatabase(questions, widget.fileName);
  //       */
  //       // 데이터베이스 파일이 존재하는지 확인
  //       final dbFilePath = '${widget.fileName}.db';
  //       final dbFile = File(dbFilePath);
  //       final dbExists = await dbFile.exists();

  //       if (dbExists) {
  //         // 데이터베이스 파일이 이미 존재한다면 삭제
  //         await dbFile.delete();
  //         print('Deleted previous database file: $dbFilePath');
  //       }

  //       // 새로운 데이터베이스 생성 및 저장
  //       await SQLiteQuestionModel.saveItToDatabase(questions, widget.fileName);
  //       final dbCheck = File(dbFilePath);
  //       final dbCheckExists = await dbCheck.exists();
  //       print(
  //           'Database file exists after saving: $dbCheckExists\n--Log from Make_Quiz_Card.dart--');

  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           // MaterialPageRoute를 통해 새로운 경로를 생성합니다. 이 경로는 QuizScreen 위젯을 빌드합니다.
  //           builder: (context) => OptionalCardQuiz(
  //             // QuizScreen 생성자에 'loaded_questions'인자를 전달합니다.
  //             loaded_questions: questions.take(numQuiz).toList(),
  //             // 'loaded_questions'에 대해 'questions' 리스트에서 'numQuestions' 만큼의 요소만 리스트로 추출하여 전달합니다.
  //             // OptionalCardQuiz에 db경로를 전달해줍니다.
  //             dbPath: dbFilePath.replaceAll('.db', ''),
  //           ),
  //         ),
  //       );
  //     } else {
  //       // 만일 선다형이 아니라면 MaterialPageRoute로 EssayCardsQuiz 페이지를 생성하며, 이때 numberOfQuizzes를 넘겨줍니다.
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => EssayCardsQuiz(
  //             numberOfCards: numberOfQuizzes,
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     _showErrorDialog(
  //         context, 'An error occurred while loading questions: $e');
  //   }
  // }

  Future<List<QuestionModel>> fetchQuizQuestions(
      String prompt, String apiKey, String openAiOrganization) async {
    List<QuestionModel> questions = [];
    String jsonString;

    Map<String, dynamic> body = {
      "model": 'gpt-3.5-turbo-instruct', // 해당 모델은 추후 fine tune된 모델로 대체할 것.
      "prompt": prompt.replaceAll(r'\', ''),
      "max_tokens": 2000,
      "temperature": 0.7,
      "top_p": 1.0 // 응답의 질을 조정 (0.0 - 1.0)
    };

    String encodedBody;
    try {
      encodedBody = json.encode(body); /*json 형식으로 encode*/
      print('Request body successfully encoded: $encodedBody');
    } catch (e) {
      print('Failed to encode request body: $e');
      return questions;
    }

    print('Sending request to GPT for Generating Quiz...');
    try {
      /* GPT로 메시지 송신. */
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/completions"),
        /*gpt3.5 사용 시 endpoint 주소. 모델별로 해당 주소 상이함.*/
        headers: {
          'Authorization': 'Bearer $apiKey',
          "Content-Type": "application/json",
          'OpenAI-Organization': openAiOrganization,
        },
        body: encodedBody,
      );

      print('Response status: ${response.statusCode}');
      print(
          'Response body: ${utf8.decode(response.bodyBytes)}'); // 응답을 UTF-8로 디코딩하여 출력하지 않으면 에러가 뜸
      if (response.statusCode == 200) {
        final responseBody =
            json.decode(utf8.decode(response.bodyBytes)); // 응답을 UTF-8로 디코딩하여 파싱
        final gptResponse = responseBody['choices'][0]['text'].trim();

        /* 09.04 업데이트: 토큰 트래킹 */
        final TokenUsage = responseBody['usage']['total_tokens'];
        accountController.Refresh_Used_APIToken;
        accountController.Update_Used_APIToken(TokenUsage);
        /*  09.04 업데이트: 토큰 트래킹 */
        print('\n.\n.TokenUsage:$TokenUsage\n.\n.');
        print('GPT Response: $gptResponse');
        print(responseBody['choices'][0]['finish_reason'].trim().toString() ==
            'stop'); // true

        jsonString = gptResponse;
        print('\n\n==\nTrimmed json: $jsonString');
        print('\n.\n.\n.\n.');
        Map<String, dynamic> jsonData = json.decode(jsonString);
        List<dynamic> questionsData = jsonData["QuizesFromGPT"];
        questions = questionsData.map((questionData) {
          return QuestionModel.fromJson(questionData);
        }).toList();
      }
    } catch (e) {
      print('Error occurred while interacting with GPT: $e');
      throw e;
    }

    return questions;
  }

  void _navigateToQuizScreen(
      BuildContext context, int numQuiz, String extractedContext) async {
    final QuizHandlingController GeneratedQuizHandler =
        Get.put(QuizHandlingController());
    try {
      if (widget.isMultipleChoiceSelected) {
        List<QuestionModel> questions = [];
        String prompt =
            'Generate a JSON array object named QuizesFromGPT containing $numQuiz quiz questions based on the given context: $extractedContext. Each element in the array should be an individual quiz question object. Each question object must have a unique questionNumber, a question field containing the question text, an options field containing an array of answer choices, and an answer field containing the correct answer. All options in the options field should be limited to a maximum of 2 words. → JSON array object Reference: {"QuizesFromGPT": [{\"questionNumber\":1, \"question\": \"What type of graph has all vertices connected to each other?\",\"options\": [\"Complete graph\", \"Dense graph\", \"Sparse graph\", \"Directed graph\"],\"answer\": \"Dense graph\"},{\"questionNumber\":2, \"question\": \"Which data structure uses sequential access for retrieving data?\",\"options\": [\"Arrays\", \"Linked lists\", \"Stacks\", \"Queues\"],\"answer\": \"Linked lists\"}]}';

        try {
          questions =
              await fetchQuizQuestions(prompt, apiKey, OPEN_AI_ORGANIZATION);
          if (questions.isEmpty) {
            throw Exception('Failed to generate questions.');
          }
        } catch (e) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text(
                    "overflow error:\nToken exceeded its limit. \nPlease adjust range shorter, or summarize it shorter."),
              );
            },
          );
          return;
        }

        print('Saving Questions to the database...');
        final dbFilePath = '${widget.fileName}.db';
        final dbFile = File(dbFilePath);
        final dbExists = await dbFile.exists();

        if (dbExists) {
          await dbFile.delete();
          print('Deleted previous database file: $dbFilePath');
        }

        await SQLiteQuestionModel.saveItToDatabase(questions, widget.fileName);
        final dbCheck = File(dbFilePath);
        final dbCheckExists = await dbCheck.exists();
        print(
            'Database file exists after saving: $dbCheckExists\n--Log from Make_Quiz_Card.dart--');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OptionalCardQuiz(
              loaded_questions: questions.take(numQuiz).toList(),
              dbPath: dbFilePath.replaceAll('.db', ''),
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EssayCardsQuiz(
              numberOfCards: numberOfQuizzes,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog(
          context, 'An error occurred while loading questions: $e');
    }
  }

  String StringToJsonForQuiz(String S) {
    // QuizesFromGPT 가 들어있는 부분부터 json으로 여깁니다.firstMatch를 이용,문자열에서 패턴의 첫 번째 발생을 찾습니다.
    final pattern = RegExp(r'{"QuizesFromGPT": \[.*?\]}');
    final match = pattern.firstMatch(S);

    if (match != null) {
      // Extract the matched portion
      String extractedJson = match.group(0)!;

      // 추출된 JSON 문자열을 파싱하여 jsonDecode유효한 JSON 객체인지 확인
      var jsonObject = jsonDecode(extractedJson);

      // JSON으로 다시 인코딩 : 유효한 JSON 객체는 .을 사용하여 JSON 문자열로 다시 변환 후 올바르게 포맷된 JSON 문자열을 반환
      return jsonEncode(jsonObject);
    }

    // Return an empty JSON object if no match is found
    return '{}';
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
