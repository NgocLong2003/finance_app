import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';

class AddSaving extends StatefulWidget {
  @override
  _AddSavingState createState() => _AddSavingState();
}

class _AddSavingState extends State<AddSaving> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  String? _selectedCardId;
  double dailySaving = 0;
  String? _selectedCategoryId;
  String _selectedCategoryName = 'Category'; // Giá trị mặc định
  String _selectedCategoryIcon = 'assets/img/icloud.png'; // Icon mặc định
  Color? _selectedCategoryColor;
  final user = FirebaseAuth.instance.currentUser;
  String _selectedCategory = 'Category';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

Future<void> _addSaving() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    final savingDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('savings')
          .doc();
    double _currentAmount =  dailySaving * ((_startDate.difference(DateTime.now()).inDays).abs() + 1);

    await savingDoc.set({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'categoryId': _selectedCategoryId,
      'startDate': _startDate ?? DateTime.now(),
      'endDate': _endDate ?? DateTime.now(),
      'value': double.tryParse(_valueController.text) ?? 0.0,
      'unit': "VND",
      'currentAmount':  _currentAmount,
    });


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added Saving plan')),
    );

    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error adding saving plan: $e')),
    );
  }
}

String _calculateDailySaving() {
  if (_valueController.text.isEmpty || int.tryParse(_valueController.text) == null) {
    return '0,000'; // Giá trị mặc định nếu _valueController trống hoặc không hợp lệ
  }
  int totalAmount = int.parse(_valueController.text);
  if (_startDate == null || _endDate == null) {
    return '0,000'; // Giá trị mặc định nếu chưa chọn ngày
  }

  final durationInDays = _endDate.difference(_startDate).inDays + 1;
  if (durationInDays <= 0) {
    // Trả về tổng số tiền khi số ngày <= 0
    return NumberFormat('#,##0').format(totalAmount);
  }

  dailySaving = totalAmount / durationInDays;
  return NumberFormat('#,##0').format(dailySaving);
}


  Future<List<Map<String, dynamic>>> fetchCategoriesFromFirestore(String type) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('category')
          .where('type', isEqualTo: type)
          .get();

      List<Map<String, dynamic>> categoryList = snapshot.docs.map((doc) {
        return {
          "id": doc.id, // Thêm ID của category để biết cách xử lý
          "name": doc["name"] ?? "Unknown",
          "type": doc["type"] ?? "unknown",
          "icon": doc["icon"], // Mặc định icon
          "color": doc["color"] ?? "#FFFFFF",
          "isCustom": doc["isCustom"] ?? false,
        };
      }).toList();

      print("Fetched categories: $categoryList");
      return categoryList;
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }


