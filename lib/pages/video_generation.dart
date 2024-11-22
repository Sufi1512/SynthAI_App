import 'package:flutter/material.dart';

class VideoGeneration extends StatelessWidget {
  const VideoGeneration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Generation'),
      ),
      body: const Center(
        child: Text('Video Generation Model UI'),
      ),
    );
  }
}
