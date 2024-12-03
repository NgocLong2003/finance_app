import 'dart:math';

import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:trackizer/common/color_extension.dart';
import 'package:trackizer/view/settings/settings_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CardsView extends StatefulWidget {
  const CardsView({super.key});

  @override
  State<CardsView> createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  String? _selectedCardId;
  String? _userID;
  final SwiperController controller = SwiperController();

Stream<List<Map<String, dynamic>>> cardsStream() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return const Stream.empty();
  }
  _userID = user.uid;

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('cards')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      Timestamp? expiryTimestamp = doc['expiryDate'] as Timestamp?;
      String formattedDate = expiryTimestamp != null
          ? "${expiryTimestamp.toDate().day.toString().padLeft(2, '0')}/${expiryTimestamp.toDate().month.toString().padLeft(2, '0')}/${expiryTimestamp.toDate().year}"
          : "DD/MM/YYYY";

      return {
        "id": doc.id,
        "name": doc["name"] ?? "Unknown",
        "number": doc["number"] ?? "**** **** **** 0000",
        "type": doc["type"] ?? "Unknown",
        "balance": doc["balance"],
        "currency": doc["currency"],
        "bankName": doc["bankName"] ?? "Unknown",
        "expiryDate": formattedDate,
      };
    }).toList();
  });
}


 Widget buildSwiper(List<Map<String, dynamic>> cardList) {
    return StreamBuilder<List<Map<String, dynamic>>>(
    stream: cardsStream(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text("Error loading cards"));
      }

      final cardList = snapshot.data ?? [];
      if (cardList.isEmpty) {
        return Center(child: Text("No cards available"));
      }
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
      scale: 2,
      itemWidth: 232.0,
      itemHeight: 350,
      controller: controller,
      layout: SwiperLayout.STACK,
      viewportFraction: 0.8,
      itemBuilder: (context, index) {
        var card = cardList[index];
        _selectedCardId = card["id"] ?? "unknown_id";
        return GestureDetector(
          onTap: () => showEditModal(card),
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
    },
  );
}

  void showEditModal(Map<String, dynamic> card) {
  DateTime _selectedDate = DateTime.now();
  
  // Tạo các TextEditingController riêng cho từng field
  TextEditingController nameController = TextEditingController(text: card['name']);
  TextEditingController numberController = TextEditingController(text: card['number']);
  TextEditingController typeController = TextEditingController(text: card['type']);
  TextEditingController balanceController = TextEditingController(text: card['balance'].toString());
  TextEditingController currencyController = TextEditingController(text: card['currency']);
  TextEditingController bankNameController = TextEditingController(text: card['bankName']);

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: TColor.gray70.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Edit Card", style: TextStyle(fontSize: 18, color: Colors.white)),
                    IconButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .collection('cards')
                            .doc(card['id'])
                            .delete();
                        Navigator.pop(context);
                        setState(() {});
                      },
                      icon: Image.asset("assets/img/Trash.png", width: 24, height: 24),
                    ),
                  ],
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Card Name", labelStyle: TextStyle(color: Colors.white)),
                  controller: nameController,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(labelText: "Card Number", labelStyle: TextStyle(color: Colors.white)),
                  controller: numberController,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(labelText: "Card Type", labelStyle: TextStyle(color: Colors.white)),
                  controller: typeController,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(labelText: "Balance", labelStyle: TextStyle(color: Colors.white)),
                  controller: balanceController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number, // Đảm bảo nhập số
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(labelText: "Currency", labelStyle: TextStyle(color: Colors.white)),
                  controller: currencyController,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(labelText: "Bank Name", labelStyle: TextStyle(color: Colors.white)),
                  controller: bankNameController,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            primaryColor: Color(0xFFB32B44),
                            colorScheme: ColorScheme.dark(
                              primary: Color(0xFFB32B44),
                              onPrimary: Colors.white,
                              surface: Color(0xFF1C1C1C),
                              onSurface: Colors.white,
                            ),
                            dialogBackgroundColor: Color(0xFF1C1C1C),
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
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF8C8C9D)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                  SizedBox(height: 16),
                  Center(
                    child:ElevatedButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(_userID)
                            .collection('cards')
                            .doc(card['id'])
                            .update({
                          'name': nameController.text,
                          'number': numberController.text,
                          'type': typeController.text,
                          'balance': double.tryParse(balanceController.text) ?? card["balance"],
                          'currency': currencyController.text,
                          'bankName': bankNameController.text,
                          'expiryDate': _selectedDate,
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFB32B44),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'SAVE',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: TColor.gray,
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
              const SizedBox(
                  height: 300,
                ),
            //Card here
            Container(
              height: 450, // Điều chỉnh chiều cao theo ý muốn
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: cardsStream(), // Hàm lấy dữ liệu thẻ từ Firestore
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
            Column(
              children: [
                SafeArea(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Credit Cards",
                            style:
                                TextStyle(color: TColor.gray30, fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Spacer(),
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SettingsView()));
                              },
                              icon: Image.asset("assets/img/settings.png",
                                  width: 25, height: 25, color: TColor.gray30))
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 380,
                ),

                // Text(
                //   "Subscriptions",
                //   style: TextStyle(
                //       color: TColor.white,
                //       fontSize: 16,
                //       fontWeight: FontWeight.w600),
                // ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: subArr.map((sObj) {
                //     return Container(
                //       margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                //       child: Image.asset(
                //         sObj["icon"],
                //         width: 40,
                //         height: 40,
                //       ),
                //     );
                //   }).toList(),
                // ),

                const SizedBox(
                  height: 40,
                ),

                Container(
                  height: 100,
                  child: Column(children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            //card info here
                          },
                          child: DottedBorder(
                            dashPattern: const [5, 4],
                            strokeWidth: 1,
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(16),
                            color: TColor.border.withOpacity(0.1),
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Add new card",
                                    style: TextStyle(
                                        color: TColor.gray30,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(width: 10),
                                  Image.asset(
                                    "assets/img/add.png",
                                    width: 12,
                                    height: 12,
                                    color: TColor.gray30,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
