import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiUrl = dotenv.env['apiUrl'].toString();

Future<http.Response> post(body) async {
  var response = await http.post(Uri.parse(apiUrl),body: body);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    print(response.body);
  } else {
    throw Exception('Failed to get');
  }

  return response;
}
