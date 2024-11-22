import 'package:google_generative_ai/google_generative_ai.dart';

class ApiService {
  final String apiKey;

  ApiService(this.apiKey);

  // Function to inject guidance into the user's prompt
  String injectPromptGuidance(String userPrompt) {
    // Instruction to guide the model toward text-only responses
    const String guidance = """
I am a text-based AI model, and I can only generate purely text-based content. 
Please avoid requests for code, audio, video, or images. Focus on text generation tasks like writing, answering questions, storytelling, and content creation.
and genrate text in 100-150 word only.
""";
    // Combine the guidance with the user's prompt
    return "$guidance\n\nUser Request: $userPrompt";
  }

  // Function to call the API and generate a response
  Future<String> generateResponse(String userPrompt) async {
    // Inject the prompt guidance into the user's request
    String guidedPrompt = injectPromptGuidance(userPrompt);

    try {
      // Initialize the GenerativeModel with the correct model and API key
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 1,
          topK: 64,
          topP: 0.95,
          maxOutputTokens: 8192,
          responseMimeType: 'text/plain',
        ),
      );

      final chat = model.startChat(history: []);
      final content = Content.text(guidedPrompt);

      // Send message and await response
      final response = await chat.sendMessage(content);

      // Return the generated response from the model
      return response.text ?? 'No response from model';
    } catch (e) {
      print("Error generating response: $e"); // Log error details
      return 'Failed to generate response';
    }
  }
}
