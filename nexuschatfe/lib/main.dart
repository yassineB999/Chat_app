import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nexuschatfe/app.dart';
import 'package:nexuschatfe/config/di/app_providers.dart';
import 'package:nexuschatfe/features/auth/domain/repository/google_auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await GoogleAuthRepository.initialize();

  await initializeDependencies();

  runApp(const NexusChatApp());
}
