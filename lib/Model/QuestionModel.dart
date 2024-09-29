class QuestionModel { 
  /* 
  - json파일을 다트 클래스로 변환시킬 규격.
  - https://app.quicktype.io/에서 json파일을 업로딩하고 dart로 convert하면 쉽게 모델클래스가 생성된다
 */
  int questionNumber;
  String question;
  List<String> options;
  String answer;

  QuestionModel({
    required this.questionNumber,
    required this.question,
    required this.options,
    required this.answer,
  });
  
  /* json을 decode한 형태인 {}, 즉 Map<key, value>쌍 Map<String, dynamic>을 인자로 받아 QuestionModel형태로 바꾼다. */
  factory QuestionModel.fromJson(Map<String, dynamic> Decoded_json) => QuestionModel(
        questionNumber: Decoded_json["questionNumber"],
        question: Decoded_json["question"],
        options: List<String>.from(Decoded_json["options"].map((x) => x)),
        answer: Decoded_json["answer"],
    );

    Map<String, dynamic> toJson() => {
        "questionNumber": questionNumber,
        "question": question,
        "options": List<dynamic>.from(options.map((x) => x)),
        "answer": answer,
    };
}