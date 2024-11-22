import 'package:first_app/pages/upgradetopremium.dart';
import 'package:flutter/material.dart';
import 'chat_with_document.dart';
import 'video_generation.dart';
import 'image_generation.dart';
import 'audio_generation.dart';
import 'code_generation.dart';
import 'text_generation.dart';
import '../widgets/model_card.dart';

class SynthAIHome extends StatefulWidget {
  const SynthAIHome({super.key});

  @override
  _SynthAIHomeState createState() => _SynthAIHomeState();
}

class _SynthAIHomeState extends State<SynthAIHome> {
  int _selectedIndex = 0;

  // No longer initializing _pages here

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the pages list inside the build method
    final List<Widget> _pages = [
      HomePage(onModelSelected: _onItemTapped), // Pass _onItemTapped callback
      ChatGeneration(),
      VideoGeneration(),
      ImageGeneration(),
      AudioGeneration(),
      CodeGeneration(),
      ChatWithDocument(),
      UpgradeToPremiumPage(), // Add Premium Page here
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SynthAI Suite'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 252, 252, 252),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  'SynthAI Suite',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildDrawerItem('Home', Icons.home, 0),
            _buildDrawerItem('Text Generation', Icons.text_fields, 1),
            _buildDrawerItem('Video Generation', Icons.videocam, 7),
            _buildDrawerItem('Image Generation', Icons.image, 3),
            _buildDrawerItem('Audio Generation', Icons.audiotrack, 7),
            _buildDrawerItem('Code Generation', Icons.code, 5),
            _buildDrawerItem('Chat with Document', Icons.chat, 6),
            const Divider(),
            _buildDrawerItem('Upgrade to Premium', Icons.star, 7),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex], // Use _selectedIndex to switch pages
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context); // Close drawer after tap
      },
    );
  }
}

class HomePage extends StatelessWidget {
  final Function(int) onModelSelected; // Accept a callback to switch pages

  const HomePage({super.key, required this.onModelSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        children: <Widget>[
          ModelCard('Text Generation', Icons.text_fields, const Color(0xEA4335),
              () {
            onModelSelected(1); // Use _onItemTapped for Text Generation
          }),
          ModelCard('Video Generation', Icons.videocam, Color(0xFBBC05), () {
            onModelSelected(7); // Use _onItemTapped for Video Generation
          }),
          ModelCard(
              'Image Generation', Icons.image, Color.fromARGB(0, 151, 29, 120),
              () {
            onModelSelected(3); // Use _onItemTapped for Image Generation
          }),
          ModelCard('Audio Generation', Icons.audiotrack,
              Color.fromARGB(0, 29, 147, 151), () {
            onModelSelected(7); // Use _onItemTapped for Audio Generation
          }),
          ModelCard('Code Generation', Icons.code, Color(0x4285F4), () {
            onModelSelected(5); // Use _onItemTapped for Code Generation
          }),
          ModelCard('Chat with Doc', Icons.chat, const Color(0x34A853), () {
            onModelSelected(6); // Use _onItemTapped for Chat with Document
          }),
        ],
      ),
    );
  }
}
