import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '/Model/Memo_SQFlight_Model.dart';

class MemoEditPage extends StatefulWidget {
  final int? memoId;

  MemoEditPage({this.memoId});

  @override
  _MemoEditPageState createState() => _MemoEditPageState();
}

class _MemoEditPageState extends State<MemoEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _content;

  @override
  void initState() {
    super.initState();
    if (widget.memoId != null) {
      _loadMemo();
    } else {
      _title = '';
      _content = '';
    }
  }

  Future<void> _loadMemo() async {
    final memo = await MemoDatabase.instance.readMemo(widget.memoId!);
    if (memo != null) {
      setState(() {
        _title = memo['title'];
        _content = memo['content'];
      });
    }
  }

  Future<void> _saveMemo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_title.isEmpty) {
        _showEmptyTitleDialog();
        return;
      }

      if (widget.memoId == null) {
        await MemoDatabase.instance.createMemo(_title, _content);
      } else {
        await MemoDatabase.instance
            .updateMemo(widget.memoId!, _title, _content);
      }

      Navigator.of(context).pop();
    }
  }

  void _showEmptyTitleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Title is Empty'),
          content: Text('Please enter a title.'),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.memoId == null ? 'New Memo' : 'Edit Memo',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.save, color: Colors.white), onPressed: _saveMemo)
        ],
        backgroundColor: Color(0xFF75502B), // AppBar 색상 변경
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: _title,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _title = value!;
                  },
                ),
                SizedBox(height: 30),
                TextFormField(
                  initialValue: _content,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    border: InputBorder.none, // 밑줄 제거
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some content';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _content = value!;
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFFFDE599),
    );
  }
}
