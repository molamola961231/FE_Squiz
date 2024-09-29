import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert'; // 통신
import 'package:http/http.dart' as http;
import '/Pages/Quiz_Page/SocialCardQuiz.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart'; // 북마크 상태관리를 위한 getx 사용
import '/Model/StateManaging.dart'; // 상태관리 페이지

class ShowCategoryResult extends StatefulWidget {
  final String selectedCategory;

  ShowCategoryResult({required this.selectedCategory});

  @override
  _ShowCategoryResultState createState() => _ShowCategoryResultState();
}

class _ShowCategoryResultState extends State<ShowCategoryResult> {
  late Future<List<Map<String, dynamic>>> QuizData_from_Category;

  /*request하기.... */
  Future<List<Map<String, dynamic>>> fetchQuizData(String category) async {
    final url =
        Uri.parse('http://13.209.134.75:8080/social/categories/$category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load quiz data');
    }
  }

  @override
  void initState() {
    super.initState();
    QuizData_from_Category = fetchQuizData(widget.selectedCategory);
  }

  Future<void> toggleBookmark(String quizId) async {
    final AccountController accountController = Get.put(AccountController());
    int userToken = accountController.getUserCode();

    final url = Uri.parse('http://13.209.134.75:8080/social/toggle');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userToken,
        'quizId': quizId,
      }),
    );

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(responseBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text('Failed to toggle bookmark'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final BookmarkController bookmarkController = Get.find();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6BA16A),
        title: Text('Category Code: ${widget.selectedCategory}'),
      ),
      backgroundColor: Color(0xFFB77D44),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: QuizData_from_Category,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                // child: CircularProgressIndicator()
                child: Lottie.asset('asset/Squizloading.json'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          final quizData = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: quizData.length,
            itemBuilder: (context, index) {
              final quiz = quizData[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: CategorizedCard(
                  title: quiz['title'],
                  category: quiz['category'],
                  uploader: quiz['uploader'],
                  quizId: quiz['quizId'],
                  onQuizTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SocialCardQuiz(
                          QuizContents: List<Map<String, dynamic>>.from(
                              quiz['quizesFromGpt']),
                          QuizName: quiz['title'],
                        ),
                      ),
                    );
                  },
                  onBookmarkTap: () {
                    toggleBookmark(quiz['quizId']);
                    bookmarkController.AddBookmark(quiz['quizId']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CategorizedCard extends StatelessWidget {
  // 카드 UI
  final String title;
  final String category;
  final String uploader;
  final String quizId;
  final Function onQuizTap;
  final Function onBookmarkTap;

  CategorizedCard({
    required this.title,
    required this.category,
    required this.uploader,
    required this.quizId,
    required this.onQuizTap,
    required this.onBookmarkTap,
  });
  String get utf8Title {
    try {
      return utf8.decode(title.runes.toList());
    } catch (e) {
      return title; // fallback to original title if decoding fails
    }
  }

  String get utf8Uploader {
    try {
      return utf8.decode(uploader.runes.toList());
    } catch (e) {
      return uploader; // fallback to original uploader if decoding fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 250,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 340,
            height: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/Social_Category_deco.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: 340,
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Added alignment
              children: [
                Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:
                            AssetImage('images/Social_Category_deco_body.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          utf8Title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF629C3B),
                              fontSize: 16),
                        ),
                        SizedBox(height: 40),
                        Row(
                          children: [
                            SizedBox(width: 115),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Category: $category'),
                                SizedBox(height: 20),
                                Container(
                                  width: 180,
                                  child: Text(
                                    'Uploader: $utf8Uploader',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 20),
                                SelectableText(
                                  'Quiz ID: $quizId',
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )),
                Column(
                  children: [
                    InkWell(
                      onTap: () => onBookmarkTap(),
                      child: Container(
                        width: 40,
                        height: 100,
                        color: Color(0xFFFFE5A3),
                        child: Center(child: Icon(Icons.add)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Text("Start Quiz"),
                              content: Text("Do you want to start this quiz?"),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    onQuizTap();
                                  },
                                  child: Text("Yes"),
                                ),
                                CupertinoDialogAction(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("No"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 100,
                        color: Color(0xFFFFB800),
                        child: Center(
                          child: Icon(
                            Icons.download,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
