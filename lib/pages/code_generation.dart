import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CodeGeneration extends StatefulWidget {
  const CodeGeneration({super.key});

  @override
  State<CodeGeneration> createState() => _CodeGenerationState();
}

class _CodeGenerationState extends State<CodeGeneration> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
// To store the generated code
  bool _isLoading = false;
  File? _pickedImage;
  String mytext = '';
  bool scanning = false;

  final ImagePicker _imagePicker = ImagePicker();
  final apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyDi8IrfXg7TGGf18BGul9YVZ0ssp9QRtZc'; // Replace with actual API key
  final header = {
    'Content-Type': 'application/json',
  };

  // Function to pick image
  Future<void> _pickImage() async {
    final result = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      setState(() {
        _pickedImage = File(result.path);
      });
    }
  }

  // Function to remove the selected image
  void _removeImage() {
    setState(() {
      _pickedImage = null;
    });
  }

  // Function to generate code using Gemini API
  Future<void> _generateCode() async {
    if (_controller.text.isEmpty && _pickedImage == null) {
      return; // Return if the input is empty
    }

    setState(() {
      _isLoading = true;
      mytext = '';
    });

    try {
      // Prepare the prompt
      String prompt = _controller.text.isNotEmpty
          ? "Generate only the code without any explanation or instructions for: ${_controller.text}"
          : "if user proving any image Give Output of code after running the code from the provided image without any explanation or instructions.";

      // Prepare the data for API request
      List<int> imageBytes = _pickedImage != null
          ? File(_pickedImage!.path).readAsBytesSync()
          : [];
      String base64File =
          imageBytes.isNotEmpty ? base64.encode(imageBytes) : '';

      final data = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              if (_pickedImage != null)
                {
                  "inlineData": {
                    "mimeType": "image/jpeg",
                    "data": base64File,
                  }
                }
            ]
          }
        ],
      };

      // Send request to Gemini API
      final response = await http.post(Uri.parse(apiUrl),
          headers: header, body: jsonEncode(data));

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        setState(() {
          mytext = result['candidates'][0]['content']['parts'][0]['text'];
        });
      } else {
        setState(() {
          mytext = 'Response status: ${response.statusCode}, ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        mytext = 'Error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    // Clear the input field after generating the code
    _controller.clear();
  }

  // Function to copy generated code to clipboard
  void _copyToClipboard() {
    if (mytext.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: mytext));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code copied to clipboard!'),
        ),
      );
    }
  }

  // Function to scroll to the bottom of the code display
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Center(
            child: Text(
              'Code Generation Model',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Show the selected image if available
            if (_pickedImage != null)
              Container(
                margin: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    Image.file(
                      _pickedImage!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        onPressed: _removeImage,
                      ),
                    ),
                  ],
                ),
              ),

            // Show the code output area only if generated code is available
            if (mytext.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade800, width: 2),
                  ),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        controller: _scrollController,
                        child: SelectableText(
                          mytext,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        child: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: _copyToClipboard,
                          tooltip: 'Copy to Clipboard',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Show message when no image or code has been generated yet
            if (_pickedImage == null && mytext.isEmpty && !_isLoading)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'No code generated yet. Provide instructions to generate code.',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(
                height: 16), // Add some spacing before the input field

            // Loading spinner in the center if loading is true
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Instruction input field for generating code
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type your code generation instruction...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 15,
                  ),
                ),
              ),
            ),

            // Image picker button next to the send button
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: _pickImage,
              tooltip: 'Upload Image',
            ),

            // Send button
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _generateCode,
              tooltip: 'Generate Code',
            ),
          ],
        ),
      ),
    );
  }
}
