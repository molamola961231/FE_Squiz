import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'CardFromServer.dart';
import 'package:get/get.dart'; // 북마크 상태관리를 위한 getx 사용
import '/Model/StateManaging.dart'; // 상태관리 페이지

class Social_Card_Carousel extends StatelessWidget {
  final String Title; // 표기할 타이틀 텍스트
  /*  카테고리에 따라 달라지는 bottom sheet 내용 
    - 만일 이게 Uploaded Quiz면 버튼 내용이 Row로 ("Edit Quiz","Start Quiz","Delete Quiz")로 구현하기(서버에 올라갈 quizdata수정, 퀴즈 풀이페이지 이동,서버에 올라간 퀴즈데이터 삭제)
      
    - else 버튼 내용이 Row로 ("Download Quiz","Start Quiz")로 구현하기.(내부db에 퀴즈 데이터 저장, 퀴즈풀이 페이지)
  */
  final List<String>? recommendationFilter;

  const Social_Card_Carousel(
      {Key? key,
      required this.Title, // 이걸로 Type이 Uploaded Quizzes인지,Bookmarked Quizzes인지,Recommandation인지 문맥을 넘겨주는 String변수
      //required this.QuizData_from_Server // 서버에서 받아올 퀴즈 데이터들.
      required this.recommendationFilter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //북마크 getter
    final BookmarkController bookmarkController = Get.find();
    final ProfileController profileController = Get.find();

    /** ↓ 임시: UI테스팅용 리스트 생성 */
    final List<CardFromServer> cards = [
      /*추후 서버에서 해당 데이터 받아올것.*/
      CardFromServer(
          quizName: "유기농 농업 퀴즈 #AGRI0001",
          category: "Agricultural Studies",
          uploader: "S'Quiz",
          likes: 10),
      CardFromServer(
          quizName: "물리학 기본 퀴즈 #PHYS0002",
          category: "Physical Science",
          uploader: "S'Quiz",
          likes: 15),
      CardFromServer(
          quizName: "세계 문명 퀴즈 #HUMN0003",
          category: "Humanities and Liberal Arts",
          uploader: "S'Quiz",
          likes: 8),
      CardFromServer(
          quizName: "현대 미술 퀴즈 #ARTS0004",
          category: "The Visual and Performing Arts",
          uploader: "S'Quiz",
          likes: 12),
      CardFromServer(
          quizName: "교통사고 예방 퀴즈 #TRAN0005",
          category: "Transportation and Distribution Services",
          uploader: "S'Quiz",
          likes: 20),
      CardFromServer(
          quizName: "세계 문학 이야기 #HUMN0006",
          category: "Humanities and Liberal Arts",
          uploader: "S'Quiz",
          likes: 7),
      CardFromServer(
          quizName: "Flutter 퀴즈 #COMP0007",
          category: "Computer Science",
          uploader: "S'Quiz",
          likes: 18),
      CardFromServer(
          quizName: "스타트업 비즈니스 퀴즈 #BUSI0008",
          category: "Business Management",
          uploader: "S'Quiz",
          likes: 13),
      CardFromServer(
          quizName: "독립 영화 퀴즈 #ARTS0009",
          category: "The Visual and Performing Arts",
          uploader: "S'Quiz",
          likes: 25),
      CardFromServer(
          quizName: "에너지 음료의 진실 #HLTH0010",
          category: "Health Professions and Medical Services",
          uploader: "S'Quiz",
          likes: 9),
/*이후 랜덤하게 표기*/
      CardFromServer(
          quizName: "Organic Farming Trivia #AGRI0011",
          category: "Agricultural Studies",
          uploader: "QuizMaster",
          likes: 14),
      CardFromServer(
          quizName: "Quantum Physics Quiz #PHYS0012",
          category: "Physical Science",
          uploader: "KnowledgeHub",
          likes: 22),
      CardFromServer(
          quizName: "Ancient Civilizations Quiz #HUMN0013",
          category: "Humanities and Liberal Arts",
          uploader: "TriviaKing",
          likes: 19),
      CardFromServer(
          quizName: "Impressionist Art Trivia #ARTS0014",
          category: "The Visual and Performing Arts",
          uploader: "QuizGenius",
          likes: 17),
      CardFromServer(
          quizName: "Public Transportation Trivia #TRAN0015",
          category: "Transportation and Distribution Services",
          uploader: "QuizMaster",
          likes: 24),
      CardFromServer(
          quizName: "Shakespearean Literature Quiz #HUMN0016",
          category: "Humanities and Liberal Arts",
          uploader: "KnowledgeHub",
          likes: 11),
      CardFromServer(
          quizName: "Artificial Intelligence Basics #COMP0017",
          category: "Computer Science",
          uploader: "TriviaKing",
          likes: 27),
      CardFromServer(
          quizName: "Startup Business Models #BUSI0018",
          category: "Business Management",
          uploader: "QuizGenius",
          likes: 16),
      CardFromServer(
          quizName: "Spaghetti Western Trivia #ARTS0019",
          category: "The Visual and Performing Arts",
          uploader: "QuizMaster",
          likes: 28),
      CardFromServer(
          quizName: "Truth of Energy Drinks #HLTH0020",
          category: "Health Professions and Medical Services",
          uploader: "KnowledgeHub",
          likes: 13)
    ];
    final List<CardFromServer> Selected_cards = [];
    for (var card in cards) {
      if (Title == "Uploaded Quiz" && card.uploader == "S\'Quiz") {
        Selected_cards.add(
            card); // 타이틀이 업로드한 퀴즈 => 유저명 가져와서 일치하는 것만 Selected_cards에 추가
      } else if (Title == "Bookmarked Quiz" &&
          bookmarkController.isBookmarked(card.quizName) == true) {
        Selected_cards.add(card);
      } else if (Title == "Quiz Recommandation" &&
          profileController.RecommandationFilter.contains(
              extractSubjectCode(card.quizName))) {
        Selected_cards.add(card);
      }
    }
    /** ↑ UI테스팅 리스트 이용 완료 후 주석처리할 코드 */
    /* getx를 통해 업데이트 된 ui를 감지하는 코드*/
    return Container(
        height: 250,
        width: double.infinity,
        child: Column(
          children: [
            Row(
              /* 상단 텍스트*/
              children: [
                SizedBox(width: 5),
                Text(
                  Title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lemon(
                    fontSize: 20,
                    color: Color(0xFF3E6426),
                  ),
                ),
                Spacer(),
                TextButton(
                  child: Text(
                    'View All',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF54C5F8),
                    ),
                  ),
                  onPressed: () {
                    print('view all');
                    // 여기에 서버에서 [맥락]에 의해 선택된 퀴즈데이터들을 보여주는 페이지로 이동하게해주면 됨. 해당 페이지도 구현해야함
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            /** *Card 넣는거 여기에
            FutureBuilder<List<CardFromServer>>(
              future: fetchCardsFromServer(category),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // 데이터 로딩 중일 때 로딩 표시기
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // 에러 발생 시 에러 메시지 표시
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  // 데이터 로딩 완료 시 카드 목록 표시
                  final cards = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cards.length, // 해당 cards.leangth는 서버에서 받아올것!
                    itemBuilder: (context, index) {
                      return cards[index];
                    },
                  );
                }
              },
            ),
            */
            /** ↓ 임시 UI테스팅용 코드. ui요소 반영된 것 */
            Title == "Bookmarked Quiz"
                ? Expanded(
                    child: Obx(() {
                      // Obx를 이용해 실시간 상태관리 모니터링
                      final Selected_cards = cards.where((card) {
                        if (Title == "Uploaded Quiz" &&
                            card.uploader == "S'Quiz") {
                          return true;
                        } else if (Title == "Bookmarked Quiz" &&
                            bookmarkController.isBookmarked(card.quizName)) {
                          return true;
                        }
                        return false;
                      }).toList();

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: Selected_cards.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              CardFromServer(
                                quizName: Selected_cards[index].quizName,
                                category: Selected_cards[index].category,
                                uploader: Selected_cards[index].uploader,
                                likes: Selected_cards[index].likes,
                              ),
                              SizedBox(width: 10),
                            ],
                          );
                        },
                      );
                    }),
                  )
                : Container(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: Selected_cards
                          .length, // Ensure cards is defined and not null
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            CardFromServer(
                              quizName: Selected_cards[index].quizName,
                              category: Selected_cards[index].category,
                              uploader: Selected_cards[index].uploader,
                              likes: Selected_cards[index].likes,
                            ),
                            SizedBox(width: 10)
                          ],
                        );
                      },
                    ),
                  ),
            SizedBox(height: 10)
            /** ↑ 임시 UI테스팅용 코드. 이후 제거할것. */
          ],
        ));
  }

  /*
  // 서버에서 카드를 가져오는 비동기 함수
  Future<List<CardFromServer>> fetchCardsFromServer(String category) async {
    final response = await http.get(
        Uri.parse('https://your-api-endpoint.com/cards?category=$category'));

    if (response.statusCode == 200) {
      // 응답이 성공적일 때, 데이터를 파싱하여 CardFromServer들이 든 객체 리스트로 변환
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => CardFromServer.fromJson(json)).toList();
    } else {
      // 응답이 실패할 때 예외 발생
      throw Exception('Failed to load cards');
    }
  }

  */
}

String extractSubjectCode(String quizName) {
  RegExp regExp = RegExp(r'#([A-Z]+)\d+');
  Match? match = regExp.firstMatch(quizName);

  if (match != null) {
    return match.group(1)!;
  } else {
    throw Exception("패턴을 찾을 수 없습니다.");
  }
}
