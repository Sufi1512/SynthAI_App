import 'package:flutter/material.dart';

class AudioGeneration extends StatelessWidget {
  const AudioGeneration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Generation'),
      ),
      body: const Center(
        child: Text('Audio Generation Model UI'),
      ),
    );
  }
}
