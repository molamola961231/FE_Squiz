import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '/Model/StateManaging.dart';

class RecommandationSelectionWidget extends StatefulWidget {
  final bool ShowFilter;
  final Function onClose;

  RecommandationSelectionWidget({
    required this.ShowFilter,
    required this.onClose,
  });

  @override
  _RecommandationSelectionWidgetState createState() =>
      _RecommandationSelectionWidgetState();
}

class _RecommandationSelectionWidgetState
    extends State<RecommandationSelectionWidget> {
  final ProfileController profileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.ShowFilter,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 43,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/Memo_Container_Background_image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 407,
            decoration: BoxDecoration(
              color: Color(0xFFFFFDE2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      ' Recommandation Filter',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lemon(
                        fontSize: 20,
                        color: Color(0xFF3E6426),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        widget.onClose(); // X 버튼 클릭 시 onClose 호출
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          FilterButton(
                              Subject: 'Agricultural Studies',
                              SubjectCode: "AGRI"),
                          FilterButton(
                              Subject: 'Architecture Design',
                              SubjectCode: "ARCH"),
                          FilterButton(
                              Subject: 'Biological Sciences',
                              SubjectCode: "BIO_"),
                          FilterButton(
                              Subject: 'Business Management',
                              SubjectCode: "BUSI"),
                          FilterButton(
                              Subject: 'Computer Science', SubjectCode: "COMP"),
                          FilterButton(
                              Subject: 'Culinary and Cosmetic Services',
                              SubjectCode: "CULI"),
                        ],
                      ),
                      Column(
                        children: [
                          FilterButton(
                              Subject: 'Engineering', SubjectCode: "ENGR"),
                          FilterButton(
                              Subject:
                                  'Health Professions and Medical Services',
                              SubjectCode: "HLTH"),
                          FilterButton(
                              Subject: 'Humanities and Liberal Arts',
                              SubjectCode: "HUMN"),
                          FilterButton(
                              Subject: 'Legal Studies', SubjectCode: "LEGL"),
                          FilterButton(
                              Subject: 'Mechanical and Electrical Repair',
                              SubjectCode: "MECH"),
                          FilterButton(
                              Subject: 'Media Related Communication',
                              SubjectCode: "MEDI"),
                        ],
                      ),
                      Column(
                        children: [
                          FilterButton(
                              Subject: 'Physical Science', SubjectCode: "PHYS"),
                          FilterButton(
                              Subject: 'Psychology', SubjectCode: "PSYC"),
                          FilterButton(
                              Subject: 'School Administration',
                              SubjectCode: "SCHL"),
                          FilterButton(
                              Subject: 'The Visual and Performing Arts',
                              SubjectCode: "ARTS"),
                          FilterButton(
                              Subject:
                                  'Transportation and Distribution Services',
                              SubjectCode: "TRAN"),
                          FilterButton(Subject: 'ETC', SubjectCode: "MISC"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String Subject;
  final String SubjectCode;
  final ProfileController profileController = Get.find();

  FilterButton({
    required this.Subject,
    required this.SubjectCode,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ProfileController profileController = Get.find();
      final isFilterSelected =
          profileController.RecommandationFilter.contains(SubjectCode);

      return TextButton(
        onPressed: () {
          if (isFilterSelected) {
            profileController.RecommandationFilter.remove(SubjectCode);
            print('Removed Filter Subject: $SubjectCode');
          } else if (profileController.RecommandationFilter.length < 5) {
            profileController.RecommandationFilter.add(SubjectCode);
            print('Selected Filter Subject: $SubjectCode');
          } else {
            print('Cannot select more than 5 subjects');
          }
        },
        child: Text(
          Subject,
          style: TextStyle(
            color: isFilterSelected ? Color(0xFF3E6426) : Color(0xFF686868),
            fontWeight: isFilterSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    });
  }
}
