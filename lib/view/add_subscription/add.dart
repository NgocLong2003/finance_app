import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:trackizer/common/color_extension.dart';
import 'package:trackizer/common_widget/primary_button.dart';
import 'package:trackizer/common_widget/round_textfield.dart';
import '../../common_widget/image_button.dart';

import 'dart:math';
import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../common_widget/custom_arc_painter.dart';
import '../../common_widget/segment_button.dart';
import '../../common_widget/status_button.dart';
import '../../common_widget/subscription_home_row.dart';
import '../../common_widget/upcoming_bill_row.dart';
import '../settings/settings_view.dart';
import '../subscription_info/subscription_info_view.dart';
import '../add_subscription/add_outcome.dart';
import '../add_subscription/add_income.dart';
import '../add_subscription/add_saving.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddView extends StatefulWidget {
  const AddView({super.key});

  @override
  State<AddView> createState() => _AddViewState();
}

class _AddViewState extends State<AddView> {
  TextEditingController txtDescription = TextEditingController();
    bool isSavingPlans = true;



  List savingPlans = [
  {
    "title": "Emergency Fund",
    "currentAmount": 5000,
    "value": 10000,
    "categoryId": "assets/img/spotify_logo.png",
  },
  {
    "title": "Vacation",
    "currentAmount": 2000,
    "value": 5000,
    "categoryId": "assets/img/youtube_logo.png",
  },
];


List upcomingBills = [
  {
    "name": "Spotify",
    "date": DateTime(2023, 12, 10),
    "price": 5.99,
    "expenseType": "Monthly",
  },
  {
    "name": "NetFlix",
    "date": DateTime(2023, 12, 15),
    "price": 15.00,
    "expenseType": "Monthly",
  },
];



  List subArr = [
    {"name": "Spotify", "icon": "assets/img/spotify_logo.png", "price": "5.99"},
    {
      "name": "YouTube Premium",
      "icon": "assets/img/youtube_logo.png",
      "price": "18.99"
    },
    {
      "name": "Microsoft OneDrive",
      "icon": "assets/img/onedrive_logo.png",
      "price": "29.99"
    },
    {"name": "NetFlix", "icon": "assets/img/netflix_logo.png", "price": "15.00"}
  ];

  List bilArr = [
    {"name": "Spotify", "date": DateTime(2023, 07, 25), "price": "5.99"},
    {
      "name": "YouTube Premium",
      "date": DateTime(2023, 07, 25),
      "price": "18.99"
    },
    {
      "name": "Microsoft OneDrive",
      "date": DateTime(2023, 07, 25),
      "price": "29.99"
    },
    {"name": "NetFlix", "date": DateTime(2023, 07, 25), "price": "15.00"}
  ];

  Future<double> calculateTotalBalance() async {
  double totalBalance = 0.0;

  try {
    User? user = FirebaseAuth.instance.currentUser;
    // Truy cập vào collection "cards" của userId
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('cards')
        .get();

    // Lặp qua tất cả các card để cộng dồn balance
    for (var card in snapshot.docs) {
      final balance = card.data()['balance'] ?? 0.0; // Lấy giá trị balance
      totalBalance += balance;
    }
  } catch (e) {
    print("Error calculating total balance: $e");
  }

  return totalBalance;
}

  Future<List<Map<String, dynamic>>> getSavingPlans() async {
    List<Map<String, dynamic>> savingPlans = [];
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      // Truy cập vào collection savings của user
      QuerySnapshot savingsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('savings')
          .get();

      for (QueryDocumentSnapshot savingsDoc in savingsSnapshot.docs) {
        Map<String, dynamic> savingData = savingsDoc.data() as Map<String, dynamic>;

        // Truy cập vào categoryId từ saving
        String categoryId = savingData['categoryId'] ?? '';

      // Lấy thông tin category từ Firestore
      DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('category')
          .doc(categoryId)
          .get();

          if (categoryDoc.exists) {
            Map<String, dynamic> categoryData = categoryDoc.data() as Map<String, dynamic>;

            // Thêm dữ liệu vào savingPlans
            savingPlans.add({
              "title": savingData['title'],
              "currentAmount": savingData['currentAmount'],
              "value": savingData['value'],
              "icon": "assets/img/icloud.png", // Lấy icon từ category
              "price": "${NumberFormat('#,##0').format(savingData['currentAmount'])} / ${NumberFormat('#,##0').format(savingData['value'])} VNĐ",
            });
          }
        
      }
    } catch (e) {
      print("Error fetching saving plans: $e");
    }