void showCategoryModal(BuildContext context) async {
  List<Map<String, dynamic>> categories = await fetchCategoriesFromFirestore("outcome");

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFF1C1C1E), // Đổi màu nền của modal
        title: Text(
          'Select Category',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16, // Giảm cỡ chữ tiêu đề
          ),
        ),
        content: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true, // Giảm chiều cao để phù hợp với nội dung
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Hiển thị 4 cột
                crossAxisSpacing: 6.0, // Khoảng cách ngang giữa các mục
                mainAxisSpacing: 10.0, // Khoảng cách dọc giữa các hàng
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                var category = categories[index];
                return GestureDetector(
                  onTap: () {
                    // Cập nhật giá trị được chọn
                    setState(() {
                      _selectedCategoryName = category["name"];
                      _selectedCategoryIcon = category["icon"];
                      _selectedCategoryId = category["id"];
                      _selectedCategoryColor = Color(int.parse("0xFF" + category["color"].substring(1)));
                    });
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.0),
                        child: Image.asset(
                          category["icon"],
                          width: 40,
                          height: 40,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.0), // Khoảng cách bên trái và phải
                        child: Text(
                          category["name"],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10, // Giảm cỡ chữ
                          ),
                          textAlign: TextAlign.center, // Căn giữa chữ
                          overflow: TextOverflow.ellipsis, // Hiển thị "..." khi chữ quá dài
                          maxLines: 1, // Giới hạn số dòng là 1
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1E),
      appBar: AppBar(
        title: Text(
          "NEW SAVING PLAN",
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
              style: TextStyle(
                color: _selectedCategoryColor ?? Color(0xFFB32B44),
                 fontSize: 32,
                 fontWeight: FontWeight.bold
                 ),
              textAlign: TextAlign.center, // Căn giữa nội dung chữ
              decoration: InputDecoration(
                hintText: 'TITLE SAVING*',
                hintStyle: TextStyle(
                  color: Color(0xFF8C8C9D),
                  fontSize: 32,
                  fontWeight: FontWeight.bold // Kích thước chữ gợi ý
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
                hintText: 'Description your saving plan',
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
            SizedBox(height: 40),

            TextField(
              controller: _valueController,
              style: TextStyle(color: Colors.white, fontSize: 45),
              textAlign: TextAlign.center, // Căn giữa nội dung chữ
              decoration: InputDecoration(
                hintText: '0,000 VNĐ',
                hintStyle: TextStyle(
                  color: Color(0xFF8C8C9D),
                  fontSize: 50, // Kích thước chữ gợi ý
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
            
            SizedBox(height: 40),
            Row(
              children: [
               SizedBox(width: 10),   
                Text(
                  'FROM: ',
                  style: TextStyle(
                    color: Color(0xFFB32B44),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
Expanded(
  child: GestureDetector(
    onTap: () async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: _startDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              primaryColor: Color(0xFFB32B44), // Màu chủ đạo
              colorScheme: ColorScheme.dark(
                primary: Color(0xFFB32B44), // Màu chính (tương tự như trên)
                onPrimary: Colors.white, // Màu văn bản khi trên nền chính
                surface: Color(0xFF1C1C1C), // Màu nền của lịch (tối hơn)
                onSurface: Colors.white, // Màu văn bản trên nền
              ),
              buttonTheme: ButtonThemeData(
                textTheme: ButtonTextTheme.primary,
              ),
              dialogBackgroundColor: Color(0xFF1C1C1C), // Nền của hộp thoại
            ),
            child: child!,
          );
        },
      );
      if (pickedDate != null) {
        setState(() {
          _startDate = pickedDate;
        });
      }
    },
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF8C8C9D)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
          style: TextStyle(color: Colors.white,
           fontSize: 16,
           fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ),
),
                SizedBox(width: 8),
                Text(
                  'TO: ',
                  style: TextStyle(
                    color: Color(0xFFB32B44), 
                    fontSize: 16, 
                    fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),


Expanded(
  child: GestureDetector(
    onTap: () async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: _endDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              primaryColor: Color(0xFFB32B44), // Màu chủ đạo
              colorScheme: ColorScheme.dark(
                primary: Color(0xFFB32B44), // Màu chính (tương tự như trên)
                onPrimary: Colors.white, // Màu văn bản khi trên nền chính
                surface: Color(0xFF1C1C1C), // Màu nền của lịch (tối hơn)
                onSurface: Colors.white, // Màu văn bản trên nền
              ),
              buttonTheme: ButtonThemeData(
                textTheme: ButtonTextTheme.primary,
              ),
              dialogBackgroundColor: Color(0xFF1C1C1C), // Nền của hộp thoại
            ),
            child: child!,
          );
        },
      );
      if (pickedDate != null) {
        setState(() {
          _endDate = pickedDate;
        });
      }
    },
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF8C8C9D)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '${_endDate.day}/${_endDate.month}/${_endDate.year}',
          style: TextStyle(color: Colors.white,
           fontSize: 16,
           fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ),
),


              ],
            ),
            
      SizedBox(height: 20),
      Center(
        child:GestureDetector(
            onTap: () {
              showCategoryModal(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: _selectedCategoryColor, // Màu sắc mặc định nếu không có giá trị
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    _selectedCategoryIcon,
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(width: 14),
                  Text(
                    _selectedCategoryName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
            SizedBox(height: 20),
Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${_calculateDailySaving()}',
          style: TextStyle(
            color: Color(0xFFB32B44),
            fontSize: 45,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 4),
        Text(
          'VNĐ a day',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    ),

            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _addSaving,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB32B44),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'ADD SAVING PLAN',
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



