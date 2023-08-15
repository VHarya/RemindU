import 'package:flutter/material.dart';
import 'package:remind_u/model/category.dart';

class CategoryCreateForm extends StatefulWidget {
  final Function(Category category) onDonePressed;
  const CategoryCreateForm({
    super.key,
    required this.onDonePressed,
  });

  @override
  State<CategoryCreateForm> createState() => _CategoryCreateFormState();
}

class _CategoryCreateFormState extends State<CategoryCreateForm> {
  TextEditingController nameController = TextEditingController();
  bool validateName = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Add Category",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
                
          const SizedBox(height: 10),
    
          Text(
            "Category Name",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(.15),
              hintText: "Enter Category Name",
              errorText: validateName ? "Category Name can't be empty!" : null,
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF333333))
              )
            ),
          ),
          
          // ---- BUTTONS ---- //
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  if (nameController.text.isEmpty) {
                    setState(() => validateName = true);
                    return;
                  }
    
                  widget.onDonePressed(Category(nameController.text));
                },
                child: const Text("Save"),
              ),
            ],
          ),
          // ---- BUTTONS ---- //
        ],
      ),
    );
  }
}