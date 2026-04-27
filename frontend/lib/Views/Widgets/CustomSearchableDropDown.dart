import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSearchableDropDown<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final String Function(T) itemAsString;
  final Function(T?) onChanged;
  final T? selectedItem;
  final String hintText;
  final bool isRequired;
  final String? Function(T?)? validator;
  final IconData prefixIcon;
  final bool showAddButton;
  final VoidCallback? onAddPressed;
  final bool enabled; // 👈 Added enabled property

  const CustomSearchableDropDown({
    super.key,
    required this.label,
    required this.items,
    required this.itemAsString,
    required this.onChanged,
    this.selectedItem,
    this.hintText = 'Select an option',
    this.isRequired = false,
    this.validator,
    this.prefixIcon = Icons.search,
    this.showAddButton = false,
    this.onAddPressed,
    this.enabled = true, // Default to true
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.6, // Visual feedback for disabled state
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap:
                  enabled
                      ? () => _showSearchModal(context)
                      : null, // Disable tap
              child: FormField<T>(
                initialValue: selectedItem,
                validator:
                    validator ??
                    (value) {
                      if (isRequired && value == null && enabled) {
                        // Only validate if enabled
                        return '$label is required';
                      }
                      return null;
                    },
                builder: (state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: label,
                      hintText: hintText,
                      prefixIcon: Icon(
                        prefixIcon,
                        color:
                            enabled
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                      ),
                      errorText: state.errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerLowest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            selectedItem != null
                                ? itemAsString(selectedItem as T)
                                : hintText,
                            style: TextStyle(
                              color:
                                  selectedItem != null && enabled
                                      ? Colors.black87
                                      : Colors.grey[600],
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchModal(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    var filteredItems = items.obs;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle for sliding
            Container(
              margin: const EdgeInsets.all(12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search $label...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (value) {
                        filteredItems.value =
                            items
                                .where(
                                  (item) => itemAsString(
                                    item,
                                  ).toLowerCase().contains(value.toLowerCase()),
                                )
                                .toList();
                      },
                    ),
                  ),
                  if (showAddButton) ...[
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.blue,
                        size: 30,
                      ),
                      onPressed: onAddPressed,
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: filteredItems.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      title: Text(itemAsString(item)),
                      onTap: () {
                        onChanged(item);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }
}
