import 'package:flutter/material.dart';
import '../../Utils/Colors.dart';

class CustomButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String buttonText;
  final bool isYellow; // repurpose as primary toggler

  const CustomButton({
    super.key,
    this.onTap,
    required this.buttonText,
    this.isYellow = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    if (widget.onTap != null) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.onTap == null ? AppColors.grey.withOpacity(0.3) : (widget.isYellow ? AppColors.primaryBlue : AppColors.accentBlue);
    final textColor = Colors.white;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.96 : 1.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          // REMOVED ALL BORDERS: Using only modern soft shadows
          boxShadow: _isPressed || widget.onTap == null
              ? []
              : [
            BoxShadow(
              color: backgroundColor.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        alignment: Alignment.center,
        child: Text(
          widget.buttonText.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.5,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
