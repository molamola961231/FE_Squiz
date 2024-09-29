import 'package:flutter/material.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;

  DefaultAppBar({this.title = '', this.backgroundColor = const Color(0xFF6BA16A)});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor,
      flexibleSpace: Container(
        margin: EdgeInsets.only(top: 20.0),
        child: Image.asset('images/Logo_AppBar.png', fit: BoxFit.fitHeight),
      ),
      centerTitle: true,

    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
