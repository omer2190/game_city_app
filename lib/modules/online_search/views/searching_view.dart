import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_city_app/shared/widgets/custom_card.dart';
import 'package:get/get.dart';
import '../matchmaking_controller.dart';

class SearchingView extends StatefulWidget {
  final MatchmakingController controller;
  final Color primary;
  final Color secondary;

  const SearchingView({
    super.key,
    required this.controller,
    required this.primary,
    required this.secondary,
  });

  @override
  State<SearchingView> createState() => _SearchingViewState();
}

class _SearchingViewState extends State<SearchingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ripple effects
                    Container(
                      width: 200 * _pulseController.value,
                      height: 200 * _pulseController.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.primary.withOpacity(
                            1 - _pulseController.value,
                          ),
                          width: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: 150 * _pulseController.value,
                      height: 150 * _pulseController.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.primary.withOpacity(
                            1 - _pulseController.value,
                          ),
                          width: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: widget.secondary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.secondary.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.search,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'جار البحث عن لاعب مناسب...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.primary,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () =>
                //  Text(
                //   'لعبة: ${widget.controller.myGames.firstWhereOrNull((g) => g['id'] == widget.controller.selectedGameId.value)?['title'] ?? 'Selected Game'}',
                //   style: TextStyle(color: Colors.grey[600]),
                // ),
                CustomCard(
                  child: Row(
                    children: [
                      ClipPath(
                        clipper: ShapeBorderClipper(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              widget.controller.myGames.firstWhereOrNull(
                                (g) =>
                                    g['id'] ==
                                    widget.controller.selectedGameId.value,
                              )?['image'] ??
                              '',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.videogame_asset, size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.controller.myGames.firstWhereOrNull((g) => g['id'] == widget.controller.selectedGameId.value)?['title'] ?? 'Selected Game'}',
                            style: TextStyle(
                              color: Get.theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                widget.controller.selectedType.value == 'solo'
                                    ? Icons.person
                                    : Icons.group,
                                size: 16,
                                color: Get.theme.primaryColor,
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          if (widget.controller.notesController.text.isNotEmpty)
                            Text(
                              widget.controller.notesController.text,
                              style: TextStyle(color: Colors.white),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
          const SizedBox(height: 48),
          OutlinedButton(
            onPressed: widget.controller.cancelSearch,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('إلغاء البحث'),
          ),
        ],
      ),
    );
  }
}
