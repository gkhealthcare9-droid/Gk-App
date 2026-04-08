import 'package:flutter/material.dart';
import '../../Utils/Colors.dart';

class CustomLazyLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const CustomLazyLoader({super.key, this.size = 50, this.color});

  @override
  State<CustomLazyLoader> createState() => _CustomLazyLoaderState();
}

class _CustomLazyLoaderState extends State<CustomLazyLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Center(
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                (widget.color ?? AppColors.primaryBlue).withOpacity(0.1),
                (widget.color ?? AppColors.primaryBlue),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedView extends StatelessWidget {
  final Widget child;
  final int delay; // in milliseconds

  const AnimatedView({super.key, required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
