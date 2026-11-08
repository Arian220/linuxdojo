import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LinuxDojoApp(),
    ),
  );
}
