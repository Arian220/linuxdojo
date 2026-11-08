import 'package:flutter/material.dart';
import 'package:linuxdojo/app/app_gate.dart';
import 'package:linuxdojo/core/theme/app_theme.dart';

class LinuxDojoApp extends StatelessWidget {
  const LinuxDojoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linux Dojo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const AppGate(),
    );
  }
}
