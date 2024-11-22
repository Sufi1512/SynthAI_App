// ignore: unused_import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard functionality
import '../services/api_service.dart'; // Import the API service

class ChatGeneration extends StatefulWidget {
  const ChatGeneration({super.key});

  @override
  _ChatGenerationState createState() => _ChatGenerationState();
}

class _ChatGenerationState extends State<ChatGeneration> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> _messages = []; // To store conversation history
  bool _isLoading = false;

  // Replace with your actual API key
  final String apiKey = 'AIzaSyDMuxmy8CrJFWwDPD5SDtMsHNx163QFtmg';
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService =
        ApiService(apiKey); // Initialize the API service with the API key
  }

  // Function to handle text generation from Gemini model
  Future<void> _generateResponse() async {
    if (_controller.text.isEmpty) {
      return; // Return if the input is empty
    }

    // Add user message to the conversation
    setState(() {
      _messages.add('You: ${_controller.text}');
      _isLoading = true; // Show loading spinner while waiting for response
    });

    try {
      // Generate response using the ApiService
      String response = await apiService.generateResponse(_controller.text);

      // Clean the response by removing special characters like * or **
      String cleanedResponse = _cleanResponse(response);

      // Add model's response to the conversation
      setState(() {
        _messages.add('Model: $cleanedResponse');
      });

      // Scroll to the bottom after new messages
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add('Model: Failed to generate response');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });

      // Clear the input field after sending the message
      _controller.clear();
    }
  }

  // Function to clean the response and remove unwanted characters
  String _cleanResponse(String response) {
    // Remove any '*' or '**' from the response
    return response.replaceAll(RegExp(r'\*+'), '');
  }

  // Function to scroll to the bottom of the chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Function to copy text to clipboard
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Center(
            child: Text(
              'Text Genration Model',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isUserMessage = _messages[index].startsWith('You:');
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 15),
                      decoration: BoxDecoration(
                        color: isUserMessage
                            ? const Color.fromARGB(255, 194, 232, 235)
                            : const Color.fromARGB(255, 221, 207, 207),
                        borderRadius: isUserMessage
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(1),
                              ) // Rounded corners for user text
                            : const BorderRadius.only(
                                topLeft: Radius.circular(1),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                        boxShadow: isUserMessage
                            ? [
                                const BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(2, 2),
                                  blurRadius: 5,
                                ),
                              ]
                            : [
                                const BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(2, 2),
                                  blurRadius: 5,
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Copy to Clipboard icon at the top-right (for model messages only)
                          if (!isUserMessage)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Model:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18),
                                  onPressed: () =>
                                      _copyToClipboard(_messages[index]),
                                  tooltip: 'Copy to clipboard',
                                ),
                              ],
                            ),
                          if (!isUserMessage)
                            Divider(
                                color: Colors.grey.shade300,
                                height: 1), // Border line
                          const SizedBox(height: 8),
                          // Message content below the border
                          SelectableText(
                            _messages[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your question...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _generateResponse,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
