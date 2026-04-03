import 'package:flutter/material.dart';
import 'package:market_express/utils/app_colors.dart';

class ComprixAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final double elevation;

  const ComprixAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.bottom,
    this.elevation = 0,
  });

  static Text titleText(
    String text, {
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: Colors.white,
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      bottom: bottom,
      centerTitle: centerTitle,
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: elevation,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white, size: 24),
      actionsIconTheme: const IconThemeData(color: Colors.white, size: 24),
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      ),
    );
  }
}
