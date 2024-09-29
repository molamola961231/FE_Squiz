// import 'package:flutter/material.dart';
// import '/DefaultAppBar.dart';

// class EssayCardsQuiz extends StatefulWidget {
//   final int numberOfCards;

//   const EssayCardsQuiz({Key? key, required this.numberOfCards}) : super(key: key);

//   @override
//   _EssayCardsQuizState createState() => _EssayCardsQuizState();
// }

// class _EssayCardsQuizState extends State<EssayCardsQuiz> {
//   late List<String?> essayAnswers; // 각 퀴즈 카드에서 주관식 답안을 저장하는 리스트
//   int currentIndex = 0; // 현재 퀴즈 카드의 인덱스
//   final TextEditingController _essayController = TextEditingController(); // 주관식 답안을 입력받는 컨트롤러

//   @override
//   void initState() {
//     super.initState();
//     essayAnswers = List<String?>.filled(widget.numberOfCards, null);
//   }

//   @override
//   void dispose() {
//     _essayController.dispose(); // 사용이 끝난 컨트롤러는 dispose하여 메모리 누수를 방지합니다.
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xff5E8E5E),
//       appBar: DefaultAppBar(),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Container(
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
//                 SizedBox(height: 30),
//                 GestureDetector(
//                   onTap: () {
//                     // QuestionBox 클릭 시 포커스를 제거하여 키보드를 내립니다.
//                     FocusScope.of(context).requestFocus(FocusNode());
//                   },
//                   child: _buildQuestionBox(),
//                 ),
//                 SizedBox(height: 30),
//                 _buildEssayBox(),
//                 SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildCircleButton(Icons.arrow_back, _showPreviousCard),
//                     SizedBox(width: 140),
//                     _buildCircleButton(Icons.arrow_forward, _showNextCard),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildQuestionBox() {
//     return Container(
//       width: 270,
//       height: 200,
//       decoration: BoxDecoration(
//         color: Color(0xFFE2F0D9),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Center(
//         child: Text('Question ${currentIndex + 1} here'),
//       ),
//     );
//   }

//   Widget _buildEssayBox() {
//     return Container(
//       width: 270,
//       height: 200,
//       decoration: BoxDecoration(
//         color: Color(0xFFFFE299),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: TextField(
//         controller: _essayController, // 컨트롤러 설정
//         onChanged: (text) {
//           essayAnswers[currentIndex] = text; // 주관식 답변을 리스트에 저장
//         },
//         maxLines: null, // 줄바꿈이 자유롭도록 설정
//         keyboardType: TextInputType.multiline, // 여러 줄의 입력을 받도록 설정
//         decoration: InputDecoration(
//           border: InputBorder.none, // 테두리 없애기
//           hintText: 'Type your answer here...',
//           contentPadding: EdgeInsets.all(16), // 내용 안으로 padding 주기
//         ),
//       ),
//     );
//   }

//   Widget _buildCircleButton(IconData icon, Function()? onPressed) {
//     return FloatingActionButton(
//        heroTag: null, 
//       child: Icon(icon),
//       onPressed: onPressed != null ? () => onPressed!() : null,
//       mini: true,
//       backgroundColor: Colors.green,
//     );
//   }

//   void _showPreviousCard() {
//     if (currentIndex > 0) {
//       setState(() {
//         currentIndex--;
//         _essayController.text = essayAnswers[currentIndex] ?? ''; // 이전 카드의 답안으로 TextField 업데이트
//       });
//     }
//   }

//   void _showNextCard() {
//     if (currentIndex < widget.numberOfCards - 1) {
//       setState(() {
//         currentIndex++;
//         _essayController.text = essayAnswers[currentIndex] ?? ''; // 다음 카드의 답안으로 TextField 업데이트
//       });
//     } else {
//       showQuizResults();
//        print('Is Card Finished? ${isCardFinished()}'); // 카드 끝났는지 보여주는데수
//     }
//   }

//   /*getter:isCardFinished로 t/f값 반환해서 내부 조작하기 쉽게! */
//   bool isCardFinished() {
//   return currentIndex == widget.numberOfCards - 1;
// }

//   void showQuizResults() {
//     for (int i = 0; i < widget.numberOfCards; i++) {
//       print('Answer for Essay ${i + 1}: ${essayAnswers[i]}');
//     }
//   }

//   List<String?> getEssayResults() {
//     return List.from(essayAnswers); // 주관식 답변 리스트 반환
//   }
// }