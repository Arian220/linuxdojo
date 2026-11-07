import 'package:flutter/material.dart';
import 'package:linuxdojo/core/theme/app_theme.dart';
import 'package:linuxdojo/features/shell/presentation/app_shell.dart';

class LinuxDojoApp extends StatelessWidget {
  const LinuxDojoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinuxDojo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const AppShell(),
    );
  }
}
