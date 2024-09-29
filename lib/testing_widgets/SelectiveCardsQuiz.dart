// import 'package:flutter/material.dart';
// import '/DefaultAppBar.dart';

// class SelectiveCardsQuiz extends StatefulWidget { /* 선행되야 할 클래스: Class Create_Quiz */
//   final int numberOfCards;

//   const SelectiveCardsQuiz({Key? key, required this.numberOfCards}) : super(key: key);
//   /** 키값 추가하기.."" */

//   // static bool isCardFinished(int currentIndex, int numberOfCards) {
//   //   return currentIndex == numberOfCards - 1;
//   // } ==> argument 있으니까 잠시 바꿔보지.
//   @override
//   _SelectiveCardsQuizState createState() => _SelectiveCardsQuizState();
// }

// class _SelectiveCardsQuizState extends State<SelectiveCardsQuiz> { //                     getQuizResults() 수정사항 있음!!
//   late List<int> selectedAnswers; // 각 퀴즈 카드에서 선택된 답변의 인덱스를 저장하는 리스트
//   int currentIndex = 0; // 현재 퀴즈 카드의 인덱스

//   @override
//   void initState() {
//     super.initState();
//     selectedAnswers = List<int>.filled(widget.numberOfCards, -1); 
//     /* selectedAnswers는 정수 value(선택된 답안의 인덱스)만을 저장한다. 
//     selectedAnswers의 index의 끝은 numberOfCards기 때문에 결국 selectedAnswers[i]는 i번째 퀴즈의 정답을 의미하기때문에 카드번호를 별도로 저장할 필요가 없다.
//     filled(widget.numberOfCards, -1)는 numberOfCards개의 리스트를 -1로 초기화 시키라는 의미이다.
//     */
//   }

//   @override
//   Widget build(BuildContext context) { // 카드 빌드
//     return Scaffold(
//       appBar: DefaultAppBar(),
//       backgroundColor: Color(0xff5E8E5E),
//       body: Center(
//         child: Container( //카드포맷
//           height: 600,
//           width: 320,
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage("images/Card_Background.png"), // 퀴즈 카드의 배경 이미지 설정
//               fit: BoxFit.cover,
//             ),
//             color: Colors.white, // 퀴즈 카드의 배경색 설정
//             border: Border.all(width: 4, color: Colors.green), // 퀴즈 카드의 테두리 설정
//             borderRadius: BorderRadius.circular(20), // 퀴즈 카드의 모서리를 둥글게 설정
//           ),
//           child: Column( // 정답 , 문제 box
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(height: 30), // 문제 박스와의 간격 조절
//               _buildQuestionBox(), // 문제 박스 위젯 생성
//               SizedBox(height: 15), // 답안 박스와의 간격 조절
//               _buildAnswerBoxes(), // 답안 박스 위젯 생성
//               SizedBox(height: 10), // 다음/이전 버튼과의 간격 조절
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildCircleButton(Icons.arrow_back, _showPreviousCard), // 이전 버튼 위젯 생성
//                   SizedBox(width: 140),
//                   _buildCircleButton(Icons.arrow_forward, _showNextCard), // 다음 버튼 위젯 생성
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /* 문제 박스 위젯 생성
//      구현할 기능: gpt로부터 문제 받아오기....
//      구현된 기능: 문제 번호 표기 */
//   Widget _buildQuestionBox() {
//     return Container(
//       width: 270,
//       height: 200,
//       decoration: BoxDecoration(
//         color: Color(0xFFE2F0D9), // 문제 박스의 배경색 설정
//         borderRadius: BorderRadius.circular(10), // 문제 박스의 모서리를 둥글게 설정
//       ),
//       child: Center(
//         child: Text('Question ${currentIndex + 1} here'), // 현재 퀴즈 카드의 문제 번호 표시
//       ),
//     );
//   }

