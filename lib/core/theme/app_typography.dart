import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const command = TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: ['Menlo', 'Courier New', 'Courier'],
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0.2,
  );

  static const commandLarge = TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: ['Menlo', 'Courier New', 'Courier'],
    fontSize: 18,
    height: 1.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}
