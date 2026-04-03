import 'package:http_interceptor/http_interceptor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth.dart';

class ApiInterceptor implements InterceptorContract {
  final storage = const FlutterSecureStorage();

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    String? token = await storage.read(key: 'access_token');
    if (token != null) {
      data.headers['Authorization'] = 'Bearer $token';
    }
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    if (data.statusCode == 401) {
      String? refreshToken = await storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        bool success = await AuthService().refreshToken(refreshToken);
        if (success) {
          // Token refreshed successfully, RetryPolicy will handle retrying the request
        }
      }
    }
    return data;
  }
}

class ExpiredTokenRetryPolicy extends RetryPolicy {
  @override
  int get maxRetryAttempts => 1;

  @override
  Future<bool> shouldAttemptRetryOnResponse(ResponseData response) async {
    if (response.statusCode == 401) {
      return true;
    }
    return false;
  }
}
