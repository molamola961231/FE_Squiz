// import 'package:flutter/material.dart';
// // import 'package:buttom_navigation/testing_widgets/EssayCardsQuiz.dart';
// // import 'package:buttom_navigation/testing_widgets/SelectiveCardsQuiz.dart';
// import '/testing_widgets/EssayCardsQuiz.dart';
// import '/testing_widgets/SelectiveCardsQuiz.dart';


// class MakeQuizCard extends StatefulWidget {
//   const MakeQuizCard({Key? key}) : super(key: key);

//   @override
//   _MakeQuizCardState createState() => _MakeQuizCardState();
// }

// class _MakeQuizCardState extends State<MakeQuizCard> {
//   bool? isMultipleChoiceSelected;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xffB77D44),
//       body: Center(
//         child: SingleChildScrollView( // 입력때문에 자식 위젯이 화면에 표시될 때 화면의 크기를 벗어나게 된다.
//           child: Container( // 카드 서식
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

//             child: Column( /* Container의 child인 contents: 퀴즈타입 + 2가지 네비게이션 버튼 */
//               // 여기에 QuizType설정
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(height: 10),
//                 Text(// 퀴즈타입 텍스트
//                   ' Quiz type ',
//                   style: TextStyle(
//                     fontSize: 20,
//                     color: Colors.black, // 텍스트 색상을 검은색으로 지정
//                   ),
//                 ),
//                 SizedBox(height: 60),
//                 ElevatedButton( /* 선다형: 눌리면 MultipleChoiceSelected를 업데이트하고 새로 반영사항 렌더링. 이후(context)부여해 _navigateToQuizNumberScreen 실행 */
//                   onPressed: () {
//                     setState(() {
//                       isMultipleChoiceSelected = true; 
//                     });
//                     _navigateToQuizNumberScreen(context);
//                   },
//                     style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF6BA16A), // 버튼 배경색 변경
//                   ),
//                   child: Text('Multiple Choice', style: TextStyle(color: Colors.white),),
//                 ),
                
//                 SizedBox(height: 80), // 버튼간 간격
                
//                 ElevatedButton( /* 주관식: 눌리면 MultipleChoiceSelected를 업데이트하고 새로 반영사항 렌더링. 이후(context)부여해 _navigateToQuizNumberScreen 실행 */
//                   onPressed: () {
//                     setState(() {
//                       isMultipleChoiceSelected = false;
//                     });
//                     _navigateToQuizNumberScreen(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF6BA16A), // 버튼 배경색 변경
//                   ),
//                   child: Text('Essay', style: TextStyle(color: Colors.white),),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _navigateToQuizNumberScreen(BuildContext context) {/* 해당 함수는 부여받은 context로 새 화면을 만들어 얹습니다. */
//     Navigator.push( /* Navigator에 push로 MaterialPageRoute() 안에서 context를 이용해 이동할 새 페이지를 생성합니다. */
//       context,
//       MaterialPageRoute(
//         builder: (context) => QuizNumberScreen(
//           isMultipleChoiceSelected: isMultipleChoiceSelected!,
//         ),
//       ),
//     );
//   }
// }

// class QuizNumberScreen extends StatefulWidget {
//   final bool isMultipleChoiceSelected;

//   const QuizNumberScreen({Key? key, required this.isMultipleChoiceSelected}) : super(key: key);

//   @override
//   _QuizNumberScreenState createState() => _QuizNumberScreenState();
// }

// class _QuizNumberScreenState extends State<QuizNumberScreen> {
//   int numberOfQuizzes = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xffB77D44),
//       appBar: AppBar( // 선택에 따라 객관식 /주관식으로 나뉨.
//         backgroundColor: Color(0xFF6BA16A),
//         title: Text(widget.isMultipleChoiceSelected ? 'Quiz type: Multiple Choice' : 'Quiz type: Essay'),
//         //해당 Scaffold는 Navigator.push()와 MaterialPageRoute()를 통해 생성되었기에 뒤로가기로 이전화면으로 갈 수 있습니다(Stack에서 pop됩니다)
//       ),
//       body: Center(
//         child: SingleChildScrollView(  // 입력때문에 자식 위젯이 화면에 표시될 때 화면의 크기를 벗어나게 된다.
//           child: Container( //카드 서식
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
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(  // 입력창 서식.
//                   width: 270,
//                   height: 48,
//                   decoration: BoxDecoration( // 입력창 장식 
//                     color: Color(0xFFFFE299), // Box의 배경색
//                     borderRadius: BorderRadius.circular(10), // Box의 모서리를 둥글게 설정
//                   ),
//                   child: TextField( //입력창 영역. 숫자만 입력가능합니다.
//                     textAlign: TextAlign.center,
//                     keyboardType: TextInputType.number, //숫자만 입력하게 설정하며, 숫자가 아니라면 error처리됨.
//                     onChanged: (value) { //입력값이 변경될때마다 콜백되는 함수. 자연수인지를 검산합니다.
//                       setState(() { 
//                         numberOfQuizzes = int.tryParse(value) ?? 0; // => 입력된 값이 정수로 변환될 수 있다면 해당 값을 numberOfQuizzes에 저장하고, 변환할 수 없는 경우 기본값으로 0을 사용
//                       });
//                     },
//                     decoration: InputDecoration( // 텍스트필드의 힌트가 되는 텍스트입니다.
//                       hintText: numberOfQuizzes > 0 ? 'How many Quiz Questions?' : 'Please type Right numbers',
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 60),
//                 ElevatedButton( // 입력값을 제출하는 버튼입니다. 0보다 작다면 콜백함수의 내용으로 _navigateToQuizScreen(context)가 설정되고, 아니면 null로서 클릭이 불가능합니다.
//                   onPressed: numberOfQuizzes > 0
//                       ? () {
//                           _navigateToQuizScreen(context);
//                         }
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF6BA16A),
//                   ),
//                   child: Text(
//                     'Start Quiz!',
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

//   void _navigateToQuizScreen(BuildContext context) {
//     if (widget.isMultipleChoiceSelected) { // 만일 선다형이라면 MaterialPageRoute로 SelectiveCardsQuiz 페이지를 생성하며, 이때 numberOfQuizzes를 넘겨줍니다.
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SelectiveCardsQuiz(
//             numberOfCards: numberOfQuizzes,
//           ),
//         ),
//       );
//     } else {// 만일 선다형이 아니라면 MaterialPageRoute로 EssayCardsQuiz 페이지를 생성하며, 이때 numberOfQuizzes를 넘겨줍니다.
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => EssayCardsQuiz(
//             numberOfCards: numberOfQuizzes,
//           ),
//         ),
//       );
//     }
//   }
// }
