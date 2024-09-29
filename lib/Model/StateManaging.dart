import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*회원정보 컨트롤러*/
class AccountController extends GetxController {
  var UserID = ''.obs;
  var UserPW = ''.obs;
  var UserNickname = ''.obs;
  var AfterAuth = false.obs;
  var UserToken = ''.obs; //발급받은 회원 토큰
  var Used_APIToken = 0.obs; //GPT API 토큰수 초기값을 0으로 설정 

/*  ↓ GPT API 토큰 수 확인하는 메소드 ↓  */
  void Refresh_Used_APIToken() {
    var now = DateTime.now();
    if (now.day == 1) {
      Used_APIToken.value = 0;
    }
  }

  void Update_Used_APIToken(int usedToken) {
    Used_APIToken.value += usedToken;
  }

  int Get_Used_APIToken() {
    return Used_APIToken.value;
  }
  void updateAfterAuth(bool value) {
    AfterAuth.value = value;
  }
  /*  ↑ GPT API 토큰 수 확인하는 메소드 ↑  */

  int getUserCode() {
    int UserTokenInt = int.tryParse(UserToken.value) ?? 0;
    return UserTokenInt;
  }

  String getUserID() {
    return UserID.value;
  }

  String getUserNickname() {
    return UserNickname.value;
  }

  bool isPWvalid(String PW) {
    return (PW == UserPW.value);
  }

  void PrintUserInfo() {
    print(
        'ID: ${UserID.value}, PW: ${UserPW.value}, Nickname: ${UserNickname.value},Token: ${UserToken.value}');
  }

  void getUserInfo(String ID, String PW, String Nickname, int UserTokenvalue) {
    UserID.value = ID;
    UserPW.value = PW;
    UserNickname.value = Nickname;
    UserToken.value = UserTokenvalue.toString();
  }

  void getBriefUserInfo(String ID, String PW) {
    UserID.value = ID;
    UserPW.value = PW;
  }

  void handleLogout() {
    UserID.value = '';
    UserPW.value = '';
    UserNickname.value = '';
    AfterAuth.value = false;
  }
}

/*PDF페이지 텍스트 추출 전용 컨트롤러*/
class ContextController extends GetxController {
  var recentPDFContextForGPT = ''.obs;

  void updateContext(String context) {
    recentPDFContextForGPT.value = context;
  }

  void clearContext() {
    recentPDFContextForGPT.value = '';
  }
}

/*퀴즈 소셜페이지 북마크 전용 컨트롤러*/
class BookmarkController extends GetxController {
  var bookmarkedQuizzes = <String>[].obs;
  var likesCount = {}.obs; // 북마크 한 사람수 카운터.

  // 퀴즈명 자체가 ID가 된다.
  void addBookmark(String quizID, int BeforeUpdate) {
    if (!bookmarkedQuizzes.contains(quizID)) {
      bookmarkedQuizzes.add(quizID);
      //유저의 북마크여부에 따라 카운트 변경.
      if (!likesCount.containsKey(quizID)) {
        likesCount[quizID] = BeforeUpdate;
      }
      likesCount[quizID] = likesCount[quizID]! + 1;
    }
  }

  void AddBookmark(String quizID) {
    if (!bookmarkedQuizzes.contains(quizID)) {
      bookmarkedQuizzes.add(quizID);
      //유저의 북마크여부에 따라 카운트 변경.
    }
  }

  void removeBookmark(String quizID) {
    if (bookmarkedQuizzes.contains(quizID)) {
      bookmarkedQuizzes.remove(quizID);
      //유저의 북마크 여부에 따라 카운트 변경
      if (likesCount.containsKey(quizID)) {
        likesCount[quizID] = likesCount[quizID]! - 1;
      }
    }
  }

  bool isBookmarked(String quizID) {
    return bookmarkedQuizzes.contains(quizID);
  }

  void reverseBookmark(String quizID) {
    if (bookmarkedQuizzes.contains(quizID)) {
      bookmarkedQuizzes.remove(quizID);
    } else {
      bookmarkedQuizzes.add(quizID);
    }
  }

  // 북마크 num 가져오기
  int getLikes(String quizName, int BeforeUpdate) {
    return likesCount[quizName] ?? BeforeUpdate;
  }
}

/*프로필 전용 컨트롤러*/
class ProfileController extends GetxController {
  var profileImagePath = ''.obs;
  var RecommandationFilter =
      <String>[].obs; // 프로필에서 유저의 recommandationFilter역시 관리합니다.

  @override
  void onInit() {
    super.onInit();
    _loadProfileImage();
  }

  void setProfileImage(String path) {
    profileImagePath.value = path;
    _saveProfileImage(path);
  }

  Future<void> _saveProfileImage(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', path);
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    profileImagePath.value = prefs.getString('profileImagePath') ?? '';
  }
}

/*Quiz Handling 전용 컨트롤러*/
class QuizHandlingController extends GetxController {
  var summarizedContext = ''.obs;
  var QuizRowData = ''.obs; // Make_Quiz_Card의 GPT응답을 임시로 저장하는 리스트.
  var tokenCount = 0.obs; // 토큰 카운터

  void updateSummarizedContext(String context) {
    summarizedContext.value = context;
  }

  void clearSummarizedContext() {
    summarizedContext.value = '';
  }

  void updateQuizRowData(String context) {
    QuizRowData.value = context;
  }

  void clearQuizRowData() {
    QuizRowData.value = '';
  }

  void updateTokenCount(String text) {
    tokenCount.value = _calculateGPTTokens(text);
  }

  int _calculateGPTTokens(String text) {
    // 간단한 공백 기준 토큰화 방식 적용
    List<String> tokens = text.split(RegExp(r'\s+'));
    int Beforecalibration = tokens.where((token) => token.isNotEmpty).length;
    int Aftercalibration = (1.5 * Beforecalibration).ceil();
    return Aftercalibration;
  }
}
