import 'package:flutter/material.dart';

class DesktopTwoColumns extends StatelessWidget {
  final Widget left;
  final Widget right;
  const DesktopTwoColumns({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 11, child: left),
          const SizedBox(width: 16),
          Expanded(flex: 9, child: right),
        ],
      ),
    );
  }
}
