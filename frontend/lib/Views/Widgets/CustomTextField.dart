import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../Utils/Colors.dart';

class FirstLetterCapitalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final first = text.characters.first;
    if (first.toUpperCase() == first) return newValue;

    final capitalized = first.toUpperCase() + text.substring(1);
    return TextEditingValue(
      text: capitalized,
      selection: newValue.selection,
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final bool showSuffixIcon;
  final VoidCallback? onTapSuffix;
  final Widget? footer;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.showSuffixIcon = false,
    this.onTapSuffix,
    this.footer,
    this.inputFormatters,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              // REMOVED OUTLINE: Using a subtle shadow instead for a cleaner, modern look
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primaryBlue),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    obscureText: obscureText,
                    inputFormatters: inputFormatters,
                    validator: validator,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    focusNode: focusNode,
                    style: const TextStyle(fontSize: 15, color: AppColors.black, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: hintText,
                      hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.5), fontWeight: FontWeight.normal),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      errorStyle: const TextStyle(height: 0), // Hide default error text to keep it clean
                    ),
                  ),
                ),
                if (showSuffixIcon)
                  GestureDetector(
                    onTap: onTapSuffix,
                    child: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: AppColors.grey.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: footer!,
              ),
            ),
        ],
      ),
    );
  }
}

class CustomDatePickerField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Widget? footer;

  const CustomDatePickerField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    this.selectedDate,
    required this.onDateSelected,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              // REMOVED OUTLINE: Soft shadow integration
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primaryBlue,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  onDateSelected(pickedDate);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: AppColors.primaryBlue),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        selectedDate != null ? formattedDate : hintText,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: selectedDate != null ? AppColors.black : AppColors.grey.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: footer!,
              ),
            ),
        ],
      ),
    );
  }
}

class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final Widget? footer;
  final String? Function(String?)? validator;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.footer,
    this.validator,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      label: widget.label,
      hintText: widget.hintText,
      icon: Icons.lock_outline,
      obscureText: _obscureText,
      showSuffixIcon: true,
      onTapSuffix: _toggleObscure,
      footer: widget.footer,
      validator: widget.validator,
    );
  }
}
