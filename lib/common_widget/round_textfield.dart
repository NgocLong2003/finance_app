import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/color_extension.dart';
import '../view/theme/theme_notifier.dart';

class RoundTextField extends StatelessWidget {
  final String title;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextAlign titleAlign;
  final bool obscureText;
  const RoundTextField(
      {super.key,
      required this.title,
      this.titleAlign = TextAlign.left,
      this.controller,
      this.keyboardType,
      this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: titleAlign,
                style: TextStyle(color: themeNotifier.textColor, fontSize: 16),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        Container(
          height: 48,
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: TColor.gray60.withOpacity(0.05),
              border: Border.all(color: TColor.gray70),
              borderRadius: BorderRadius.circular(15)),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: TextStyle(
              color: themeNotifier.textColor, // Set text color to white
            ),
          ),
        )
      ],
    );
  }
}
