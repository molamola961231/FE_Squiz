import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'; // 클립보드 사용
import 'dart:convert'; // dart ↔ json
import 'package:http/http.dart' as http; // api통신(엔드포인트) 위해.
import '/Pages/Chat_Page/Const_for_chat.dart'; // OpenAI api key val등.
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:get/get.dart';
import '/Model/StateManaging.dart';
import '/Pages/Chat_Page/Chat_Edit_Summary_Page.dart';
import 'package:google_fonts/google_fonts.dart';
import '/Pages/Quiz_Page/Make_Quiz_Card.dart';

String apiKey = ConstForChat.OPEN_AI_KEY;
String OPEN_AI_ORGANIZATION = ConstForChat.OPEN_AI_ORGANIZATION_addr;
String API_URL = ConstForChat.GPT_API_URL;
bool IsNormalConvo = true;

class Chat_Main_Page extends StatefulWidget {
  final String FileName;
  final String contextText_for_GPT;

  const Chat_Main_Page(
      {Key? key, required this.contextText_for_GPT, required this.FileName})
      : super(key: key);

  @override
  _Chat_Main_PageState createState() => _Chat_Main_PageState();
}

class _Chat_Main_PageState extends State<Chat_Main_Page> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textEditingController = TextEditingController();
  final QuizHandlingController quizHandlingController =
      Get.put(QuizHandlingController()); //퀴즈로 넘겨줄 요약된 context를 저장하기위해.
  final History chatHistory = History(); // 히스토리 객체 생성
  final AccountController accountController =
      Get.put(AccountController()); // 토큰 수 갱신 및 저장
  bool isEmpty = true;
  String ExtractingFrom = '';

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void getEnv() async {
    await dotenv.load();
    String apiKey = dotenv.get("OPEN_AI_KEY");
    String OPEN_AI_ORGANIZATION = dotenv.get("OPEN_AI_ORGANIZATION_addr");
    String API_URL = dotenv.get("GPT_API_URL");
  }

  /* 메신저 UI에 메시지 반영시키는 함수 */
  Future<void> _sendMessage(String text, bool isVisible,
      {String userId = '1', String userName = 'User'}) async {
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          user: ChatUser(id: userId, name: userName),
          text: text,
          createdAt: DateTime.now(),
          isVisible: isVisible,
        ),
      );
      _textEditingController.clear();
      isEmpty = true;
    });
  }

  void copyMessagesToClipboard() {
    final clipboardContent = _messages.reversed.map((message) => message.text).join('\n\n'); // Allow line breaks between messages
    Clipboard.setData(ClipboardData(text: clipboardContent));
    print('Messages copied to clipboard: $clipboardContent');
  }

  /* GPT와 통신하는 함수 */
  Future<void> _chatWithGPT(String text, String user) async {
    String prompt = text;
    bool isSummary = false;
    print('Entering _chatWithGPT');
    print('Prompt: $prompt');

    // GPT에게 메시지 송신하기 전에 메신저 UI에 반영
    if (user == 'ContextProvider') {
      // ContextProvider 사용자일 경우
      isSummary = true;
      await _sendMessage(
          //'Summerize the Context with Keywords and index it, and explain it: $text',
          'Summarize the given context focusing on keywords within 1000 tokens. The response must be in English. Given context: $text',
          false,
          userId: '3',
          userName: 'ContextProvider');
      print('Summerize request sent to UI.\n Context: $text');
      prompt =
          //'';
          'Summarize the given context briefly focusing on keywords within 1000 tokens. The response must be in English, brief and simple as possible. Given context: $text';
      // 'Extract the keywords and concepts from given context. The response must be in English, within 2000 tokens.Given context: $text';
    } else if (user == 'KeywordProvider') {
      isSummary = true;
      await _sendMessage(
          'Extract Keywords and following concepts. The response must be in English. Given context: $text',
          false,
          userId: '3',
          userName: 'ContextProvider');
      print('Summerize request sent to UI.\n Context: $text');
      prompt =
          'Extract Keywords and following concepts. The response must be in English. Given context: $text';
    } else {
      // 일반 사용자일 경우
      isSummary = false;
      await _sendMessage(text, true, userId: '1', userName: 'User');
      if (chatHistory.chatLogs.isEmpty) {
        chatHistory.updatehistory(
          widget.contextText_for_GPT,
          '0',
          DateTime.now().toIso8601String().substring(0, 19),
          chatHistory._calculateGPTTokens(text),
        );
      }
      prompt =
          'Answer $text within this context: ${chatHistory.chatLogs}'; //text;
      print('User message sent to UI');

      /* 08.08 업데이트 */
      chatHistory.updatehistory(
        text,
        '1',
        DateTime.now().toIso8601String().substring(0, 19),
        chatHistory._calculateGPTTokens(text),
      );
    }

    /*GPT에게 송신하는 메시지 형식*/
    Map<String, dynamic> requestBody = {
      "model": 'gpt-3.5-turbo-instruct', // 해당 모델은 추후 fine tune된 모델로 대체할 것.
      "prompt": prompt,
      "max_tokens":
          1000, // 해당 토큰값이 너무 작을 경우, 응답의 정확도가 심하게 떨어짐. 너무 커질경우, 입력값을 줄여야함.
      "temperature": 0.7, // 응답의 다양성을 조정 (0.0 - 1.0)
      "top_p": 1.0 // 응답의 질을 조정 (0.0 - 1.0)
    };

    String encodedRequestBody;
    try {
      encodedRequestBody = json.encode(requestBody); /*json 형식으로 encode*/
      print('Request body successfully encoded: $encodedRequestBody');
    } catch (e) {
      print('Failed to encode request body: $e');
      return;
    }

    print('Sending request to GPT...');
    // 응답완료까지  CircularProgressIndicator 표기...
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      /* GPT로 메시지 송신. */
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/completions"),
        /*gpt3.5 사용 시 endpoint 주소. 모델별로 해당 주소 상이함.*/
        //Uri.parse("https://api.openai.com/v1/assistants"), /*assistants 이용해 이전 대화목록 기억해 사용*/
        headers: {
          'Authorization': 'Bearer $apiKey',
          "Content-Type": "application/json",
          'OpenAI-Organization': OPEN_AI_ORGANIZATION,
          'OpenAI-Beta': 'assistants=v2'
        },
        body: encodedRequestBody,
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

        print(
            '\n.\n. Token Usage of the month: ${accountController.Get_Used_APIToken()} \n.\n.');
        print('GPT Response: $gptResponse');
        print('\n.\n.TokenUsage:$TokenUsage\n.\n.');
        if (isSummary) {
          quizHandlingController.updateSummarizedContext(gptResponse);
          print(
              'Summery Saved:${quizHandlingController.summarizedContext.value}');
        } // 이제 summarizedContext에 gpt요약 담음.

        // Call _sendMessage separately to update the UI
        if (IsNormalConvo) {
          await _sendMessage(gptResponse, true, userId: '2', userName: 'GPT');

          /* 08.08 업데이트 */
          chatHistory.updatehistory(
            gptResponse,
            '2',
            DateTime.now().toIso8601String().substring(0, 19),
            chatHistory._calculateGPTTokens(gptResponse),
          );
          print('\n.\n.\n.\nHistory:');
          print(chatHistory.chatLogs);
        } else if (!IsNormalConvo) {
          await _sendMessage(gptResponse, true,
              userId: '4', userName: 'ContextProvider');
          IsNormalConvo = true;
        }
      } else {
        print('Failed to get response from GPT: ${response.statusCode}');
        _sendMessage(
            'The token limit has been exceeded.\nYou can still Generate the Quiz, however we have Chat history overflow.\nPlease re-extract the context from PDF for the chat.',
            true,
            userId: '2',
            userName: 'GPT');
      }
      chatHistory.doubleTap(); // 초과했으니까 가장 오래된 대화내용 제거하기
    } catch (e) {
      print('Error occurred while interacting with GPT: $e');
    } finally {
      Navigator.of(context).pop(); // Close the CircularProgressIndicator dialog
    }
  }

  void _ContextProvideLog(String text, bool isVisible,
      {String userId = '1', String userName = 'User'}) {
    print('Entering _ContextProvideLog');
    print('Context Text: $text');

    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          user: ChatUser(id: userId, name: userName),
          text: text,
          createdAt: DateTime.now(),
          isVisible: isVisible,
        ),
      );
      _textEditingController.clear();
      isEmpty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 128, 156, 127),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Color(0xFF92BE87),
      endDrawer: Drawer(
        backgroundColor: Color(0xFFD4E7D4),
        child: Column(
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: [
                  Text('Features'),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      InkWell(
                        child: Row(
                          children: [
                            Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Color(0xFFA9C7A9),
                                  borderRadius:
                                      BorderRadius.circular(5), // 둥근 사각형 설정
                                ),
                                child:
                                    Image.asset('images/Icon_GPT_Summary.png')),
                            Text(' Summary')
                          ],
                        ),
                        onTap: () {
                          IsNormalConvo = false;
                          ExtractingFrom = 'Summary';
                          print('Button pressed');
                          _chatWithGPT('${widget.contextText_for_GPT}',
                              'ContextProvider');
                          _ContextProvideLog(
                            'context ${widget.contextText_for_GPT}를 gpt에 전송 완료했습니다',
                            false,
                            userId: '3',
                            userName: 'ContextProvider',
                          );
                        },
                      ),
                      Spacer(),
                      InkWell(
                        child: Row(
                          children: [
                            Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Color(0xFFA9C7A9),
                                  borderRadius:
                                      BorderRadius.circular(5), // 둥근 사각형 설정
                                ),
                                child: Container(
                                    height: 40,
                                    width: 40,
                                    child: Image.asset(
                                        'images/Icon_GPT_Keyword.png'))),
                            Text(' Keyword')
                          ],
                        ),
                        onTap: () {
                          IsNormalConvo = false;
                          ExtractingFrom = 'Keyword';
                          print('Button pressed');
                          _chatWithGPT('${widget.contextText_for_GPT}',
                              'KeywordProvider');
                          _ContextProvideLog(
                            'context ${widget.contextText_for_GPT}를 gpt에 전송 완료했습니다',
                            false,
                            userId: '3',
                            userName: 'ContextProvider',
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
            //Drawer body
            SizedBox(height: 60),

            Visibility(
              visible: ExtractingFrom != '',
              child: InkWell(
                child: Container(
                  height: 40,
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      Container(
                          width: 30,
                          height: 30,
                          child: ExtractingFrom == 'Summary'
                              ? Image.asset('images/Icon_Fix_GPT_Summary.png')
                              : Image.asset('images/Icon_Fix_GPT_Keyword.png')),
                      SizedBox(width: 20),
                      Text('Edit $ExtractingFrom')
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatEditSummaryPage(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 60),
            Visibility(
              child: InkWell(
                onTap: () {
                  quizHandlingController.clearSummarizedContext;
                  _sendMessage('Previous $ExtractingFrom deleted', true,
                      userId: '4', userName: 'ContextProvider');
                  setState(() {
                    ExtractingFrom = '';
                  });
                },
                child: Container(
                  height: 40,
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      Container(
                          width: 30,
                          height: 30,
                          child: ExtractingFrom == 'Summary'
                              ? Image.asset('images/Icon_Fix_GPT_Summary.png')
                              : Image.asset('images/Icon_Fix_GPT_Keyword.png')),
                      SizedBox(width: 20),
                      Text(
                        'Clear $ExtractingFrom',
                        style: TextStyle(color: Colors.red),
                      )
                    ],
                  ),
                ),
              ),
              visible: ExtractingFrom != '',
            ),
            Expanded(
              child: Container(), // 공간을 차지하여 최하단으로 밀어내는 역할
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    // 대화 로그 클립보드 복사 버튼임
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF759CB2).withOpacity(0.7),
                          spreadRadius: 0,
                          blurRadius: 5.0,
                          offset: Offset(0, 10), // changes position of shadow
                        )
                      ],
                    ),
                    child: OutlinedButton(
                      onPressed: () {
                        copyMessagesToClipboard();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Text("Notification"),
                              content: Text(
                                  "The chat log has been copied to the clipboard."),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        side: BorderSide(color: Color(0xFFE8EEF1), width: 2),
                      ),
                      child: Container(
                        height: 30,
                        width: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Copy ChatLog',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lemon(
                            fontSize: 20,
                            color: Color(0XFFA7CDA7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    // 퀴즈 생성 버튼임
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF759CB2).withOpacity(0.7),
                          spreadRadius: 0,
                          blurRadius: 5.0,
                          offset: Offset(0, 10), // changes position of shadow
                        )
                      ],
                    ),
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MakeQuizCard(
                                FileName: widget.FileName,
                                ExtractedContextforGPT: quizHandlingController
                                        .summarizedContext.value.isNotEmpty
                                    ? quizHandlingController.summarizedContext
                                        .value // 요약본이 있을땐 요약본을 넘겨줌.(토큰부담 저하)
                                    : widget.contextText_for_GPT
                                // 요약본이 없을땐 추출 텍스트를 넘겨줌
                                ),
                          ),
                        );
                        ;
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        side: BorderSide(color: Color(0xFFE8EEF1), width: 2),
                      ),
                      child: Container(
                        height: 30,
                        width: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Make Quiz',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lemon(
                            fontSize: 20,
                            color: Color(0XFFA7CDA7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30)
                ],
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Visibility(
                    visible: message.isVisible,
                    child: Align(
                      alignment: message.user.id == '1'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: MessageWidget(message: message),
                    ),
                  );
                },
              ),
            ),
            ChatInputField(
              textEditingController: _textEditingController,
              onSend: (text) {
                print('Send button pressed');
                if (text.isNotEmpty) {
                  _chatWithGPT(text, 'User');
                  print(text);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final ChatUser user;
  final String text;
  final DateTime createdAt;
  final bool isVisible;

  ChatMessage({
    required this.user,
    required this.text,
    required this.createdAt,
    required this.isVisible,
  });
}

class ChatUser {
  final String id;
  final String name;
  ChatUser({required this.id, required this.name});
}

class ChatInputField extends StatefulWidget {
  /* 별도로 분리시킨 키보드 위젯 */
  final TextEditingController textEditingController;
  final ValueChanged<String> onSend;

  const ChatInputField({
    Key? key,
    required this.textEditingController,
    required this.onSend,
  }) : super(key: key);

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool isEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.textEditingController,
              minLines: 1,
              maxLines: 2,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                hintText: 'Type a message...',
                fillColor: Color(0XFFC7DFC7),
                filled: true,
              ),
              onChanged: (text) {
                setState(() {
                  isEmpty = text.isEmpty;
                });
              },
            ),
          ),
          Visibility(
            visible: !isEmpty,
            child: Row(
              children: [
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFFFAEA59)),
                  onPressed: () {
                    print('Send button pressed in ChatInputField');
                    final text = widget.textEditingController.text;
                    if (text.isNotEmpty) {
                      widget.onSend(text);
                      setState(() {
                        isEmpty = true;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final ChatMessage message;

  const MessageWidget({Key? key, required this.message}) : super(key: key);

  Color determineColor(String messengerID) {
    if (messengerID == '1') {
      return Color(0xFFFDE599);
    } else if (messengerID == '4') {
      return Color(0xFFA9C7A9);
    } else {
      return Color(0xFFE8EEF1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: determineColor(message.user.id),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: message.user.id == '1'
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          SelectableText(
            message.text,
            style: TextStyle(
                color:
                    message.user.id == '4' ? Color(0xFF6D6D6D) : Colors.black),
          ),
        ],
      ),
    );
  }
}

/*히스토리 클래스*/
class History {
  final List<Map<String, dynamic>> chatLogs = [];

  void checkhistory(String text, int newTokens) {
    int totalTokens = newTokens;
    for (var log in chatLogs) {
      totalTokens += log['token'] as int;
    }

    while (totalTokens > 4096) {
      totalTokens -= chatLogs.first['token'] as int;
      chatLogs.removeAt(0);
    }
  }

  void doubleTap() {
    int totalTokens = _calculateTotalTokens();
    print('Total tokens: $totalTokens');
    while (totalTokens > 4096 && chatLogs.isNotEmpty) {
      totalTokens -= chatLogs.first['token'] as int;
      chatLogs.removeAt(0);
      print('First chatlog is deleted!');
    }
  }

  int _calculateTotalTokens() {
    int totalTokens = 0;
    for (var log in chatLogs) {
      totalTokens += _calculateGPTTokens(log['chatlog']);
    }
    return totalTokens;
  }

  int _calculateGPTTokens(String chatlog) {
    // 간단한 공백 기준 토큰화 방식 적용
    List<String> tokens = chatlog.split(RegExp(r'\s+'));
    int Beforecalibration = tokens.where((token) => token.isNotEmpty).length;
    int Aftercalibration = (1.5 * Beforecalibration).ceil();
    return Aftercalibration;
  }

  void updatehistory(String text, String userId, String timestamp, int tokens) {
    checkhistory(text, tokens);
    chatLogs.add({
      'id': userId,
      'chatlog': text,
      'timestamp': timestamp,
      'token': tokens,
    });
  }
}
