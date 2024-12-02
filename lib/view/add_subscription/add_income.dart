import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:card_swiper/card_swiper.dart';

class AddIncome extends StatefulWidget {
  @override
  _AddIncomeState createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  String _selectedCategory = 'Category';
  DateTime _selectedDate = DateTime(2024, 11, 21);

  Future<void> _addIncome() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final incomeDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('incomes')
          .doc();

      await incomeDoc.set({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'value': double.tryParse(_valueController.text) ?? 0.0,
        'categoryId': _selectedCategory == 'Category' ? null : _selectedCategory,
        'datetime': _selectedDate,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Income added successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding income: $e')),
      );
    }
  }

  final List carArr = [
    {
      "name": "code for any1",
      "number": "**** **** **** 2197",
      "month_year": "08/27"
    },
    {
      "name": "code for any2",
      "number": "**** **** **** 2198",
      "month_year": "09/27"
    },

  ];

  SwiperController controller = SwiperController();

  Widget buildSwiper() {
    return Swiper(
      itemCount: carArr.length,
      customLayoutOption: CustomLayoutOption(startIndex: -1, stateCount: 3)
        ..addRotate([-45.0 / 180, 0.0, 45.0 / 180])
        ..addTranslate([
          const Offset(-370.0, -40.0),
          Offset.zero,
          const Offset(370.0, -40.0),
        ]),
      fade: 1.0,
      onIndexChanged: (index) {
        print(index);
      },
      scale: 0.8,
      itemWidth: 232.0,
      itemHeight: 350,
      controller: controller,
      layout: SwiperLayout.STACK,
      viewportFraction: 0.8,
      itemBuilder: ((context, index) {
        var cObj = carArr[index] as Map? ?? {};
        return Container(
          // decoration: BoxDecoration(
          //     color: Colors.grey[700],
          //     borderRadius: BorderRadius.circular(15),
          //     boxShadow: const [
          //       BoxShadow(color: Colors.black26, blurRadius: 4)
          //     ]),
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(
              "assets/img/card_blank.png",
              width: 232.0,
              height: 350,
            ),
            Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Image.asset("assets/img/mastercard_logo.png", width: 50),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  "Virtual Card",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 115,
                ),
                Text(
                  cObj["name"] ?? "Code For Any",
                  style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  cObj["number"] ?? "**** **** **** 2197",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  cObj["month_year"] ?? "08/27",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ],
            )
          ]),
        );
      }),
      autoplayDisableOnInteraction: true,
      axisDirection: AxisDirection.right,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1E),
      appBar: AppBar(
        title: Text(
          "NEW INCOME",
          style:
              TextStyle(color: Color(0xFF8C8C9D), fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1C1C1E),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white, fontSize: 32),
              textAlign: TextAlign.center, // Căn giữa nội dung chữ
              decoration: InputDecoration(
                hintText: 'TITLE INCOME*',
                hintStyle: TextStyle(
                  color: Color(0xFF8C8C9D),
                  fontSize: 32, // Kích thước chữ gợi ý
                ),
                // Dùng border custom để chỉ gạch chân theo chiều dài chữ
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent, // Không hiển thị đường gạch mặc định
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF8C8C9D),
                    width: 2,
                  ),
                ),
                // Thêm border riêng để hiển thị gạch chân dài theo nội dung
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.text,
            ),

            SizedBox(height: 8),

            TextField(
              controller: _descriptionController,
              style: TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center, // Căn giữa nội dung chữ
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: TextStyle(
                  color: Color(0xFF8C8C9D),
                  fontSize: 13, // Kích thước chữ gợi ý
                ),
                // Dùng border custom để chỉ gạch chân theo chiều dài chữ
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent, // Không hiển thị đường gạch mặc định
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF8C8C9D),
                    width: 2,
                  ),
                ),
                // Thêm border riêng để hiển thị gạch chân dài theo nội dung
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 20),
            Container(
              height: 380, // Điều chỉnh chiều cao theo ý muốn
              child: buildSwiper(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _valueController,
              style: TextStyle(color: Colors.white, fontSize: 40),
              textAlign: TextAlign.center, // Căn giữa nội dung chữ
              decoration: InputDecoration(
                hintText: '\$0.00',
                hintStyle: TextStyle(
                  color: Color(0xFF8C8C9D),
                  fontSize: 40, // Kích thước chữ gợi ý
                ),
                // Dùng border custom để chỉ gạch chân theo chiều dài chữ
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent, // Không hiển thị đường gạch mặc định
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF8C8C9D),
                    width: 2,
                  ),
                ),
                // Thêm border riêng để hiển thị gạch chân dài theo nội dung
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.text,
            ),
            
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF8C8C9D)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${_selectedDate.day} ${_selectedDate.month} ${_selectedDate.year}',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                DropdownButton<String>(
                  dropdownColor: Color(0xFF1C1C1E),
                  value: _selectedCategory,
                  items: [
                    DropdownMenuItem(
                      value: 'Category',
                      child: Text('Category', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 'Salary',
                      child: Text('Salary', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 'Investment',
                      child: Text('Investment', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 'Other',
                      child: Text('Other', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),


            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _addIncome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB32B44),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'ADD INCOME',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



