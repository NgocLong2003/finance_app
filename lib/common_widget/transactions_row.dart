import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm package để định dạng ngày tháng

import '../common/color_extension.dart';

class TransactionRow extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressed;

  const TransactionRow(
      {super.key, required this.sObj, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Định dạng ngày tháng
    String formattedDate = DateFormat("dd MMM yyyy").format(sObj["datetime"]);

    // Xử lý giá trị tiền tệ
    bool isIncome = sObj["type"] == "income";
    String formattedValue = isIncome
        ? "+${NumberFormat('#,##0').format(sObj["value"])} ₫"
        : "-${NumberFormat('#,##0').format(sObj["value"])} ₫";
    Color valueColor = isIncome ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          height: 64,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: TColor.border.withOpacity(0.15),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              Image.asset(
                sObj["icon"],
                width: 40,
                height: 40,
              ),
              const SizedBox(
                width: 8,
              ),
              // Cột chứa title và date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      sObj["title"],
                      style: TextStyle(
                          color: TColor.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                          color: TColor.white.withOpacity(0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              // Hiển thị giá trị tiền tệ
              Text(
                formattedValue,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
