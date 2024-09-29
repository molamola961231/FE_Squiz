import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart'; // 북마크 상태관리를 위한 getx 사용
import '/Model/StateManaging.dart'; // 상태관리 페이지

class CardFromServer extends StatelessWidget {
  final String quizName;
  final String category;
  final String uploader;
  final int likes;
  //해쉬태그 추가? 아마도 필요할듯? oo 추가하자. 해쉬태그는 몇개까지? 음..5개까지?

  // 생성자, 필요한 데이터들을 받아옴
  CardFromServer({
    required this.quizName,
    required this.category,
    required this.uploader,
    required this.likes,
  });

  // JSON 데이터를 받아 CardFromServer 객체로 변환하는 팩토리 메서드
  //  json 형식:
  // {
  //   "quizName": "역사퀴즈 #0A14", ==> 해당 코드로 퀴즈데이터를 업로딩합니다.
  //   "category": "사회",
  //   "producer": "S'Quiz",
  //   "likes": 10
  // }

  factory CardFromServer.fromJson(Map<String, dynamic> json) {
    return CardFromServer(
      quizName: json['quizName'],
      category: json['category'],
      uploader: json['producer'],
      likes: json['likes'],
    );
  }

  // 서버에서 퀴즈 데이터를 가져오는 비동기 함수
  Future<void> fetchQuizData(BuildContext context) async {
    final response = await http
        .get(Uri.parse('https://your-api-endpoint.com/quiz?name=$quizName'));

    if (response.statusCode == 200) {
      // 응답이 성공적일 때, 데이터를 파싱하여 showQuizData 함수 호출..나중에 OptionalCardQuiz로 넘겨주자...
      Map<String, dynamic> quizData = json.decode(response.body);
      showQuizData(context, quizData);
    } else {
      // 응답이 실패할 때 예외 발생
      throw Exception('Failed to load quiz data');
    }
  }