//   /* 선다 박스 위젯 생성
//      구현할 기능: gpt로부터 문제의 index받아와 답안 옵션  받아오기
//      구현된 기능: 클릭시 색깔 설정 & 나머지 색상은 default로 다시 렌더링하기 
//      ...setState통한 re-rendering으로 구현됨 */
//   Widget _buildAnswerBoxes() {
//     return Column(
//       children: List.generate(
//         4, // 4개 만들어라....
//         (index) => Container( // index는 반복문으로 만들 4AnswerBox중 몇번째 인덱스인지.
//           width: 270,
//           height: 48,
//           margin: EdgeInsets.symmetric(vertical: 10),
//           child: TextButton(
//             style: TextButton.styleFrom(
//               backgroundColor: selectedAnswers[currentIndex] == index ? Color(0xFFE2F0D9) : Color(0xFFFFE299), 
//               /* 배경색 결정 메커니즘:
//                 selectedAnswers는 처음 초기화될때 numberOfCards개의 리스트를 -1로 초기화 된다. 
//                 따라서 리스트의 [currentIndex]번째 값이 index와 같다면 선택된 것이므로 초록색으로 지정하고  아니라면 -1로 초기화된 처음 리스트를 따른다.
//                */
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onPressed: () { // 클릭하면 State를 업데이트(다시 빌드: 초기값으로 되돌리기) 한다.
//               setState(() { 
//                 selectedAnswers[currentIndex] = index; // 선택된 답안 업데이트한다.
//               }); //해당 코드를 다 실행하면 setState함수가 속한 위젯은 다시 빌드(디폴트 초기화 값을 가지도록 변경)된다. ****************************************************
//             },
//             child: Text('${index + 1}번 답안:', style: TextStyle(color: Colors.grey)),
//           ),
//         ),
//       ),
//     );
//   }

//     /* 버튼 위젯 생성
//      구현할 기능: 
//      구현된 기능: onPressed가 null이 아니라면 함수 실행, 아니면 함수 실행 없이. 
//      실행할 함수는 argument로 받는다.
//       */
//   Widget _buildCircleButton(IconData icon, Function()? onPressed) {
//     return FloatingActionButton(
//       child: Icon(icon),
//       heroTag: null, 
//       onPressed: onPressed != null ? () => onPressed!() : null,
//       mini: true,
//       backgroundColor: Colors.green,
//     );
//   }

//   /* 이전 퀴즈 카드로 이동하는 함수
//   구현할 기능:
//   구현된 기능: 처음 카드가 아니라면 이전카드로 재 렌더링을 실행.
//   */
//   void _showPreviousCard() {
//     if (currentIndex > 0) {
//       setState(() {
//         currentIndex--;
//       });
//     }
//   }

//   /* 다음 퀴즈 카드로 이동하는 함수
//   구현할 기능: 마지막 카드면 퀴즈결과를 담은 리스트를 반환하는 getQuizResults를 CardsQuiz(numberOfCards: int value) 호출하는 페이지에 전달
//               => 전달된 getQuizResults는 CardsQuiz(numberOfCards: int value) 호출하는 페이지에서 Score(getQuizResults)를 통해 
//               정오를 확인 후 db에 저장시킴.
//   구현된 기능: 마지막 카드가 아니라면 다음카드로 재 렌더링을 실행.
//   마지막 카드라면 퀴즈결과 출력.
//   */
//   void _showNextCard() {
//     if (currentIndex < widget.numberOfCards - 1) {
//       setState(() {
//         currentIndex++;
//       });
//     } else {
//       showQuizResults(); // 퀴즈 결과 출력
//        print('Is Card Finished? ${isCardFinished()}'); // 카드 끝났는지 보여주는데수
//     }
//   }

// //   /*getter:isCardFinished로 t/f값 반환해서 내부 조작하기 쉽게! ==>SelectiveCardsQuiz로 이동시킴 */
//   bool isCardFinished() {
//   return currentIndex == widget.numberOfCards - 1;
// }

//   /* 임시: 퀴즈 결과 출력하는 함수...나중에 문제와 옵션을 저장하는 함수로 변경할것 */ 
//   void showQuizResults() {
//     for (int i = 0; i < widget.numberOfCards; i++) {
//       print('Answer for Question ${i + 1} = ${selectedAnswers[i] + 1}');
//     }
//   }

//     // 퀴즈 결과를 get할 수 있게 해 주는 함수
//   // 퀴즈 결과를 반환하는 함수
//   List<int> getQuizResults() {
//     /* 선택된 답변의 인덱스를 저장한 리스트에서 -1이 아닌 값을 찾아 결과 리스트에 추가.. 
//     나중엔 문제내용과 selectedAnswers[i] 둘다 저장할 수 있게 수정할것 !!  */
//     List<int> quizResults = [];
//     for (int i = 0; i < selectedAnswers.length; i++) {
//       if (selectedAnswers[i] != -1) {
//         quizResults.add(selectedAnswers[i]);
//       }
//     }
//     return quizResults;
//   }

  

// }