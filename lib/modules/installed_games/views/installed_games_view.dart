import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_breakpoints.dart';
import '../../../data/models/installed_game_model.dart';
import '../../../shared/header.dart';
import '../../../shared/layout_mine.dart';
import '../../../shared/widgets/widgets.dart';
import '../controllers/installed_games_controller.dart';

/// Lets the user scan the device (Android/Windows) for installed games,
/// then sync selected games to their "العب الآن" library.
///
/// Flow per game: search it in the system first, then add to "العب الآن".
///
/// Two layouts are provided:
/// - Desktop / wide screens: toolbar + info bar + grid of game cards
///   with a sticky bottom sync bar.
/// - Mobile: scan card + vertical list.
class InstalledGamesView extends StatelessWidget {
  InstalledGamesView({super.key});

  final InstalledGamesController controller = Get.put(
    InstalledGamesController(),
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= AppBreakpoints.tabletBreakpoint;

    return isDesktop
        ? _InstalledGamesDesktop(controller: controller)
        : _InstalledGamesMobile(controller: controller);
  }
}

// ════════════════════════════════════════════════════════════════════════
// Shared widgets (used by both layouts)
// ════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videogame_asset_off,
            size: 80,
            color: colorScheme.onSurface.withOpacity(0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'لم يتم فحص الجهاز بعد',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'اضغط على "فحص الجهاز" لاكتشاف الألعاب المثبتة على أندرويد أو ويندوز.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.35),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _sourceIcon(InstalledGameModel game) {
  switch (game.source) {
    case 'android':
      return Icons.android;
    case 'steam':
      return Icons.sports_esports;
    case 'epic':
      return Icons.storefront;
    default:
      return Icons.desktop_windows;
  }
}

class _GameIcon extends StatelessWidget {
  const _GameIcon({required this.game, this.size = 44});

  final InstalledGameModel game;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Uint8List? iconBytes = game.icon;

