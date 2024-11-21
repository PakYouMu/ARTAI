import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class PredictionService {
  static const String baseUrl = 'http://192.168.0.120:6969';

  Future<Map<String, dynamic>> getPredictions(File imageFile) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));

      // Add the image file to the request
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        var errorData = json.decode(responseData);
        throw Exception(errorData['error'] ??
            'Failed to get predictions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting predictions: $e');
    }
  }
}
