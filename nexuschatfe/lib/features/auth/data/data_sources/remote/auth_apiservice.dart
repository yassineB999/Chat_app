import 'package:dio/dio.dart';

abstract class AuthApiservice {
  Future<Response> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Response> login({required String email, required String password});

  Future<Response> loginWithGoogleToken({required String accessToken});

  Future<Response> logout({required String token});
}
