// widgets/career_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:careercheckr/constants/colors.dart';

class CareerBottomNav extends StatefulWidget {
  final int currentIndex;
  final Color backgroundColor;

  const CareerBottomNav({
    super.key,
    required this.currentIndex,
    this.backgroundColor = Colors.white,
  });

  @override
  State<CareerBottomNav> createState() => _CareerBottomNavState();
}

class _CareerBottomNavState extends State<CareerBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateTo(BuildContext context, int index) {
    final routes = ['/dashboard', '/profile', '/detector', '/history', '/tips'];
    if (index == widget.currentIndex) return;
    
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.home_rounded, Icons.home_outlined, 'Dashboard'),
      _NavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
      _NavItem(Icons.search_rounded, Icons.search_outlined, 'Detector'),
      _NavItem(Icons.history_rounded, Icons.history_outlined, 'History'),
      _NavItem(Icons.info_rounded, Icons.info_outline_rounded, 'Tips'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = index == widget.currentIndex;
              return _buildNavItem(context, index, items[index], isSelected);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, _NavItem item, bool isSelected) {
    return GestureDetector(
      onTap: () => _navigateTo(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.selectedIcon : item.unselectedIcon,
                key: ValueKey(isSelected),
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String label;

  _NavItem(this.selectedIcon, this.unselectedIcon, this.label);
}