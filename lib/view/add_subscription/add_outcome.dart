import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';

class AddOutcome extends StatefulWidget {
  @override
  _AddOutcomeState createState() => _AddOutcomeState();
}

class _AddOutcomeState extends State<AddOutcome> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  String? _selectedCardId;
  String? _selectedCategoryId;
  String? _selectedExpenseType;
  String _selectedCategoryName = 'Category'; // Giá trị mặc định
  String _selectedCategoryIcon = 'assets/img/icloud.png'; // Icon mặc định
  Color? _selectedCategoryColor;
  final user = FirebaseAuth.instance.currentUser;
  String _selectedCategory = 'Category';
  DateTime _selectedDate = DateTime.now();

Future<void> _addOutcome() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    final outcomeDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('outcomes')
          .doc();

    await outcomeDoc.set({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'categoryId': _selectedCategoryId,
      'cardId': _selectedCardId,
      'datetime': _selectedDate ?? DateTime.now(),
      'value': double.tryParse(_valueController.text) ?? 0.0,
      'expenseType': _selectedExpenseType,
      'unit': "VND",
    });

    // 2. Cập nhật balance của thẻ trong Firestore
    final cardDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('cards')
        .doc(_selectedCardId);

    // Lấy thông tin hiện tại của thẻ để cập nhật balance
    DocumentSnapshot cardSnapshot = await cardDoc.get();
    if (cardSnapshot.exists) {
      double currentBalance = (cardSnapshot['balance'] ?? 0.0).toDouble();
      double substractedValue = double.tryParse(_valueController.text) ?? 0.0;

      double newBalance = currentBalance - substractedValue;

      // Cập nhật balance mới cho thẻ
      await cardDoc.update({
        'balance': newBalance,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Outcome added and card balance updated successfully')),
    );

    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error adding income: $e')),
    );
  }
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

  final SwiperController controller = SwiperController();

  Future<List<Map<String, dynamic>>> fetchCardsFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Truy vấn dữ liệu từ Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cards')
          .where('available', isEqualTo: "available")
          .get();

      // Chuyển đổi dữ liệu
      List<Map<String, dynamic>> cardList = snapshot.docs.map((doc) {
        // Lấy timestamp và chuyển đổi sang định dạng MM/YY
        Timestamp? expiryTimestamp = doc['expiryDate'] as Timestamp?;
        String formattedDate = expiryTimestamp != null
            ? "${expiryTimestamp.toDate().month.toString().padLeft(2, '0')}/${expiryTimestamp.toDate().year.toString().substring(2)}"
            : "00/00";

        return {
          "id": doc.id,
          "name": doc["name"] ?? "Unknown", // Tên thẻ
          "number": doc["number"] ?? "**** **** **** 0000", // Số thẻ
          "balance": doc["balance"],
          "currency": doc["currency"],
          "expiryDate": formattedDate, // Ngày hết hạn
        };
      }).toList();

      print("Fetched cards: $cardList"); // Ghi log để kiểm tra dữ liệu
      return cardList;
    } catch (e) {
      print("Error fetching cards: $e");
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

  Widget buildSwiper(List<Map<String, dynamic>> cardList) {
    return Swiper(
      itemCount: cardList.length,
      customLayoutOption: CustomLayoutOption(startIndex: -1, stateCount: 3)
        ..addRotate([-45.0 / 180, 0.0, 45.0 / 180])
        ..addTranslate([
          const Offset(-370.0, -40.0),
          Offset.zero,
          const Offset(370.0, -40.0),
        ]),
      fade: 1.0,
      onIndexChanged: (index) {
        print("Current index: $index");
        
      },
      scale: 0.8,
      itemWidth: 232.0,
      itemHeight: 350,
      controller: controller,
      layout: SwiperLayout.STACK,
      viewportFraction: 0.8,
      itemBuilder: (context, index) {
        var card = cardList[index];
        _selectedCardId = card["id"] ?? "unknown_id";
        return Container(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                "assets/img/card_blank.png",
                width: 232.0,
                height: 350,
              ),
              Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset("assets/img/mastercard_logo.png", width: 50),
                  const SizedBox(height: 8),
                  Text(
                    "Virtual Card",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "${NumberFormat('#,##0').format(card["balance"])} ${card["currency"]}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 80),
                  Text(
                    card["name"] ?? "Nguyen Ngoc Long",
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card["number"] ?? "**** **** **** 2197",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card["expiryDate"] ?? "08/27",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
          "NEW EXPENSE",
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
                hintText: 'TITLE EXPENSE*',
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

            TextField(
              controller: _descriptionController,
              style: TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center, // Căn giữa nội dung chữ
              decoration: InputDecoration(
                hintText: 'Description your outcome',
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
            SizedBox(height: 10),

            //Card here
            Container(
              height: 340, // Điều chỉnh chiều cao theo ý muốn
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchCardsFromFirestore(), // Hàm lấy dữ liệu thẻ từ Firestore
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // Hiển thị trạng thái đang tải
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}"), // Hiển thị lỗi nếu có
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text("No cards found"), // Hiển thị nếu không có dữ liệu
                    );
                  } else {
                    // Nếu dữ liệu đã sẵn sàng, gọi hàm buildSwiper với dữ liệu
                    return buildSwiper(snapshot.data!);
                  }
                },
              ),
            ),


            SizedBox(height: 10),
            TextField(
              controller: _valueController,
              style: TextStyle(color: Colors.white, fontSize: 40),
              textAlign: TextAlign.center, // Căn giữa nội dung chữ
              decoration: InputDecoration(
                hintText: '0,000 VNĐ',
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
            
            SizedBox(height: 10),

   Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Expense Type',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

    SizedBox(height: 8),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nút "Single - One"
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedExpenseType = 'Single - One';
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _selectedExpenseType == 'Single - One'
                    ? Color(0xFFB32B44) // Màu khi được chọn
                    : Color(0xFF2C2C2E), // Màu mặc định
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Single - One',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        // Nút "Monthly"
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedExpenseType = 'Monthly';
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _selectedExpenseType == 'Monthly'
                    ? Color(0xFFB32B44)
                    : Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Monthly',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        // Nút "Annual"
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedExpenseType = 'Annual';
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _selectedExpenseType == 'Annual'
                    ? Color(0xFFB32B44)
                    : Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Annual',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ],
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
          _selectedDate = pickedDate;
        });
      }
    },
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF8C8C9D)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          style: TextStyle(color: Colors.white,
           fontSize: 16,
           fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ),
),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    showCategoryModal(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                          width: 28,
                          height: 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _selectedCategoryName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),


 

            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _addOutcome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB32B44),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'ADD EXPENSE',
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



