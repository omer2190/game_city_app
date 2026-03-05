import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/header.dart';
import '../controllers/news_controller.dart';

class NewsHeader extends StatelessWidget {
  final NewsController controller;
  final TextEditingController searchController;

  const NewsHeader({
    super.key,
    required this.controller,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: controller.isSearching.value
            ? _buildSearchBar(context)
            : _buildTitleBar(context),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      key: const ValueKey('search_bar'),
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: searchController,
        autofocus: true,
        onSubmitted: (value) => controller.setSearch(value),
        decoration: InputDecoration(
          hintText: 'ابحث عن خبر...',
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              searchController.clear();
              controller.toggleSearch();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Header(
      key: const ValueKey('title_bar'),
      leading: IconButton(
        onPressed: () => controller.toggleSearch(),
        icon: Icon(
          Icons.search_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: 'أخبار الألعاب',
      trailing: IconButton(
        onPressed: () => controller.toggleCategories(),
        icon: Icon(
          Icons.filter_list_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
