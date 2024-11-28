import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddOutcome extends StatefulWidget {
  @override
  _AddOutcomeState createState() => _AddOutcomeState();
}

class _AddOutcomeState extends State<AddOutcome> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String selectedExpenseType = "One-time"; // Giá trị mặc định
  double expenseValue = 0.0;
  

  void _addOutcomeToFirestore() async {
    // User ID tạm thời, thay bằng logic lấy userId thật nếu cần
    User? user = FirebaseAuth.instance.currentUser; // Lấy User hiện tại
    if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user is logged in. Please log in first!')),
        );
        return;
    }

  String userId = user.uid; // Lấy userId từ FirebaseAuth

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("outcomes")
          .add({
        "title": _titleController.text,
        "description": _descriptionController.text,
        "cardId": "C001", // Giá trị mặc định
        "value": expenseValue,
        "unit": "USD", // Hoặc tuỳ chỉnh theo logic của bạn
        "categoryId": "Foods", // Giá trị mặc định
        "datetime": DateTime.now(),
        "expenseType": selectedExpenseType,
        "priority": "Medium", // Mặc định, có thể thêm tuỳ chọn sau
        "dueDate": null, // Để null tạm thời
        "isEssential": false, // Giá trị mặc định
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Outcome added successfully!')),
      );
      Navigator.pop(context); // Quay lại trang trước
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add outcome: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Outcome"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Title Outcome*",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Description Field
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Expense Type Buttons
            Text("Expense Type", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildExpenseTypeButton("One-time"),
                _buildExpenseTypeButton("Monthly"),
                _buildExpenseTypeButton("Annual"),
              ],
            ),
            SizedBox(height: 16),

            // Expense Value
            Text("Value (\$)", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  expenseValue = double.tryParse(value) ?? 0.0;
                });
              },
              decoration: InputDecoration(
                hintText: "0.00",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Add Outcome Button
            Center(
              child: ElevatedButton(
                onPressed: _addOutcomeToFirestore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text("ADD OUTCOME"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo nút chọn loại khoản chi (One-time, Monthly, Annual)
  Widget _buildExpenseTypeButton(String type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedExpenseType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selectedExpenseType == type ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.teal),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: selectedExpenseType == type ? Colors.white : Colors.teal,
          ),
        ),
      ),
    );
  }
}
