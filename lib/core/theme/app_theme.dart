import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linuxdojo/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceDim: AppColors.surfaceDim,
      surfaceBright: AppColors.surfaceBright,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.onInverseSurface,
      inversePrimary: AppColors.inversePrimary,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryContainer,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return base.textTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.onPrimary
              : AppColors.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.outline;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceContainerHighest,
        circularTrackColor: AppColors.surfaceContainerHighest,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.onSurface,
        displayColor: AppColors.onSurface,
      ),
    );
  }
}
