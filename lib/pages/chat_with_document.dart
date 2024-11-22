import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ChatWithDocument extends StatefulWidget {
  const ChatWithDocument({super.key});

  @override
  _ChatWithDocumentState createState() => _ChatWithDocumentState();
}

class _ChatWithDocumentState extends State<ChatWithDocument> {
  // Function to copy text to clipboard
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard!'),
        ),
      );
    });
  }

  File? _selectedFile;
  String? _uploadStatusMessage = '';
  bool _isUploading = false;
  String _queryResponse = '';
  String _extractedText = '';
  final TextEditingController _queryController = TextEditingController();
  final apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyDi8IrfXg7TGGf18BGul9YVZ0ssp9QRtZc'; // Replace with your Gemini API URL
  final header = {
    'Content-Type': 'application/json',
  };

  // Function to pick PDF file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  // Function to upload the PDF to the Gemini API
  Future<void> _uploadPDF() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadStatusMessage = ''; // Reset status message
    });

    try {
      // Convert PDF file to base64
      List<int> fileBytes = _selectedFile!.readAsBytesSync();
      String base64File = base64.encode(fileBytes);

      // Prepare the data for the API request
      final data = {
        "contents": [
          {
            "parts": [
              {"text": "Extract the text from the provided PDF file."},
              {
                "inlineData": {
                  "mimeType": "application/pdf",
                  "data": base64File,
                }
              }
            ]
          }
        ],
      };

      // Send request to the API
      http.Response apiResponse = await http.post(
        Uri.parse(apiUrl),
        headers: header,
        body: jsonEncode(data),
      );

      if (apiResponse.statusCode == 200) {
        var result = jsonDecode(apiResponse.body);
        setState(() {
          _uploadStatusMessage = 'PDF uploaded successfully.';
          _extractedText = result['candidates'][0]['content']['parts'][0]
              ['text']; // Example of text extraction
        });
      } else {
        setState(() {
          _uploadStatusMessage =
              'Error: ${apiResponse.statusCode} - ${apiResponse.body}';
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatusMessage = 'Error occurred: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Function to submit a query to the API
  Future<void> _submitQuery() async {
    if (_queryController.text.isEmpty) return;

    setState(() {
      _queryResponse = 'Processing your query...';
    });

    try {
      // Prepare data for query
      final data = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Based on the extracted document, answer the following query: ${_queryController.text}"
              },
              {
                "inlineData": {
                  "mimeType": "text/plain",
                  "data": base64.encode(utf8.encode(_extractedText)),
                }
              }
            ]
          }
        ],
      };

      // Send query request to the Gemini API
      http.Response apiResponse = await http.post(
        Uri.parse(apiUrl),
        headers: header,
        body: jsonEncode(data),
      );

      if (apiResponse.statusCode == 200) {
        var result = jsonDecode(apiResponse.body);
        setState(() {
          _queryResponse =
              result['candidates'][0]['content']['parts'][0]['text'];
        });
      } else {
        setState(() {
          _queryResponse =
              'Error: ${apiResponse.statusCode} - ${apiResponse.body}';
        });
      }
    } catch (e) {
      setState(() {
        _queryResponse = 'Error occurred: $e';
      });
    }
  }

  // Widget to preview the PDF
  Widget _buildPreviewPDF() {
    if (_selectedFile == null) return const SizedBox.shrink();

    return PDFView(
      filePath: _selectedFile!.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // Transparent AppBar background
        elevation: 0, // Remove AppBar shadow

        title: const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Center(
            child: Text(
              'Chat With Doc',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ), // Dark blue AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload PDF section
            Center(
              child: Column(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Upload your PDF',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                Color.fromARGB(255, 46, 45, 45), // White text
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.file_present,
                              color: Colors.white),
                          label: const Text(
                            'Select PDF',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            backgroundColor:
                                Color(0xFF3A8DAA), // Dark blue button
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                        if (_selectedFile != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Selected PDF: ${_selectedFile!.path.split('/').last}', // Display file name only
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // PDF Preview and Upload buttons
            if (_selectedFile != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: SizedBox(
                              width: double.infinity,
                              child: _buildPreviewPDF(),
                            ),
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Preview PDF',
                      style:
                          TextStyle(color: Color(0xFF3A8DAA)), // Dark blue text
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _uploadPDF,
                    child: const Text('Upload PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3A8DAA), // Dark blue button
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),

            // Uploading status
            if (_isUploading) const Center(child: CircularProgressIndicator()),
            if (_uploadStatusMessage!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _uploadStatusMessage!,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green), // Green status message
                ),
              ),
            const SizedBox(height: 20),

            // Query Section
            if (_extractedText.isNotEmpty) ...[
              const Divider(),
              const Text(
                'Ask a question based on the document:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _queryController,
                decoration: const InputDecoration(
                  labelText: 'Enter your question',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitQuery,
                child: const Text('Submit Query'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3A8DAA), // Dark blue submit button
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Query Response
            if (_queryResponse.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Response:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          _copyToClipboard(_queryResponse);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _queryResponse,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
