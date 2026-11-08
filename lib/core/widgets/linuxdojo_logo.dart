import 'package:flutter/widgets.dart';

class LinuxDojoLogo extends StatelessWidget {
  const LinuxDojoLogo({required this.size, super.key});

  static const assetPath =
      'assets/icons/iOS/AppIcon.appiconset/AppIcon-1024.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}
