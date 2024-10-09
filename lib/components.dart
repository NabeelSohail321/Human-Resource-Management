import 'package:flutter/material.dart';

class CustomTextStyles {
  static const TextStyle customTextStyle = TextStyle(
      fontFamily: 'Lora',
      fontSize: 18,
      color: Colors.black
  );
}

class CustomAppBar {
  static AppBar customAppBar(String title) {
    return AppBar(
      backgroundColor:const Color(0xFFDEE5D4),
      title: Text(
        title,
        style: customTextStyle,
      ),
      centerTitle: true,
    );
  }

  static  TextStyle customTextStyle = const TextStyle(
    fontFamily: 'Lora',
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
}

class NewCustomTextStyles {
  static const TextStyle newcustomTextStyle = TextStyle(
      fontFamily: 'Lora',
      fontSize: 25,
      color: Colors.white,
    fontWeight: FontWeight.bold,
  );
}
