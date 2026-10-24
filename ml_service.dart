import 'dart:convert';
import 'package:http/http.dart' as http;

/// Talks to the pretrained-model server in 04-ml-service.
/// Android emulator -> your PC is 10.0.2.2. Real phone -> your PC's LAN IP:
///   flutter run --dart-define=ML_URL=http://192.168.1.5:8000
class MlService {
  static const baseUrl =
      String.fromEnvironment('ML_URL', defaultValue: 'http://10.0.2.2:8000');

  Future<Map<String, dynamic>> analyze(String text) async {
    final res = await http
        .post(Uri.parse('$baseUrl/intent'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text}))
        .timeout(const Duration(seconds: 4));
    if (res.statusCode != 200) throw Exception('ML ${res.statusCode}');
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }
}
