import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import '../helpers/constant.dart';
import 'api_interceptor.dart';

class ApiService {
  final http.Client client = InterceptedClient.build(
    interceptors: [ApiInterceptor()],
    retryPolicy: ExpiredTokenRetryPolicy(),
  );

  Future<String> getSecretArea() async {
    final response = await client.get(
      Uri.parse('${Constants.baseUrl}/secret'),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load secret area (Status: ${response.statusCode})');
    }
  }
}
