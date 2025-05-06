import 'package:flutter/material.dart';

class TitleParagraph extends StatelessWidget {
  final String title;
  final String paragraph;

  const TitleParagraph({
    super.key,
    required this.title,
    required this.paragraph,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(paragraph, style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),),
        ],
      ),
    );
  }
}
