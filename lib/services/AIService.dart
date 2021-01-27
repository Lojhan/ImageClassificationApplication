import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> getPlantInfo(String imagePath) async {
  final baseUrl = '192.168.15.3:8000';
  var url = Uri.http(baseUrl, '/control');

  try {
    final response = await http.post(
      url,
      body: json.encode(
        {
          'image': base64Encode(File(imagePath).readAsBytesSync()),
        },
      ),
    );

    return response.headers['plant'];
  } catch (e) {
    print(e);
  }
}
