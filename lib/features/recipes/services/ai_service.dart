import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/constants/api_constants.dart';

class AiService {
  static Future<Map<String, dynamic>?> analyzeRecipeFromImage(File imageFile) async {
    try {
      final apiKey = ApiConstants.GEMINI_API_KEY;
      if (apiKey == 'AIzaSyA0OQKEmrksTeN7nqENWgA-doTaAjyGCLo' || apiKey.isEmpty) {
        throw Exception('API Key Gemini belum diatur di ApiConstants');
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      final imageBytes = await imageFile.readAsBytes();
      
      final prompt = '''
        Analisa gambar makanan ini dengan cermat. 
        Tebak nama makanannya, deskripsinya, kalori per porsi, protein (g), lemak (g), karbo (g), dan bahan-bahannya.
        Jawab HANYA menggunakan format JSON seperti di bawah ini, tanpa teks tambahan di luar JSON:
        {
          "title": "Nama Makanan",
          "description": "Deskripsi singkat dan lezat 1-2 kalimat",
          "calories": 350,
          "protein": 15,
          "fat": 10,
          "carbs": 40,
          "ingredients": [
            "Bahan 1",
            "Bahan 2"
          ]
        }
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      final text = response.text;
      
      if (text != null) {
        // Hapus backticks markdown untuk berjaga-jaga jika AI mengembalikannya
        final cleanedText = text.replaceAll('```json', '').replaceAll('```', '').trim();
        return jsonDecode(cleanedText);
      }
      return null;
    } catch (e) {
      print('Error AI Analysis: \$e');
      rethrow;
    }
  }
}
