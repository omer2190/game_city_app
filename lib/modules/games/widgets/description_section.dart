import 'package:flutter/material.dart';
import 'package:game_city_app/data/models/game_model.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';

class DescriptionSection extends StatefulWidget {
  final Game game;

  const DescriptionSection({super.key, required this.game});

  @override
  State<DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<DescriptionSection> {
  static const int _minLines = 5;
  bool _expanded = false;
  bool _isOverflowing = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final text = widget.game.description ?? widget.game.rawgDescription;

    if (text == null || text.isEmpty) return const SizedBox.shrink();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'عن اللعبة',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              // Detect overflow using TextPainter
              if (!_expanded && !_isOverflowing && constraints.maxWidth > 0) {
                final style = TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.7,
                );
                final span = TextSpan(text: text, style: style);
                final tp = TextPainter(
                  text: span,
                  maxLines: _minLines,
                  textDirection: Directionality.of(context),
                )..layout(maxWidth: constraints.maxWidth);

                final overflows = tp.didExceedMaxLines;
                if (overflows != _isOverflowing) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _isOverflowing = overflows);
                  });
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    maxLines: _expanded ? null : _minLines,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 15,
                      height: 1.7,
                    ),
                  ),
                  if (_isOverflowing || _expanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: () =>
                              setState(() => _expanded = !_expanded),
                          icon: Icon(
                            _expanded ? Icons.expand_less : Icons.expand_more,
                            size: 18,
                          ),
                          label: Text(_expanded ? 'عرض أقل' : 'عرض المزيد'),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
