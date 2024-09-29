import 'package:flutter/material.dart';
import '/Model/Memo_SQFlight_Model.dart';
import '/Pages/Memo_Page/Memo_Edit_Page.dart';

class MemoMainPage extends StatefulWidget {
  final String dbName;

  MemoMainPage({required this.dbName});

  @override
  _MemoMainPageState createState() => _MemoMainPageState();
}

class _MemoMainPageState extends State<MemoMainPage> {
  late Future<List<Map<String, dynamic>>> _memos;

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    setState(() {
      _memos = MemoDatabase.instance.readAllMemos();
    });
  }

  Future<void> _deleteMemo(int id) async {
    await MemoDatabase.instance.deleteMemo(id);
    _loadMemos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memo Main Page', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF75502B), // AppBar 색상 변경
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _memos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final memos = snapshot.data;

            return ListView.builder(
              itemCount: memos?.length,
              itemBuilder: (context, index) {
                final memo = memos![index];

                return Column(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(
                            builder: (context) =>
                                MemoEditPage(memoId: memo['id']),
                          ))
                          .then((_) => _loadMemos()), // 메모 편집 후 메모 목록 새로고침
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        child: Row(
                          children: [
                            SizedBox(width: 16),
                            Text(memo['title']),
                            Spacer(),
                            IconButton(
                              icon:
                                  Icon(Icons.delete, color: Color(0xFF686868)),
                              onPressed: () => _deleteMemo(memo['id']),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (context) => MemoEditPage(memoId: null),
            ))
            .then((_) => _loadMemos()), // 새 메모 추가 후 메모 목록 새로고침
        child: Icon(Icons.add),
      ),
      backgroundColor: Color(0xFFFDE599),
    );
  }
}
