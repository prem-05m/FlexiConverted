import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/extensions/context_extensions.dart';

class AnimatedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const AnimatedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(
        title,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
      centerTitle: centerTitle,
      actions: actions != null
          ? [
              ...actions!.map((action) => action
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(delay: 100.ms))
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
