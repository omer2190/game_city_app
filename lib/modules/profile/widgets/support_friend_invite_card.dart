import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/widgets/widgets.dart';

class SupportFriendInviteCard extends StatefulWidget {
  final bool hasJoined;
  final String? joinedCode;
  final String? friendName;
  final int teamCount;
  final bool isJoining;
  final bool isTeamLoading;
  final Future<bool> Function(String code) onJoin;
  final VoidCallback onViewTeam;

  const SupportFriendInviteCard({
    super.key,
    required this.hasJoined,
    this.joinedCode,
    this.friendName,
    this.teamCount = 0,
    this.isJoining = false,
    this.isTeamLoading = false,
    required this.onJoin,
    required this.onViewTeam,
  });

  @override
  State<SupportFriendInviteCard> createState() =>
      _SupportFriendInviteCardState();
}

class _SupportFriendInviteCardState extends State<SupportFriendInviteCard> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isValidating = false;
  bool _isCodeValid = false;
  Timer? _debounce;

  bool get _isJoined => widget.hasJoined;

  @override
  void dispose() {
    _debounce?.cancel();
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _validate(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty || trimmed.length < 3) {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _isCodeValid = false;
        });
      }
      return;
    }
    setState(() => _isValidating = true);
    // Simple length validation for instant UX feedback —
    // the actual server validation happens on join.
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _isValidating = false;
        _isCodeValid = trimmed.length >= 4;
      });
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _validate(value),
    );
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    await widget.onJoin(code);
    // Widget rebuilds automatically because hasJoined changes reactively
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: _isJoined ? _buildJoinedState(cs, theme) : _buildInputState(cs),
      ),
    );
  }

  // ───────────────────── State A: input ─────────────────────

  Widget _buildInputState(ColorScheme cs) {
    return Column(
      key: const ValueKey('input'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(cs, Icons.group_add_rounded, 'انضم إلى فريق صديق'),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Text(
            'أدخل كود الدعوة للانضمام إلى فريق صديقك',
            style: TextStyle(
              color: cs.onSurfaceVariant.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Input row
        Row(
          children: [
            // Input
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isCodeValid
                        ? Colors.green.withOpacity(0.4)
                        : cs.onSurface.withOpacity(0.08),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(
                      Icons.card_giftcard_outlined,
                      size: 20,
                      color: cs.primary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        focusNode: _focusNode,
                        onChanged: _onChanged,
                        onSubmitted: (_) => _isCodeValid ? _submit() : null,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'aB3xK9',
                          hintStyle: TextStyle(
                            color: cs.onSurfaceVariant.withOpacity(0.35),
                            fontSize: 16,
                            letterSpacing: 1.5,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_isValidating)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(cs.primary),
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Join button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: widget.isJoining ? null : () => _submit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: widget.isJoining
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'انضم',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // validation hint
        if (_isCodeValid)
          Padding(
            padding: const EdgeInsets.only(right: 4, top: 2),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text(
                  'الكود صالح — اضغط انضم للمتابعة',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ───────────────────── State B: joined ─────────────────────

  Widget _buildJoinedState(ColorScheme cs, ThemeData theme) {
    final displayName = widget.friendName ?? '';
    final displayCode = widget.joinedCode ?? '------';

    return Column(
      key: const ValueKey('joined'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with check
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName.isNotEmpty
                        ? 'أنت في فريق $displayName'
                        : 'أنت منضم إلى فريق',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Code display row
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primary.withOpacity(0.06),
                cs.primary.withOpacity(0.12),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.primary.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              // Code text
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.link_rounded,
                      size: 18,
                      color: cs.primary.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      displayCode,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),

              // View team button
              SizedBox(
                height: 34,
                child: OutlinedButton.icon(
                  onPressed: widget.onViewTeam,
                  icon: const Icon(Icons.group_rounded, size: 16),
                  label: Text(
                    widget.teamCount > 0
                        ? 'الفريق (${widget.teamCount})'
                        : 'الفريق',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(
                      color: cs.primary.withOpacity(0.4),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────── Shared header ─────────────────────

  Widget _buildHeader(ColorScheme cs, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: cs.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: cs.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
