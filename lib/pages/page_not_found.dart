import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PageNotFoundPage extends StatelessWidget {
  const PageNotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '404 - Page not found',
          style: GoogleFonts.montserratAlternates(
              fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
