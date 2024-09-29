import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'RecievedCard.dart';
import 'package:get/get.dart';
import '/Model/StateManaging.dart';

class RecommandationCards extends StatefulWidget {
  final int UserToken;
  final String Title;

  RecommandationCards({required this.UserToken, required this.Title})
      : super(key: UniqueKey());

  @override
  _RecommandationCardsState createState() => _RecommandationCardsState();
}

class _RecommandationCardsState extends State<RecommandationCards> {
  late Future<List<Map<String, dynamic>>> requestContents;
  final ProfileController profileController = Get.find();

  @override
  void initState() {
    super.initState();
    requestContents = fetchRecommandationRequestContents(profileController.RecommandationFilter);
  }

  Future<List<Map<String, dynamic>>> fetchRecommandationRequestContents(List<String> categories) async {
    final Allcategory = categories.join(',').toString(); // 전체 카테고리 리턴...
    final url = 'http://13.209.134.75:8080/social/categories/$Allcategory';
    final response = await http.get(Uri.parse(url), headers: {'accept': '*/*'});

    if (response.statusCode == 200) {
      try {
        final responseBody = utf8.decode(response.bodyBytes);
        final data = json.decode(responseBody) as List;

        List<Map<String, dynamic>> contents = [];

        for (var item in data) {
         contents.add(item);
        }

        return contents;
      } catch (e) {
        print('Error parsing response: $e');
        throw Exception('Failed to parse quiz data');
      }
    } else {
      throw Exception('Failed to load quiz data');
    }
  }

  void refreshData() {
    setState(() {
      requestContents = fetchRecommandationRequestContents(profileController.RecommandationFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: requestContents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()
                // child:   Lottie.asset('asset/Squizloading.json')
                );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final contents = snapshot.data!;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      SizedBox(width: 5),
                      Text(
                        widget.Title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lemon(
                          fontSize: 20,
                          color: Color(0xFF3E6426),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: contents.length,
                    itemBuilder: (context, index) {
                      final item = contents[index];
                      return Row(
                        children: [
                          RecievedCard(
                            item: item,
                            refreshData: refreshData,
                          ),
                          SizedBox(width: 10),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('No data Found'));
          }
        },
      ),
    );
  }
}
