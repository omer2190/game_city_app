import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_city_app/data/models/user_model.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

Widget buildVisitorPlayNowSection(BuildContext context, UserModel user) {
  return SizedBox(
    height: 180,
    child: HorizontalScrollbar(
      builder: (context, controller) => ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: user.playNow!.length,
        itemBuilder: (_, i) {
          final g = user.playNow![i] as Map<String, dynamic>;
          final img = (g['image'] ?? g['backgroundImage'] ?? '') as String;
          final t = (g['title'] ?? g['name'] ?? '') as String;
          return Container(
            width: 130,
            margin: const EdgeInsetsDirectional.only(end: 14, bottom: 4),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(
                  AppRoutes.gameDetails,
                  arguments: {'gameId': g['id']},
                );
              },
              child: CustomCard(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      img.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: img,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: Colors.white10,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.white10,
                                child: const Icon(
                                  Icons.videogame_asset,
                                  color: Colors.white30,
                                  size: 40,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.white10,
                              child: const Icon(
                                Icons.videogame_asset,
                                color: Colors.white30,
                                size: 40,
                              ),
                            ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.85),
                            ],
                            stops: const [0.45, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Text(
                          t,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
