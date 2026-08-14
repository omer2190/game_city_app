import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';

class GameSelectorCard extends StatelessWidget {
  final Map<String, dynamic> game;
  final bool isSelected;
  final Color primary;
  final Color surface;
  final VoidCallback onTap;

  const GameSelectorCard({
    super.key,
    required this.game,
    required this.isSelected,
    required this.primary,
    required this.surface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= AppBreakpoints.tabletBreakpoint;
    final isTablet =
        screenWidth >= AppBreakpoints.mobileBreakpoint &&
        screenWidth < AppBreakpoints.tabletBreakpoint;

    // Desktop: wider card with horizontal layout
    // Tablet: medium card
    // Mobile: original narrow vertical card
    final double cardWidth = isDesktop ? 180 : (isTablet ? 140 : 110);
    final double cardRadius = isDesktop ? 24 : 20;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: cardWidth,
        margin: EdgeInsets.only(right: isDesktop ? 18 : 14, bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.15) : surface,
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: isDesktop ? 14 : 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 2,
          ),
        ),
        padding: EdgeInsets.all(isDesktop ? 12 : 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (game['image'] != null && game['image'].toString().isNotEmpty)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isDesktop ? 18 : 14),
                  child: Image.network(
                    game['image'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.videogame_asset,
                      size: isDesktop ? 52 : 44,
                      color: isSelected ? primary : Colors.grey[400],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Icon(
                  Icons.videogame_asset,
                  size: isDesktop ? 52 : 44,
                  color: isSelected ? primary : Colors.grey[400],
                ),
              ),
            SizedBox(height: isDesktop ? 12 : 8),
            Text(
              game['title'].toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 13 : 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primary : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
