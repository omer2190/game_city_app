import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 110,
        margin: const EdgeInsets.only(right: 14, bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.15) : surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: 10,
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
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (game['image'] != null && game['image'].toString().isNotEmpty)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    game['image'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.videogame_asset,
                      size: 44,
                      color: isSelected ? primary : Colors.grey[400],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Icon(
                  Icons.videogame_asset,
                  size: 44,
                  color: isSelected ? primary : Colors.grey[400],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              game['title'].toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
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
