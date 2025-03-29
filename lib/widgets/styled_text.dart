import 'package:flutter/material.dart';

class StyledText extends StatelessWidget{
  const StyledText(this.font,this.text,this.color,{this.weight=FontWeight.w400,super.key});
  final String text ;
  final double font;
  final Color color;
  final FontWeight weight;

  @override
  Widget build(context) {
     return  Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: font,
            fontWeight: weight,
          ),
          
        );
  }
}