import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/services/auth_service.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize();

  // If no PIN set, start authenticated (no lock screen needed)
  final hasPin = await AuthService.instance.hasPin();

  runApp(
    ProviderScope(
      overrides: [
        isAuthenticatedProvider.overrideWith((ref) => !hasPin),
      ],
      child: const ArrivalDaysApp(),
    ),
  );
}
