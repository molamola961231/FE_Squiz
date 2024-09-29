import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart'; // 북마크 상태관리를 위한 getx 사용
import '/Model/StateManaging.dart'; // 상태관리 페이지
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/Pages/Quiz_Page/SocialCardQuiz.dart';

class RecievedCard extends StatelessWidget {
  Map<String, dynamic> item;
  Function refreshData;
  int userTokenVal = Get.find<AccountController>().getUserCode();
  RecievedCard({required this.item, required this.refreshData});

  Future<void> DeleteQuiz(BuildContext context, String quizId, int userToken,
      Function refreshData) async {
    quizId = quizId.replaceAll('#', '').toString();
    final String url =
        // 'http://13.209.134.75:8080/social/%23$quizId?userId=$userToken';
        'http://13.209.134.75:8080/social/%23$quizId?userId=${userTokenVal}';
    //삭제 확인할건지 물어보고 삭제 진행
    bool confirmDeletion = await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Delete Quiz'),
          content: Text('Are you sure you want to delete this quiz?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            CupertinoDialogAction(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (!confirmDeletion) {
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      // 응답 본문을 UTF-8로 디코딩
      final responseMessage = utf8.decode(response.bodyBytes);

      // 서버 응답이 성공적일 때와 실패했을 때의 처리
      if (response.statusCode == 200) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Quiz Deletion'),
              content: Text(responseMessage), // 서버의 응답 메시지를 표시
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () {
                    refreshData();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Quiz Deletion Failed'),
              content: Text(responseMessage), // 실패 메시지를 표시
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error: $e');
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Quiz Deletion Failed'),
            content: Text('Failed to delete quiz. Please try again later.'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showBottomSheet(
      BuildContext context,
      String quizName,
      String category,
      String uploader,
      int likes,
      int UploaderToken,
      var QuizData,
      Function refreshData /** */) {
    final AccountController accountController = Get.put(AccountController());

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
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // if (UploaderToken != 10) {
            //   _BookmarkButton(quizName, item['quizId'], likes, refreshData),
            // }
            UploaderToken != accountController.UserToken
                ? _BookmarkButton(quizName, item['quizId'], likes, refreshData)
                : Container(),

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
                                          child: Text('$category',
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
                        child: int.tryParse(UploaderToken.toString()) ==
                                accountController.getUserCode()
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
                                      print(QuizData);
                                      print(QuizData.runtimeType);
                                      print('"quizesFromGpt": ' +
                                          QuizData.toString());
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SocialCardQuiz(
                                            QuizContents:
                                                QuizData, //QuizData['quizesFromGpt'],
                                            QuizName: quizName,
                                          ),
                                        ),
                                      );
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
                                      print(item['quizId']);
                                      DeleteQuiz(
                                          context,
                                          item['quizId'],
                                          accountController.getUserCode(),
                                          refreshData);
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
    String quizName = item['title'] ?? 'No Title';
    String category = item['category'] ?? 'Unknown';
    String uploader = item['uploader'] ?? 'Unknown';
    int UploaderToken = item['userId'] ?? 0;
    int likes = item['likes'] ?? 0;
    var rawQuizContents = item['quizesFromGpt'] ?? [];

    List<Map<String, dynamic>> QuizContents = [];

    if (rawQuizContents is List) {
      for (var element in rawQuizContents) {
        if (element is Map<String, dynamic>) {
          // Ensure that we add all quiz questions to QuizContents
          QuizContents.add(element);
        }
      }
    }
    

    /* 역순으로 들어오기에 정렬 한번 진행해줌. 이때QuizContents는 List<Map<String, dynamic>>형태임 */
    /*즉, 정렬 진행 후에는 List<Map<String, dynamic>> QuizContents = [
    {questionNumber: 1, question: What is the data structure used to represent polynomials, large numbers, and implement other data structures?, options: [Linked list, Array, Stack, Queue], answer: Linked list},
    {questionNumber: 2, question: What is the purpose of having multiple pointers in a double linked list?, options: [To traverse in both forward and backward directions, To store more data, To make the list circular, To rearrange elements], answer: To traverse in both forward and backward directions}
    .
    .
    .
    {questionNumber: 30, question: What is the main disadvantage of using a linked list for implementing a graph?, options: [Requires more memory, Slower access speed, Difficult to implement, Limited data storage], answer: Slower access speed}
    ]형태가 되는 것임.    */

    QuizContents.sort((a, b) {
      int questionNumberA = a['questionNumber'] as int;
      int questionNumberB = b['questionNumber'] as int;
      return questionNumberA.compareTo(questionNumberB);
    });

    final BookmarkController bookmarkController = Get.put(BookmarkController());
    return InkWell(
        onTap: () {
          print(item);
          print('Clicked');
          print(QuizContents);
          _showBottomSheet(context, quizName, category, uploader, likes,
              UploaderToken, QuizContents, refreshData);
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
  final String quizID;
  final int BeforeUpdatelikes;
  final Function refreshData;

  _BookmarkButton(
      this.quizName, this.quizID, this.BeforeUpdatelikes, this.refreshData);

  @override
  __BookmarkButtonState createState() => __BookmarkButtonState();
}

class __BookmarkButtonState extends State<_BookmarkButton> {
  bool isBookmarked = true; // 북마크 컨텐츠일경우를 가정하고 일단 true로 설정하기로 함
  final AccountController accountController =
      Get.find(); // AccountController 가져오기

  Future<void> HandleBookmark(
      String quizID, int userToken, Function refreshData) async {
    final String url = 'http://13.209.134.75:8080/social/toggle';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'userId': userToken,
        'quizId': quizID,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      if (responseBody == 'Bookmark removed successfully' ||
          responseBody == 'Bookmark added successfully') {
        refreshData();
      } else {
        print('Unexpected response: $responseBody');
      }
    } else {
      print('Failed to toggle bookmark: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final BookmarkController bookmarkController = Get.find();
    final AccountController accountController =
        Get.find(); // AccountController 가져오기

    return Positioned(
      top: 15,
      right: 2,
      child: Obx(() {
        // bool isBookmarked = bookmarkController.isBookmarked(widget.quizID);
        return IconButton(
          icon: Image.asset(
            // isBookmarked
             bookmarkController.isBookmarked(widget.quizID)
                ? 'images/icon_Bookmark_filled.png'
                : 'images/icon_Bookmark.png',
            width: 30,
            height: 30,
          ),
          onPressed: () {
            // HandleBookmark 함수 호출
            HandleBookmark(
              widget.quizID,
              accountController.getUserCode(), // userToken
              widget.refreshData, // refreshData 함수
            ).then((_) {
              setState(() {
                // isBookmarked = !isBookmarked;
              bookmarkController.reverseBookmark(widget.quizID);
                if (bookmarkController.isBookmarked(widget.quizID)) {
                  print('${widget.quizName} is added to your bookmark');
                  // bookmarkController.addBookmark(
                  //     widget.quizName, widget.BeforeUpdatelikes);
                  bookmarkController.AddBookmark(widget.quizID);
                } else {
                  print('${widget.quizName} is removed from your bookmark');
                  // bookmarkController.removeBookmark(widget.quizName);
                  bookmarkController.removeBookmark(widget.quizID);
                }
              });
            }).catchError((error) {
              print('Failed to toggle bookmark: $error');
            });
          },
        );
      }),
    );
  }
}
