import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    return await _apiClient.post<LoginResponse>(
      '/app-api/member/auth/login',
      request.toJson(),
      fromJson: (json) => LoginResponse.fromJson(json),
    );
  }

  Future<ApiResponse<RegisterResponse>> register(RegisterRequest request) async {
    return await _apiClient.post<RegisterResponse>(
      '/app-api/member/auth/register',
      request.toJson(),
      fromJson: (json) => RegisterResponse.fromJson(json),
    );
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    return await _apiClient.get<User>(
      '/app-api/member/user/get',
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<void>> logout() async {
    final response = await _apiClient.post<void>('/app-api/member/auth/logout', {});
    if (response.success) {
      await _apiClient.clearTokens();
    }
    return response;
  }

  Future<ApiResponse<LoginResponse>> refreshToken() async {
    return await _apiClient.post<LoginResponse>(
      '/app-api/member/auth/refresh-token',
      {},
      fromJson: (json) => LoginResponse.fromJson(json),
    );
  }

  bool get isLoggedIn => _apiClient.isLoggedIn;
}