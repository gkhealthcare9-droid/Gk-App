import 'package:flutter/material.dart';

class CustomHeading extends StatelessWidget {
  final String heading;
  final String? subheading;
  final TextAlign textAlign;
  final Color headingColor;
  final Color subheadingColor;

  const CustomHeading({
    super.key,
    required this.heading,
    this.subheading,
    this.textAlign = TextAlign.start,
    this.headingColor = Colors.black,
    this.subheadingColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: _getCrossAlignment(),
      children: [
        Text(
          heading,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        if (subheading != null) ...[
          SizedBox(height: 4),
          Text(
            subheading!,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: 16,
              color: subheadingColor,
            ),
          ),
        ]
      ],
    );
  }

  CrossAxisAlignment _getCrossAlignment() {
    switch (textAlign) {
      case TextAlign.center:
        return CrossAxisAlignment.center;
      case TextAlign.right:
        return CrossAxisAlignment.end;
      case TextAlign.left:
      case TextAlign.start:
      default:
        return CrossAxisAlignment.start;
    }
  }
}
