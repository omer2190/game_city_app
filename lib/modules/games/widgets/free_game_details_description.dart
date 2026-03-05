import 'package:flutter/material.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import '../../../data/models/game_model.dart';

class FreeGameDetailsDescription extends StatelessWidget {
  final Game game;

  const FreeGameDetailsDescription({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (game.platforms != null && game.platforms!.isNotEmpty) ...[
          const Text(
            'المنصات المتوفرة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            game.platforms!.join(', '),
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          const SizedBox(height: 20),
        ],
        const Text(
          'عن العرض',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          game.description ?? 'لا يوجد وصف متاح',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[400], fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 24),
        if (game.deal?.expiry != null ||
            game.released != null ||
            game.status == 'coming_soon') ...[
          Builder(
            builder: (context) {
              // Separate logic for "Coming Soon" status from "Offer Expiry"
              bool isComingSoon = game.status == 'coming_soon';
              if (!isComingSoon && game.released != null) {
                try {
                  final releaseDate = DateTime.parse(game.released!);
                  isComingSoon = releaseDate.isAfter(DateTime.now());
                } catch (_) {}
              }

              // Decide which date to show in the rows
              final String? dateToShow = isComingSoon
                  ? (game.released ?? game.deal?.expiry)
                  : game.deal?.expiry;

              return Column(
                children: [
                  _buildInfoRow(
                    'الحالة',
                    isComingSoon ? 'لعبة قادمة قريباً' : 'متاح الان',
                    color: isComingSoon ? Colors.orange : Colors.green,
                    textColor: Colors.black,
                  ),
                  SizedBox(height: 20),
                  if (isComingSoon && game.remainingTime.isNotEmpty) ...[
                    const Text(
                      'الوقت المتبقي لليوم المتوقع',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.remainingTime,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (game.deal?.timestamp != null)
                        _buildInfoRow(
                          'تاريخ الإضافة',
                          _formatDate(game.deal!.timestamp!),
                          color: Colors.transparent,
                        ),
                      if (dateToShow != null)
                        _buildInfoRow(
                          isComingSoon
                              ? 'تاريخ الإصدار المتوقع'
                              : 'تاريخ انتهاء العرض',
                          _formatDate(dateToShow),
                          color: Colors.transparent,
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? color,
    Color? textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        CustomCard(
          color: color,
          border: Border.all(color: color ?? Colors.transparent),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
