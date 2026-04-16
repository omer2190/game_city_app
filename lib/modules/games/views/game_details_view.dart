import 'package:flutter/material.dart';
import 'package:game_city_app/modules/games/widgets/free_game_details_description.dart';
import 'package:game_city_app/modules/games/widgets/free_game_details_image.dart';
import 'package:game_city_app/modules/games/widgets/free_game_details_info.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/game_model.dart';
import '../../../data/repositories/games_repository.dart';
import '../../wishlist/controllers/wishlist_controller.dart';

class GameDetailsView extends StatefulWidget {
  // final Game game;

  const GameDetailsView({super.key});

  @override
  State<GameDetailsView> createState() => _GameDetailsViewState();
}

class _GameDetailsViewState extends State<GameDetailsView> {
  final WishlistController wishlistController = Get.find();
  final GamesRepository _gamesRepository = GamesRepository();

  late Future<Game?> _gameFuture;
  final String gameId = Get.arguments['gameId'];

  @override
  void initState() {
    super.initState();
    // if (widget.game.id != null) {
    _gameFuture = _gamesRepository.getGameById(gameId);
    // } else {
    //   _gameFuture = Future.value(widget.game);
    // }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Game?>(
      future: _gameFuture,
      builder: (context, snapshot) {
        // Use the initial game while loading or if it fails
        final Game displayGame =
            snapshot.data ?? Game(id: gameId, title: 'تفاصيل اللعبة');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LayoutMine(
            body: Column(
              children: [
                Header(
                  title: 'تحميل تفاصيل اللعبة',
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return LayoutMine(
            body: Column(
              children: [
                Header(
                  title: 'خطأ',
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text('حدث خطأ أثناء تحميل تفاصيل اللعبة.'),
                  ),
                ),
              ],
            ),
          );
        }

        return LayoutMine(
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Header(
                      title: displayGame.title ?? 'تفاصيل اللعبة',
                      leading: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      trailing: Obx(() {
                        final isInWishlist = wishlistController.isInWishlist(
                          displayGame.id ?? '',
                        );
                        return IconButton(
                          onPressed: () {
                            if (displayGame.id != null) {
                              wishlistController.toggleWishlist(
                                displayGame.id!,
                              );
                            }
                          },
                          icon: Icon(
                            isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isInWishlist ? Colors.red : null,
                          ),
                        );
                      }),
                    ),
                    Column(
                      children: [
                        FreeGameDetailsImage(imageUrl: displayGame.image),
                        FreeGameDetailsInfo(game: displayGame),
                        FreeGameDetailsDescription(game: displayGame),
                        const SizedBox(height: 20),
                        if (displayGame.url != null ||
                            displayGame.deal?.url != null)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => _launchUrl(
                                displayGame.deal?.url ?? displayGame.url!,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'احصل على اللعبة الآن',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ],
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
