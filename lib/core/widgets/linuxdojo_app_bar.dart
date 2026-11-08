import 'package:flutter/material.dart';

class LinuxDojoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LinuxDojoAppBar({
    required this.title,
    this.icon,
    this.iconWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    super.key,
  }) : assert(icon == null || iconWidget == null);

  final String title;
  final IconData? icon;
  final Widget? iconWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      title: Row(
        children: [
          if (icon != null || iconWidget != null) ...[
            if (iconWidget case final iconWidget?)
              SizedBox(width: 30, height: 30, child: iconWidget)
            else
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: theme.colorScheme.primary),
              ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: theme.colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
