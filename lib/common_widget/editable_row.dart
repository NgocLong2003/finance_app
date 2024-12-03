import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class EditableRow extends StatelessWidget {
  final String title;
  final String value;
  final ValueChanged<String> onValueChanged; // Hàm callback để truyền giá trị mới

  const EditableRow({
    super.key,
    required this.title,
    required this.value,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // Hiện modal dialog để chỉnh sửa
        final newValue = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            String tempValue = value;
            return AlertDialog(
              title: Text("Edit $title"),
              content: TextField(
                controller: TextEditingController(text: value),
                onChanged: (val) {
                  tempValue = val;
                },
                decoration: InputDecoration(
                  labelText: "Enter new $title",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null), // Cancel
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(tempValue), // OK
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );

        if (newValue != null && newValue != value) {
          onValueChanged(newValue); // Truyền giá trị mới qua callback
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                  color: TColor.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: TColor.gray30,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Image.asset("assets/img/next.png",
                width: 12, height: 12, color: TColor.gray30)
          ],
        ),
      ),
    );
  }
}
