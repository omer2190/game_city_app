import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.trailing,
  });
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          if (leading != null) leading! else const SizedBox(width: 48),
          const Spacer(),
          if (titleWidget != null)
            Expanded(flex: 8, child: titleWidget!)
          else if (title != null)
            Expanded(
              flex: 8,
              child: Text(
                title!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          const Spacer(),
          if (trailing != null) trailing! else const SizedBox(width: 48),
        ],
      ),
    );
  }
}
