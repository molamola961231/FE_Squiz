import 'package:buttom_navigation/Pages/Social_Page/ShowCategoryResult.dart';
import 'package:flutter/material.dart';
import 'Social_Card_Carousel.dart';
import 'package:get/get.dart'; // 프로필 사진 전역변수처럼 사용하기위해.
import '/Model/StateManaging.dart';
import 'dart:io'; // File키워드 사용
import '/Pages/Social_Page/UploadSelection.dart';
import '/Pages/Social_Page/CategorySelection.dart';
import '/Pages/Social_Page/RecommandationSelection.dart';
import 'ShowCategoryResult.dart';
import 'SocialCardQuizScreen.dart';
import 'RecommandationScreen.dart';
import 'Search_result.dart';

class Social_MainPage extends StatefulWidget {
  @override
  _Social_MainPage_State createState() => _Social_MainPage_State();
}

class _Social_MainPage_State extends State<Social_MainPage> {
  /*getX 컨트롤러*/
  final ProfileController profileController = Get.find();
  final AccountController _accountController = Get.put(AccountController());

  // 필드 영역
  bool ShowFilter = false; // 필터 클릭하면 SetState호출해 상태변경. 이후 Visibility연동하기
  bool ShowCategory = false; // 카테고리 클릭하면 SetState호출해 상태변경. 이후 Visibility연동하기
  bool UploadQuiz = false; //업로드 클릭하면 Setstate 호출해 상태변동. 이후 Visibility 연동하기
  String? Selected_Category; // recommandation필터의 카테고리
  String? selectedCategory; // Category필터의 카테고리

  // 필터값 담아 RecommendationCarousel에 추가해주기위해.

  void passFunction() {
    setState(() {
      UploadQuiz = false;
    });
  }



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller =
        TextEditingController(); // Searchbar 컨트롤러
    return Scaffold(
      backgroundColor: Color(0xFFB77D44),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          //Overflow 관리
          child: Column(
            children: [
              Container(
                height: 140,
                child: Stack(
                  children: [
                    Container(
                      height: 74,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/Setting_info.png'),
                          fit: BoxFit.none,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Obx(
                                () => CircleAvatar(
                                  backgroundImage: profileController
                                          .profileImagePath.isNotEmpty
                                      ? FileImage(File(profileController
                                          .profileImagePath.value))
                                      : null,
                                  backgroundColor:
                                      Colors.grey, // 기본으로 회색으로 채워주세요
                                  radius: 30,
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_accountController.UserNickname.value}', // 유저 이름
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '${_accountController.UserID.value}', // 유저 아이디
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0XFFFAEA59),
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                child: IconButton(
                                  icon: Icon(Icons.notifications,
                                      color: Color(0XFFFAEA59 /*0XFFF5B000*/)),
                                  onPressed: () {
                                    // 알람 아이콘 클릭 시 동작
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 30, // 검색창 높이 지정
                                  child: TextField(
                                    controller: controller,
                                    textAlignVertical: TextAlignVertical.center,
                                    autofocus: false /*true*/,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: 'Search Quizcode...',
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.search,
                                            size: 18, color: Color(0XFF3E6426)),
                                        onPressed: () {
                                          // 검색 아이콘 클릭 시 동작
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => SearchResult(
                                              Searchword: controller.text.replaceAll('#', ''),
                                            ),
                                          ),
                                        );
                                        print(controller.text); // 콘솔에 입력된 문자에서 #을 지우고 출력
                                        },
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(
                                            color: Color(0XFF3E6426)),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 5), // 수직 패딩 조정
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.3),
                                child: IconButton(
                                  icon: Image.asset('images/button_Filter.png',
                                      width: 20, height: 20),
                                  onPressed: () {
                                    // 필터 아이콘 클릭 시 동작
                                    setState(() {
                                      ShowCategory = false;
                                      ShowFilter = !ShowFilter;
                                      UploadQuiz = false;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.3),
                                child: IconButton(
                                  icon: Icon(
                                      ShowCategory
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Color(0XFF3E6426)),
                                  iconSize: 26,
                                  onPressed: () {
                                    // 열기 아이콘 클릭 시 동작
                                    setState(() {
                                      ShowFilter = false;
                                      ShowCategory = !ShowCategory;
                                      UploadQuiz = false;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.3),
                                child: IconButton(
                                  icon: Icon(Icons.upload,
                                      color: Color(0XFF3E6426)),
                                  onPressed: () {
                                    // 업로드 아이콘 클릭 시 동작
                                    setState(() {
                                      ShowCategory = false;
                                      ShowFilter = false;
                                      UploadQuiz = !UploadQuiz;
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ), // 여기까지 user정보
              SizedBox(height: 50),
              /** 필터 클릭하면 오픈할 Visibility창 */
              RecommandationSelectionWidget(
                ShowFilter: ShowFilter,
                onClose: () {
                  setState(() {
                    ShowFilter = false;
                  });
                },
              ),

              /** 더보기 클릭하면 오픈할 Visibility창 */
              CategorySelectionWidget(
                ShowCategory: ShowCategory,
                SelectedCategory: selectedCategory,
                onClose: () {
                  setState(() {
                    ShowCategory = false;
                  });
                },
                onCategorySelected: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                  print('Selected Category: $category');
                  if (category != '') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowCategoryResult(
                          selectedCategory: category,
                        ),
                      ),
                    );
                  }
                },
              ),

              Visibility(
                  child: UploadSelection(externalFunction: passFunction),
                  visible: UploadQuiz),

              /*유저 업로드 퀴즈*/
              SocialCardQuizScreen(
                  Title: "Uploaded Quiz",
                  UserToken: _accountController.getUserCode()),
              /*북마크 퀴즈  */
              SocialCardQuizScreen(
                  Title: "Bookmarked Quiz",
                  UserToken: _accountController.getUserCode()),
              // 더 추가할건 추후 업데이트할것.
              Visibility(
                visible: profileController.RecommandationFilter.isNotEmpty,
                child: RecommandationCards(
                  Title: "Recommandation",
                  UserToken: _accountController.getUserCode(),
                ),
                // child: Social_Card_Carousel(
                //     Title: "Quiz Recommandation",
                //     recommendationFilter:
                //         profileController.RecommandationFilter),
              )
            ],
          ),
        ),
      ),
    );
  }
}