    return savingPlans;
  }

  Future<List<Map<String, dynamic>>> _fetchUpcomingBills() async {
  List<Map<String, dynamic>> upcomingBills = [];
  DateTime now = DateTime.now();
  DateTime threeWeeksFromNow = now.add(Duration(days: 21));

  try {
    User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }
    QuerySnapshot outcomesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('outcomes')
        .get();

    for (QueryDocumentSnapshot outcomeDoc in outcomesSnapshot.docs) {
      Map<String, dynamic> outcomeData = outcomeDoc.data() as Map<String, dynamic>;

      // Check for "Monthly" or "Annual" expense type
      String expenseType = outcomeData['expenseType'] ?? '';
      if (expenseType == 'Monthly' || expenseType == 'Annual') {
        DateTime firstPaymentDate = (outcomeData['datetime'] as Timestamp).toDate();
        DateTime nextPaymentDate = DateTime.now();

        // Calculate the next payment date based on the expense type
        if (expenseType == 'Monthly') {
          nextPaymentDate = DateTime(now.year, now.month, firstPaymentDate.day);
          if (nextPaymentDate.isBefore(now)) {
            nextPaymentDate = DateTime(now.year, now.month + 1, firstPaymentDate.day);
          }
        } else if (expenseType == 'Annual') {
          nextPaymentDate = DateTime(now.year, firstPaymentDate.month, firstPaymentDate.day);
          if (nextPaymentDate.isBefore(now)) {
            nextPaymentDate = DateTime(now.year + 1, firstPaymentDate.month, firstPaymentDate.day);
          }
        }

        // Check if the next payment date is within 3 weeks from now
        if (nextPaymentDate.isAfter(now) && nextPaymentDate.isBefore(threeWeeksFromNow)) {
          
          print(outcomeData['title']);
          upcomingBills.add({
            "name": outcomeData['title'],
            "date": nextPaymentDate,
            "price": outcomeData['value'],
            "expenseType": expenseType,
          });
        }
      }
    }
    if(upcomingBills.isEmpty){
      throw Exception("upcomingBills Empty");
    }

  } catch (e) {
    print("Error fetching upcoming bills: $e");
  }

  return upcomingBills;
}

    @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: TColor.gray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: media.width * 0.65,
              decoration: BoxDecoration(
                  color: TColor.gray70.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25))),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Image.asset("assets/img/back.png",
                                    width: 25,
                                    height: 25,
                                    color: TColor.gray30))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "New",
                              style:
                                  TextStyle(color: TColor.gray30, fontSize: 16),
                            )
                          ],
                        ),
                      ],
                    ),
Padding(
  padding: const EdgeInsets.symmetric(vertical: 20),
  child: FutureBuilder<double>(
    future: calculateTotalBalance(), // Hàm lấy tổng số tiền
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text(
          "Loading...",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: TColor.white,
              fontSize: 40,
              fontWeight: FontWeight.w700),
        );
      } else if (snapshot.hasError) {
        return Text(
          "Error loading data",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: TColor.white,
              fontSize: 40,
              fontWeight: FontWeight.w700),
        );
      } else {
        final total = snapshot.data ?? 0.0;

        // Hiển thị tổng số tiền với định dạng VNĐ
        return Text(
          "${NumberFormat('#,##0').format(total)} VNĐ",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: TColor.white,
              fontSize: 40,
              fontWeight: FontWeight.w700),
        );
      }
    },
  ),
),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddOutcome() ));
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddIncome() ));
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddSaving() ));
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    

                  ],
                ),
              ),
            ),


Container(
  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  height: 50,
  decoration: BoxDecoration(
      color: Colors.black, borderRadius: BorderRadius.circular(15)),
  child: Row(
    children: [
      Expanded(
        child: SegmentButton(
          title: "Saving Plans",
          isActive: isSavingPlans,
          onPressed: () {
            setState(() {
              isSavingPlans = true;
            });
          },
        ),
      ),
      Expanded(
        child: SegmentButton(
          title: "Upcoming Bills",
          isActive: !isSavingPlans,
          onPressed: () {
            setState(() {
              isSavingPlans = false;
            });
          },
        ),
      )
    ],
  ),
),

if (isSavingPlans)

Container(
      height: 380, // Điều chỉnh chiều cao theo ý muốn
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: getSavingPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No saving plans found"));
          } else {
            List<Map<String, dynamic>> savingPlans = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: savingPlans.length,
              itemBuilder: (context, index) {
                var sObj = savingPlans[index] as Map? ?? {};
                return SubScriptionHomeRow(
                  sObj: {
                    "name": sObj["title"],
                    "icon": sObj["icon"],
                    "price": sObj["price"],
                  },
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscriptionInfoView(sObj: sObj),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
),

if (!isSavingPlans)
Container(
  height: 380, // Adjust height as needed
  child: FutureBuilder<List<Map<String, dynamic>>>(
    future: _fetchUpcomingBills(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text("Error: ${snapshot.error}"));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(child: Text("No upcoming bills"));
      } else {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var bill = snapshot.data![index];
            return UpcomingBillRow(
              sObj: {
                "name": bill["name"],
                "date": bill["date"],
                "price": "${NumberFormat('#,##0').format(bill["price"])} VNĐ",
              },
              onPressed: () {},
            );
          },
        );
      }
    },
  ),
),



          ],
        ),
      ),
    );
    
    }

}






