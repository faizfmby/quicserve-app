import 'package:flutter/material.dart';

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(size.width, size.height); // Bottom Right Corner
    path.lineTo(size.width, 0); // Top Right Corner
    path.quadraticBezierTo(size.width - 0.5, size.height - 130, size.width - 50, size.height - 120);
    path.quadraticBezierTo(size.width - 93, size.height - 109, size.width - 92, size.height - 75);
    path.quadraticBezierTo(size.width - 93, size.height - 41, size.width - 50, size.height - 30);
    path.quadraticBezierTo(size.width - 0.5, size.height - 20, size.width, size.height);
    path.lineTo(size.width, size.height); // Bottom Right Corner
    // path.lineTo(0, size.height); // Bottom Left Corner
    // path.lineTo(0, 0); // Top Left Corner

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
