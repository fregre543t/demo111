import 'package:flutter/foundation.dart';

class Environment {
  Environment._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080',
  );

  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: kIsWeb ? 'ws://localhost:8080/ws' : 'ws://10.0.2.2:8080/ws',
  );
}
