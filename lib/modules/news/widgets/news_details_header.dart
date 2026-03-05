import 'package:flutter/material.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:get/get.dart';

class NewsDetailsHeader extends StatelessWidget {
  const NewsDetailsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Header(
      title: 'تفاصيل الخبر',
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
    );
  }
}