    final Widget content = (iconBytes != null && iconBytes.isNotEmpty)
        ? Image.memory(
            iconBytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => _fallback(colorScheme),
          )
        : _fallback(colorScheme);

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: content,
    );
  }

  Widget _fallback(ColorScheme colorScheme) {
    return Container(
      width: size,
      height: size,
      color: colorScheme.primary.withOpacity(0.1),
      child: Icon(
        _sourceIcon(game),
        color: colorScheme.primary,
        size: size * 0.55,
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.game});

  final InstalledGameModel game;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        game.sourceLabel,
        style: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

(String, Color, IconData) _statusInfo(InstalledGameSyncStatus status) {
  return switch (status) {
    InstalledGameSyncStatus.syncing => (
      'جاري البحث...',
      Colors.blueAccent,
      Icons.hourglass_top,
    ),
    InstalledGameSyncStatus.added => (
      'تمت الإضافة',
      Colors.green,
      Icons.check_circle,
    ),
    InstalledGameSyncStatus.already => (
      'موجودة مسبقاً',
      Colors.teal,
      Icons.check_circle_outline,
    ),
    InstalledGameSyncStatus.queued => (
      'قيد البحث المتقدم',
      Colors.amber,
      Icons.manage_search,
    ),
    InstalledGameSyncStatus.notFound => (
      'غير موجودة',
      Colors.redAccent,
      Icons.search_off,
    ),
    InstalledGameSyncStatus.error => (
      'فشل المزامنة',
      Colors.redAccent,
      Icons.error_outline,
    ),
    InstalledGameSyncStatus.idle => ('', Colors.transparent, Icons.circle),
  };
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final InstalledGameSyncStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _statusInfo(status);
    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Desktop / large-screen layout
// ════════════════════════════════════════════════════════════════════════

class _InstalledGamesDesktop extends StatelessWidget {
  const _InstalledGamesDesktop({required this.controller});

  final InstalledGamesController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutMine(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildToolbar(context),
          const SizedBox(height: 16),
          _buildInfoBar(context),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget(message: 'جاري فحص الجهاز...');
              }

              if (controller.games.isEmpty) {
                return const _EmptyState();
              }

              return AdaptiveGridView(
                mainAxisExtent: 236,
                itemCount: controller.games.length,
                itemBuilder: (context, index) => _GameCard(
                  controller: controller,
                  game: controller.games[index],
                ),
              );
            }),
          ),
          Obx(() {
            if (controller.games.isEmpty) return const SizedBox.shrink();
            return _buildBottomBar(context);
          }),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        const BackButton(),
        const SizedBox(width: 8),
        Icon(
          Icons.videogame_asset_rounded,
          color: colorScheme.primary,
          size: 30,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'الألعاب المثبتة على جهازك',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Obx(() {
          final allSelected =
              controller.selected.length == controller.games.length;
          final hasGames = controller.games.isNotEmpty;
          return TextButton.icon(
            onPressed: hasGames ? controller.toggleSelectAll : null,
            icon: Icon(allSelected ? Icons.deselect : Icons.select_all),
            label: Text(allSelected ? 'إلغاء تحديد الكل' : 'تحديد الكل'),
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
          );
        }),
        const SizedBox(width: 12),
        Obx(() {
          return CustomButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.detectInstalledGames,
            text: controller.games.isEmpty ? 'فحص الجهاز' : 'إعادة الفحص',
            icon: Icon(
              controller.games.isEmpty ? Icons.travel_explore : Icons.refresh,
            ),
            isLoading: controller.isLoading.value,
            width: 190,
            height: 46,
          );
        }),
      ],
    );
  }

  Widget _buildInfoBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                'جاري فحص جهازك للبحث عن الألعاب المثبتة...',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      final count = controller.games.length;
      if (count == 0) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'تم العثور على $count لعبة على جهازك — اختر الألعاب لنقلها إلى مكتبة "العب الآن"، سيتم البحث عنها في النظام أولاً ثم إضافتها.',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.06)),
      ),
      child: Obx(() {
        final count = controller.selected.length;
        return Row(
          children: [
            Expanded(
              child: Text(
                count == 0
                    ? 'لم يتم اختيار أي لعبة بعد'
                    : 'تم اختيار $count لعبة',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 440,
              child: CustomButton(
                onPressed: controller.isSyncing.value
                    ? null
                    : controller.syncSelectedToPlayNow,
                text: count == 0
                    ? 'اختر ألعاباً للمزامنة'
                    : 'إضافة $count لعبة إلى العب الآن',
                icon: const Icon(Icons.cloud_upload_outlined),
                isLoading: controller.isSyncing.value,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Mobile / narrow-screen layout
// ════════════════════════════════════════════════════════════════════════

class _InstalledGamesMobile extends StatelessWidget {
  const _InstalledGamesMobile({required this.controller});

  final InstalledGamesController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutMine(
      body: Column(
        children: [
          Header(
            title: 'الألعاب المثبتة على جهازك',
            leading: const BackButton(),
          ),
          const SizedBox(height: 8),
          _buildScanSection(context),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget(message: 'جاري فحص الجهاز...');
              }

              if (controller.games.isEmpty) {
                return const _EmptyState();
              }

              return _buildList();
            }),
          ),
          Obx(() {
            if (controller.games.isEmpty) return const SizedBox.shrink();
            return _buildBottomBar(context);
          }),
        ],
      ),
    );
  }

  Widget _buildScanSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final count = controller.games.length;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      count == 0
                          ? 'افحص جهازك لاكتشاف الألعاب المثبتة عليه'
                          : 'تم العثور على $count لعبة مثبتة على جهازك',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.detectInstalledGames,
                    text: count == 0 ? 'فحص الجهاز' : 'إعادة الفحص',
                    icon: Icon(
                      count == 0 ? Icons.travel_explore : Icons.refresh,
                    ),
                    isLoading: controller.isLoading.value,
                    height: 44,
                    width: 160,
                  ),
                ],
              ),
              if (count > 0) ...[
                const SizedBox(height: 10),
                Text(
                  'اختر الألعاب التي تريد نقلها إلى مكتبة "العب الآن" — سيتم البحث عنها في النظام أولاً ثم إضافتها.',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Obx(() {
                final allSelected =
                    controller.selected.length == controller.games.length;
                return InkWell(
                  onTap: controller.toggleSelectAll,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: allSelected,
                          onChanged: (_) => controller.toggleSelectAll(),
                          visualDensity: VisualDensity.compact,
                        ),
                        Text(
                          allSelected ? 'إلغاء تحديد الكل' : 'تحديد الكل',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: controller.games.length,
            itemBuilder: (context, index) {
              return _buildTile(context, controller.games[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, InstalledGameModel game) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final isSel = controller.isSelected(game);
      final status = controller.statusOf(game);

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: CustomCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: isSel
              ? Border.all(color: colorScheme.primary, width: 1.5)
              : null,
          child: Row(
            children: [
              Checkbox(
                value: isSel,
                onChanged: (_) => controller.toggleSelection(game),
                activeColor: colorScheme.primary,
              ),
              _GameIcon(game: game),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _SourceBadge(game: game),
                        if (status != InstalledGameSyncStatus.idle) ...[
                          const SizedBox(width: 8),
                          _StatusBadge(status: status),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(context, game, status),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButton(
    BuildContext context,
    InstalledGameModel game,
    InstalledGameSyncStatus status,
  ) {
    switch (status) {
      case InstalledGameSyncStatus.syncing:
        return const SizedBox(
          width: 40,
          height: 40,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );

      case InstalledGameSyncStatus.idle:
      case InstalledGameSyncStatus.error:
      case InstalledGameSyncStatus.notFound:
        return IconButton(
          onPressed: controller.isSyncing.value
              ? null
              : () => controller.syncSingleGame(game),
          tooltip: 'إضافة إلى العب الآن',
          icon: const Icon(Icons.playlist_add),
          color: Theme.of(context).colorScheme.primary,
        );

      case InstalledGameSyncStatus.added:
      case InstalledGameSyncStatus.already:
      case InstalledGameSyncStatus.queued:
        return const SizedBox(width: 40);
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.onSurface.withOpacity(0.08)),
        ),
      ),
      child: Obx(() {
        final count = controller.selected.length;
        return Row(
          children: [
            Expanded(
              child: CustomButton(
                onPressed: controller.isSyncing.value
                    ? null
                    : controller.syncSelectedToPlayNow,
                text: count == 0
                    ? 'اختر ألعاباً للمزامنة'
                    : 'إضافة $count لعبة إلى العب الآن',
                icon: const Icon(Icons.cloud_upload_outlined),
                isLoading: controller.isSyncing.value,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Desktop game card
// ════════════════════════════════════════════════════════════════════════

class _GameCard extends StatelessWidget {
  const _GameCard({required this.controller, required this.game});

  final InstalledGamesController controller;
  final InstalledGameModel game;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final isSel = controller.isSelected(game);
      final status = controller.statusOf(game);

      return GestureDetector(
        onTap: () => controller.toggleSelection(game),
        child: CustomCard(
          padding: const EdgeInsets.all(14),
          border: Border.all(
            color: isSel
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.07),
            width: isSel ? 2 : 1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _GameIcon(game: game, size: 52),
                  const Spacer(),
                  Icon(
                    isSel ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSel
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.25),
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                game.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _SourceBadge(game: game),
                  if (status != InstalledGameSyncStatus.idle) ...[
                    const SizedBox(width: 6),
                    Flexible(child: _StatusBadge(status: status)),
                  ],
                ],
              ),
              const Spacer(),
              _DesktopCardAction(
                controller: controller,
                game: game,
                status: status,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _DesktopCardAction extends StatelessWidget {
  const _DesktopCardAction({
    required this.controller,
    required this.game,
    required this.status,
  });

  final InstalledGamesController controller;
  final InstalledGameModel game;
  final InstalledGameSyncStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status) {
      case InstalledGameSyncStatus.syncing:
        return SizedBox(
          height: 40,
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Text(
                'جاري البحث...',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      case InstalledGameSyncStatus.idle:
      case InstalledGameSyncStatus.error:
      case InstalledGameSyncStatus.notFound:
        return SizedBox(
          width: double.infinity,
          height: 40,
          child: OutlinedButton.icon(
            onPressed: controller.isSyncing.value
                ? null
                : () => controller.syncSingleGame(game),
            icon: const Icon(Icons.playlist_add, size: 18),
            label: const Text('إضافة إلى العب الآن'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary.withOpacity(0.6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );

      case InstalledGameSyncStatus.added:
      case InstalledGameSyncStatus.already:
      case InstalledGameSyncStatus.queued:
        final (label, color, icon) = _statusInfo(status);
        return Container(
          height: 40,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
    }
  }
}
