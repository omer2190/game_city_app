import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _scale = Tween<double>(
      begin: 0.92,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
    _fade = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
    _anim.repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).cardColor;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primary.withOpacity(0.12),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _anim,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fade.value,
                    child: Transform.scale(scale: _scale.value, child: child),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    // shape: BoxShape.circle,
                    // gradient: LinearGradient(
                    //   colors: [primary, primary.withOpacity(0.85)],
                    // ),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: primary.withOpacity(0.28),
                    //     blurRadius: 18,
                    //     spreadRadius: 2,
                    //   ),
                    // ],
                  ),
                  child: SvgPicture.asset(
                    'assets/images/Asset 10.svg',
                    height: 50,
                    width: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Gaming City',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary.withOpacity(0.98),
                ),
              ),
              // const SizedBox(height: 8),
              // Text(
              //   'جاري التحضير...',
              //   style: TextStyle(
              //     fontSize: 12,
              //     color: Colors.white.withOpacity(0.8),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
