import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthUserModel> login({
    required String email,
    required String password,
  });

  Future<AuthUserModel> register({
    required String name,
    required String email,
    required String password,
  });
}

final class DioAuthRemoteDataSource implements AuthRemoteDataSource {
  const DioAuthRemoteDataSource(this._client);

  final DioClient _client;

  @override
  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException('Empty login response');
    }

    return AuthUserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<AuthUserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException('Empty register response');
    }

    return AuthUserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}
