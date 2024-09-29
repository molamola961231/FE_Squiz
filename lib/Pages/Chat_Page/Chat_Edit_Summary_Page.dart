import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/Model/StateManaging.dart';

class ChatEditSummaryPage extends StatelessWidget {
  final QuizHandlingController quizHandlingController = Get.find();

  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController(
        text: quizHandlingController.summarizedContext.value);

    textEditingController.addListener(() {
      quizHandlingController.updateTokenCount(textEditingController.text);
    });
    quizHandlingController
        .updateTokenCount(quizHandlingController.summarizedContext.value);

    return Scaffold(
      backgroundColor: Color(0xffD4E7D4),
      appBar: AppBar(
        title: Text('Edit Summary'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              quizHandlingController
                  .updateSummarizedContext(textEditingController.text);
              Get.back(); // Navigate back after saving
            },
          ),
        ],
      ),
      body: Container(
          color: Color(0xffD4E7D4),
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text('Simple is the better!'),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: textEditingController,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Edit Summary',
                  ),
                ),
                SizedBox(height: 10),
                Obx(
                  () => Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      children: [
                        Text(
                            'Token approximation: ${quizHandlingController.tokenCount.value} / 4097',
                            style: TextStyle(
                                color: Color(0XFF5E8E5E), fontSize: 16)),
                        (quizHandlingController.tokenCount.value<180)?Text('Available Quiz:30'):Text('')
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
