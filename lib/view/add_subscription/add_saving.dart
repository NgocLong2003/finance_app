import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddSaving extends StatefulWidget {
  @override
  _AddSavingState createState() => _AddSavingState();
}

class _AddSavingState extends State<AddSaving> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();
  final TextEditingController _currentAmountController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  String _category = 'Category';  // Default category value
  String _priority = 'Medium'; // Default priority value
  String _unit = 'a day'; // Default unit value for savings

  // Select Date Function
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate && picked != _endDate) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Add saving plan to Firebase
void _addSavingPlan() async {
  final user = FirebaseAuth.instance.currentUser;  // Lấy user hiện tại
  if (user == null) {
    // Nếu không có người dùng đăng nhập
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("No user is logged in. Please log in first."),
    ));
    return;
  }
  final userId = user.uid;  // Lấy UID của người dùng

  if (_titleController.text.isEmpty || _goalAmountController.text.isEmpty) {
    // Hiển thị cảnh báo nếu các trường bắt buộc bị bỏ trống
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Please fill all the required fields."),
    ));
    return;
  }

  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('savings').add({
      'title': _titleController.text,
      'goalAmount': double.parse(_goalAmountController.text),
      'currentAmount': double.parse(_currentAmountController.text.isEmpty ? '0' : _currentAmountController.text),
      'unit': _unit,
      'startDate': Timestamp.fromDate(_startDate!),
      'endDate': _endDate != null ? Timestamp.fromDate(_endDate!) : null,
      'priority': _priority,
      'purpose': _descriptionController.text,
    });

    // Hiển thị thông báo thành công và quay lại màn hình trước
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Saving Plan added successfully!"),
    ));
    Navigator.pop(context);
  } catch (e) {
    // Xử lý lỗi
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Error adding saving plan: $e"),
    ));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Saving Plan"),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "TITLE SAVING PLAN*"),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              TextField(
                controller: _goalAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Goal Amount"),
              ),
              TextField(
                controller: _currentAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Current Amount (Optional)"),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'From:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: Text(
                      _startDate != null
                          ? DateFormat('dd MMM yyyy').format(_startDate!)
                          : 'Select Date',
                      style: TextStyle(color: Colors.teal, fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'To:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: Text(
                      _endDate != null
                          ? DateFormat('dd MMM yyyy').format(_endDate!)
                          : 'Select Date',
                      style: TextStyle(color: Colors.teal, fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Amount per $_unit:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              TextFormField(
                initialValue: '3.00', // Default value
                decoration: InputDecoration(labelText: 'Amount per Day'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _unit = value;
                  });
                },
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _priority,
                onChanged: (String? newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
                items: <String>['High', 'Medium', 'Low']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                hint: Text("Priority"),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _category,
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
                items: <String>['Category', 'Food', 'Transport', 'Health']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                hint: Text("Category"),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _addSavingPlan,
                  child: Text('ADD SAVING PLANS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
