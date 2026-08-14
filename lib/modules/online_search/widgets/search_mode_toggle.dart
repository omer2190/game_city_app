import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';

class SearchModeToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color primary;
  final Color surface;
  final VoidCallback onTap;

  const SearchModeToggle({
    super.key,
    required this.label,
    required this.icon,
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

    // Desktop: horizontal layout with larger content
    // Tablet: horizontal layout with medium content
    // Mobile: vertical stacked layout (original)
    final bool useHorizontalLayout = isDesktop || isTablet;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: useHorizontalLayout
            ? EdgeInsets.symmetric(
                horizontal: isDesktop ? 28 : 20,
                vertical: isDesktop ? 22 : 16,
              )
            : const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? primary : surface,
          borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: isDesktop ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          border: Border.all(
            color: isSelected ? primary : Colors.white12,
            width: 1.5,
          ),
        ),
        child: useHorizontalLayout
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.black : Colors.grey,
                    size: isDesktop ? 30 : 26,
                  ),
                  SizedBox(width: isDesktop ? 14 : 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      color: isSelected ? Colors.black : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.black : Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
