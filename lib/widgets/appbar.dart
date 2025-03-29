import 'package:flutter/material.dart';
import 'styled_text.dart';

class Bar extends StatelessWidget implements PreferredSizeWidget {
  const Bar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:  Colors.white,
      elevation: 10,
      title: StyledText(25, "Chatbot", Colors.black87,weight:FontWeight.w700) ,
       
      // centerTitle: true,
      // leading: Padding(
      //   padding: const EdgeInsets.all(15.0),
      //   child: Image.asset(
      //     'assets/images/logo.jpeg', // Replace with your logo path
      //     fit: BoxFit.contain,

      //   ),
      // ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/jojo.jpg'), // Replace with user image
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
