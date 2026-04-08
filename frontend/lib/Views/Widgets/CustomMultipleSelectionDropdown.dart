import 'package:flutter/material.dart';

class CustomMultiSelectField<T> extends StatelessWidget {
  final List<T> selectedValues;
  final List<T> allOptions;
  final String hintText;
  final IconData icon;
  final void Function(List<T>) onSelectionChanged;
  final String Function(T) optionLabel;
  final Widget? footer;

  const CustomMultiSelectField({
    super.key,
    required this.selectedValues,
    required this.allOptions,
    required this.onSelectionChanged,
    required this.hintText,
    required this.icon,
    required this.optionLabel,
    this.footer,
  });

  void _showMultiSelect(BuildContext context) async {
    final List<T> tempSelected = List.from(selectedValues);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Select Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...allOptions.map((item) {
                  return CheckboxListTile(
                    value: tempSelected.contains(item),
                    title: Text(optionLabel(item)),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          tempSelected.add(item);
                        } else {
                          tempSelected.remove(item);
                        }
                      });
                    },
                  );
                }),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onSelectionChanged(tempSelected);
                  },
                  child: Text('Done'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabels = selectedValues.map(optionLabel).join(', ');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showMultiSelect(context),
            child: Container(
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedValues.isEmpty ? hintText : selectedLabels,
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedValues.isEmpty ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0, right: 10),
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
