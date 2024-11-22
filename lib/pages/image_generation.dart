import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ImageGeneration extends StatefulWidget {
  const ImageGeneration({super.key});

  @override
  _ImageGenerationState createState() => _ImageGenerationState();
}

class _ImageGenerationState extends State<ImageGeneration> {
  Uint8List? imageBytes;
  bool isLoading = false;
  final TextEditingController _promptController = TextEditingController();

  // Function to send prompt and receive image from Hugging Face API
  Future<void> generateImage(String prompt) async {
    setState(() {
      isLoading = true;
      imageBytes = null;
    });

    const String apiUrl =
        "https://api-inference.huggingface.co/models/CompVis/stable-diffusion-v1-4";
    const String apiKey =
        "Bearer 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"; // Your Hugging Face API key

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": apiKey,
          "Content-Type": "application/json",
        },
        body: jsonEncode({"inputs": prompt}),
      );

      if (response.statusCode == 200) {
        setState(() {
          imageBytes = response.bodyBytes;
          isLoading = false;
        });
      } else if (response.statusCode == 503) {
        // Model is loading, show user a message and retry after a delay
        final errorMessage = jsonDecode(response.body);
        final estimatedTime = errorMessage['estimated_time'] ?? 60;
        print('Model is still loading. Retrying in ${estimatedTime} seconds.');

        await Future.delayed(Duration(seconds: estimatedTime.toInt()));
        await generateImage(prompt); // Retry after the delay
      } else {
        setState(() {
          isLoading = false;
        });
        print(
            'Error generating image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Exception: $e');
    }
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
              'Image Generation Model',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Allow scrolling
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Input text box for the prompt
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _promptController,
                    decoration: const InputDecoration(
                      labelText: 'Enter a prompt',
                      border: InputBorder.none,
                      hintText: 'e.g. A beautiful sunset',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Generate button
              ElevatedButton(
                onPressed: () => generateImage(_promptController.text),
                child: const Text(
                  'Generate Image',
                  style: TextStyle(color: Colors.black87),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 20),

              // Show loading indicator when generating image
              if (isLoading)
                const SpinKitCircle(color: Colors.deepPurple, size: 50),

              // Display the generated image
              if (imageBytes != null)
                Column(
                  children: [
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          imageBytes!,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Uncomment this part if you implement save functionality
                    // ElevatedButton(
                    //   onPressed: saveImageToPhone,
                    //   child: const Text('Save to Phone'),
                    // ),
                  ],
                )
              else if (!isLoading)
                const Text(
                  'Press the button to generate an image',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