  // Map<String, dynamic> quizData를 화면에 다이얼로그로 표시하는 함수... 나중에 그냥 OptionalCardQuiz로  Map<String, dynamic> quizData를 전달해준다.
  void showQuizData(BuildContext context, Map<String, dynamic> quizData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(quizName),
          content: Text(quizData.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, String quizName, String category,
      String uploader, int likes /** */) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7, // 700 height equivalent
        maxChildSize: 1.0, // Expand to full height
        minChildSize: 0.7, // Minimum height
        builder: (_, controller) => Stack(
          children: [
            Container(
              // height: 700,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/Bottomsheet_background.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              top: 15,
              left: 2,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            _BookmarkButton(quizName, likes),
            Positioned(
              top: 50,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  Container(
                    height: 280,
                    child: Column(children: [
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                              'images/Card_for_Bottomsheet_Uploaded.png'),
                          SizedBox(width: 30),
                          Container(
                            width: 200,
                            height: 175,
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /** 텍스트 */
                                    Text(
                                      '${quizName.split('#').first}',
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.lemon(
                                        fontSize: 16,
                                        color: Color(0xFF3E6426),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          'Category: ',
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.lemon(
                                            fontSize: 16,
                                            color: Color(0xFF3E6426),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '$category',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          'Uploader: ',
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.lemon(
                                            fontSize: 16,
                                            color: Color(0xFF3E6426),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(' $uploader',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.left),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          'Bookmarks : ',
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.lemon(
                                            fontSize: 16,
                                            color: Color(0xFF3E6426),
                                          ),
                                        ),
                                        // Text('$likes',
                                        //     style: TextStyle(
                                        //         fontSize: 16,
                                        //         fontWeight: FontWeight.bold),
                                        //     overflow: TextOverflow.ellipsis,
                                        //     textAlign: TextAlign.left),
                                        Obx(() {
                                          //업데이트 코드
                                          final BookmarkController
                                              bookmarkController = Get.find();
                                          int updatedLikes = bookmarkController
                                              .getLikes(quizName, likes);
                                          return Text('$updatedLikes',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.left);
                                        }),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          'Quiz Code : ',
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.lemon(
                                            fontSize: 16,
                                            color: Color(0xFF3E6426),
                                          ),
                                        ),
                                        Expanded(
                                          child: SelectableText(
                                              '${quizName.split('#').last}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 30),
                      /* 추후 유저 닉네임 확인 절차 구현하게끔 코드 업로드 */
                      Container(
                        /* 조건부 버튼 내용 교체 */
                        height: 30,
                        width: double.infinity,
                        child: uploader ==
                                "S'Quiz" /* 유저계정과 해당 퀴즈의 업로더가 같을경우로 업데이트 요망 */
                            ? Row(
                                /* 유저계정과 해당 퀴즈의 업로더가 같을경우  */
                                children: [
                                  ElevatedButton(
                                    // Edit quiz - 서버에 반영하게끔
                                    /* 추후 서버에 edit한 퀴즈결과를 반영하게끔 */
                                    onPressed: () {
                                      print('Edit the Quiz');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF5E8E5E),
                                    ),
                                    child: Text(
                                      'Edit Quiz',
                                      style:
                                          TextStyle(color: Color(0xFFFDE599)),
                                    ),
                                  ),
                                  Spacer(),
                                  ElevatedButton(
                                    // Start quiz - 퀴즈 풀이
                                    /* 추후 quizData 를 Optional card quiz로 넘겨 이동시킬 것 */
                                    onPressed: () {
                                      print('Start the Quiz');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF5E8E5E),
                                    ),
                                    child: Text(
                                      'Start Quiz',
                                      style:
                                          TextStyle(color: Color(0xFFFDE599)),
                                    ),
                                  ),
                                  Spacer(),
                                  ElevatedButton(
                                    // Delete Quiz - 서버에 반영하게끔
                                    /* 추후 quizData 를 Optional card quiz로 넘겨 이동시킬 것 */
                                    onPressed: () {
                                      print('Delete the Quiz'); // 여기에 삭제 구현
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF5E8E5E),
                                    ),
                                    child: Text(
                                      'Delete Quiz',
                                      style:
                                          TextStyle(color: Color(0xFFFDE599)),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                /* 유저계정과 해당 퀴즈의 업로더가 다를경우  */
                                children: [
                                  ElevatedButton(
                                    // Download quiz
                                    // 내부 db에 저장
                                    /* 추후 quizData를 내부db에 저장하게끔 */
                                    onPressed: () {
                                      print('Download the Quiz');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF5E8E5E),
                                    ),
                                    child: Text(
                                      'Download the Quiz',
                                      style:
                                          TextStyle(color: Color(0xFFFDE599)),
                                    ),
                                  ),
                                  Spacer(),
                                  ElevatedButton(
                                    // Start quiz
                                    // 퀴즈 페이지로 이동
                                    /* 추후 quizData 를 Optional card quiz로 넘겨 이동시킬 것 */
                                    onPressed: () {
                                      print('Start Quiz');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF5E8E5E),
                                    ),
                                    child: Text(
                                      'Start the Quiz',
                                      style:
                                          TextStyle(color: Color(0xFFFDE599)),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BookmarkController bookmarkController = Get.put(BookmarkController());
    return InkWell(
        // 클릭 시 fetchQuizData 함수 호출
        onTap: () {
          print('Clicked');
          _showBottomSheet(context, quizName, category, uploader, likes);
          // 추후 이걸 추가하기: fetchQuizData(context),
        },
        child: Stack(
          children: [
            Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/Card_Social_Uploaded.png'),
                    fit: BoxFit.none,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 80, height: 150),
                    Container(
                        width: 100,
                        height: 140,
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.end, // 정렬을 하단으로 맞춤
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            SizedBox(height: 20),
                            Expanded(
                                child: Text('Name: $quizName',
                                    overflow: TextOverflow.ellipsis)),
                            Expanded(
                                child: Text('Category: $category',
                                    overflow: TextOverflow.ellipsis)),
                            Expanded(
                                child: Text(
                              'Uploader: $uploader',
                              overflow: TextOverflow.ellipsis,
                            )),
                            Expanded(
                                child: Text(
                              'likes :${bookmarkController.getLikes(quizName, likes)}',
                              overflow: TextOverflow.ellipsis,
                            )),
                          ],
                        ))
                  ],
                )),
          ],
        ));
  }
}

class _BookmarkButton extends StatefulWidget {
  final String quizName;
  final int BeforeUpdatelikes;

  _BookmarkButton(this.quizName, this.BeforeUpdatelikes);

  @override
  __BookmarkButtonState createState() => __BookmarkButtonState();
}

class __BookmarkButtonState extends State<_BookmarkButton> {
  bool isBookmarked = true; // 북마크 컨텐츠일경우를 가정하고 일단 true로 설정하기로 함

  @override
  Widget build(BuildContext context) {
    final BookmarkController bookmarkController = Get.find();

    return Positioned(
      top: 15,
      right: 2,
      child: Obx(() {
        bool isBookmarked = bookmarkController.isBookmarked(widget.quizName);
        return IconButton(
          icon: Image.asset(
            isBookmarked
                ? 'images/icon_Bookmark_filled.png'
                : 'images/icon_Bookmark.png',
            width: 30,
            height: 30,
          ),
          onPressed: () {
            setState(() {
              isBookmarked = !isBookmarked;
              if (!isBookmarked) {
                print('${widget.quizName} is added to your bookmark');
                bookmarkController.removeBookmark(widget.quizName);
                /* 여기서 북마크된 퀴즈명&코드 유저 계정에 추가하는 코드 추가 */
              } else if (isBookmarked) {
                print('${widget.quizName} is now removed from your bookmark');
                bookmarkController.addBookmark(
                    widget.quizName, widget.BeforeUpdatelikes);

                /* 여기서 북마크된 퀴즈명&코드 유저 계정에서 제거하는 코드 추가 */
              }
            });
          },
        );
      }),
    );
  }
}
