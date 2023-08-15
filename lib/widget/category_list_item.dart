import 'package:flutter/material.dart';

class CategoryListItem extends StatelessWidget {
  final String categoryName;
  final Function() onEditPressed;
  final Function() onDeletePressed;
  const CategoryListItem({
    super.key,
    required this.categoryName,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(color: const Color(0xFFE6E6E6)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 5),
              Text(
                categoryName,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onEditPressed,
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: onDeletePressed,
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}