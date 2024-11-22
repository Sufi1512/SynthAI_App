import 'package:flutter/material.dart';
import 'dart:math' as math; // Import for perspective transformation

class ModelCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ModelCard(this.title, this.icon, this.color, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform(
        // Adding a slight perspective effect
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective depth
          ..rotateX(-0.05) // Slight tilt in X axis
          ..rotateY(0.05), // Slight tilt in Y axis
        alignment: FractionalOffset.center,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              // Shadow on the bottom-right to simulate the popping effect
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(10, 10),
                blurRadius: 20,
                spreadRadius: 1,
              ),
              // Highlight on the top-left to simulate lighting
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                offset: const Offset(-5, -5),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 10, // Keeps the card raised slightly
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.9),
                    color.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform(
                      transform: Matrix4.rotationZ(-math.pi /
                          12), // Slight rotation to the icon for extra pop
                      alignment: FractionalOffset.center,
                      child: Icon(icon, size: 50, color: Colors.black45),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
