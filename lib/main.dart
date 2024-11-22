import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(SynthAISuite());
}

class SynthAISuite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SynthAI Suite',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.copyWith(
                displayLarge:
                    const TextStyle(fontSize: 24), // Updated from headline1
                headlineSmall:
                    const TextStyle(fontSize: 20), // Updated from headline6
                bodyLarge:
                    const TextStyle(fontSize: 14), // Updated from bodyText1
                bodyMedium:
                    const TextStyle(fontSize: 12), // Updated from bodyText2
              ),
        ),
      ),
      home: const SynthAIHome(),
    );
  }
}
