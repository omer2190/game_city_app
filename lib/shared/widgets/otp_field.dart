import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/values/app_colors.dart';

/// A professional OTP input field with multiple boxes.
///
/// Features:
/// - Auto-advance to the next box when typing
/// - Backspace moves to the previous box
/// - Paste support (full code)
/// - Auto-submit callback when the code is complete
class OtpField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool obscure;
  final double boxSize;
  final double spacing;

  const OtpField({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.obscure = false,
    this.boxSize = 48,
    this.spacing = 10,
  });

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _handleChanged(int index, String value) {
    // Only keep the last character if multiple were pasted
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    _controllers[index].text = value;

    if (value.isNotEmpty && index < widget.length - 1) {
      // Defer the focus request to after the current frame, otherwise
      // it can be ignored while the text input connection is updating
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNodes[index + 1].requestFocus();
        }
      });
    }

    widget.onChanged?.call(_code);

    if (_code.length == widget.length) {
      widget.onCompleted?.call(_code);
    }
  }

  void _handlePaste(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;

    for (var i = 0; i < widget.length; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }

    final nextIndex = digits.length < widget.length
        ? digits.length
        : widget.length - 1;
    _focusNodes[nextIndex].requestFocus();

    widget.onChanged?.call(_code);

    if (_code.length == widget.length) {
      widget.onCompleted?.call(_code);
    }
  }

  void _handleBackspace(int index) {
    if (_controllers[index].text.isNotEmpty) {
      _controllers[index].clear();
    } else if (index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
    widget.onChanged?.call(_code);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Each box takes (boxSize + spacing) because of the padding on
        // both sides, so the total width is: length * boxSize + length * spacing
        final totalSpacing = widget.spacing * widget.length;
        final maxBoxSize = constraints.maxWidth.isFinite
            ? (constraints.maxWidth - totalSpacing) / widget.length
            : widget.boxSize;
        final boxSize = maxBoxSize < widget.boxSize
            ? maxBoxSize
            : widget.boxSize;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: SizedBox(
                width: boxSize,
                height: boxSize,
                child: Focus(
                  onKeyEvent: (node, event) {
                    // When the current box is empty, backspace moves to
                    // the previous box and clears it
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.backspace &&
                        _controllers[index].text.isEmpty) {
                      _handleBackspace(index);
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    obscureText: widget.obscure,
                    obscuringCharacter: '•',
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSecondary,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: colorScheme.secondary,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.secondaryLight2,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.secondaryLight2,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => _handleChanged(index, value),
                    onTapOutside: (_) => _focusNodes[index].unfocus(),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
