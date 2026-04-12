import 'package:flutter/material.dart';

/// Custom clipper yang membuat efek wave/gelombang pada background.
/// Digunakan di Landing Page 3 untuk background gradient biru.
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.55);

    var firstControlPoint = Offset(size.width * 0.25, size.height * 0.65);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.52);

    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.38);
    var secondEndPoint = Offset(size.width, size.height * 0.45);

    path.quadraticBezierTo(
      firstControlPoint.dx, firstControlPoint.dy,
      firstEndPoint.dx, firstEndPoint.dy,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx, secondControlPoint.dy,
      secondEndPoint.dx, secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
