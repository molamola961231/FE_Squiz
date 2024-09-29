import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategorySelectionWidget extends StatefulWidget {
  final String? SelectedCategory;
  final Function(String) onCategorySelected;
  final Function onClose;
  bool ShowCategory;

  CategorySelectionWidget({
    this.SelectedCategory,
    required this.onCategorySelected,
    required this.ShowCategory,
    required this.onClose,
  });

  @override
  _CategorySelectionWidgetState createState() => _CategorySelectionWidgetState();
}

class _CategorySelectionWidgetState extends State<CategorySelectionWidget> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.SelectedCategory;
  }

  void _onCategoryTap(String subjectCode) {
    setState(() {
      if (selectedCategory != subjectCode) {
        selectedCategory = subjectCode;
      } else {
        selectedCategory = null;
      }
      widget.onCategorySelected(selectedCategory ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.ShowCategory,
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
                      ' Category',
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
                          CategoryFilter(
                            Subject: 'Agricultural Studies',
                            SubjectCode: "AGRI",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'Architecture Design',
                            SubjectCode: "ARCH",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'Biological Sciences',
                            SubjectCode: "BIO_",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'Business Management',
                            SubjectCode: "BUSI",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'Computer Science',
                            SubjectCode: "COMP",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'Culinary and Cosmetic Services',
                            SubjectCode: "CULI",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          CategoryFilter(
                            Subject: 'Engineering',
                            SubjectCode: "ENGR",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'Health Professions and Medical Services',
                            SubjectCode: "HLTH",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'Humanities and Liberal Arts',
                            SubjectCode: "HUMN",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'Legal Studies',
                            SubjectCode: "LEGL",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'Mechanical and Electrical Repair',
                            SubjectCode: "MECH",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'Media Related Communication',
                            SubjectCode: "MEDI",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          CategoryFilter(
                            Subject: 'Physical Science',
                            SubjectCode: "PHYS",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'Psychology',
                            SubjectCode: "PSYC",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'School Administration',
                            SubjectCode: "SCHL",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'The Visual and Performing Arts',
                            SubjectCode: "ARTS",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'Transportation and Distribution Services',
                            SubjectCode: "TRAN",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
                          CategoryFilter(
                            Subject: 'ETC',
                            SubjectCode: "MISC",
                            SelectedCategory: selectedCategory,
                            onCategoryTap: _onCategoryTap,
                          ),
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

class CategoryFilter extends StatelessWidget {
  final String Subject;
  final String SubjectCode;
  final String? SelectedCategory;
  final Function(String) onCategoryTap;

  CategoryFilter({
    required this.Subject,
    required this.SubjectCode,
    required this.SelectedCategory,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        onCategoryTap(SubjectCode);
        print('Selected Category: $SubjectCode');
      },
      child: Text(
        Subject,
        style: TextStyle(
          color: SelectedCategory == SubjectCode
              ? Color(0xFF3E6426)
              : Color(0xFF686868),
          fontWeight: SelectedCategory == SubjectCode
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }
}
