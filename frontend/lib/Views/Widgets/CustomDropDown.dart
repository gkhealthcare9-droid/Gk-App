import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String hintText;
  final IconData icon;
  final Widget? footer;
  final bool isRequired;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    required this.hintText,
    required this.icon,
    this.footer,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(2, 2),
                ),
              ],
              border: Border.all(color: Colors.black, width: 1),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(icon, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      isExpanded: true,
                      value: value,
                      hint: RichText(
                        text: TextSpan(
                          text: hintText,
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                          children: [
                            if (isRequired)
                              const TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ),
                      items: items,
                      onChanged: onChanged,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0, right: 10),
              child: Align(alignment: Alignment.centerRight, child: footer!),
            ),
        ],
      ),
    );
  }
}
