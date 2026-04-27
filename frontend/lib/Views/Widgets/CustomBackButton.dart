import 'package:flutter/material.dart';
import 'package:sales_grow/Utils/Colors.dart';

class CustomBackButton extends StatefulWidget {
  final VoidCallback onTap;

  const CustomBackButton({
    super.key,
    required this.onTap,
  });

  @override
  State<CustomBackButton> createState() => _CustomBackButtonState();
}

class _CustomBackButtonState extends State<CustomBackButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryBlue,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
