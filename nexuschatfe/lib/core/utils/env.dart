import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiBaseUrl =>
      dotenv.env['API_URL'] ?? 'http://localhost:8000/api';

  static String get pusherAppKey =>
      dotenv.env['PUSHER_APP_KEY'] ?? 'c34b2fdf4a2cc2627a00';

  static String get pusherAppCluster =>
      dotenv.env['PUSHER_APP_CLUSTER'] ?? 'eu';
}
