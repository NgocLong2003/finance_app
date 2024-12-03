import 'package:flutter/material.dart';
import 'package:trackizer/common/color_extension.dart';
import 'package:trackizer/view/home/all_transactions.dart';
import '../../common_widget/custom_arc_painter.dart';
import '../../common_widget/status_button.dart';
import '../../common_widget/transactions_row.dart';
import '../subscription_info/transactions_info_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isSubscription = true;
  double totalBalance = 0.0;
  double savingAmount = 0.0;
  double dailySaving = 0.0;
  double recurringAmount = 0.0;
  double balanceLimit = 0.0;
  double todayLimit = 0.0;
  double todayExpense = 0.0;
  double todayRemain = 0.0;
  double ratio = 270;

  @override
  void initState() {
    super.initState();
    _calculateDashboardValues();
  }
  Future<void> _calculateDashboardValues() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      DateTime now = DateTime.now();
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      double tempTotalBalance = 0.0;
      double tempSavingAmount = 0.0;
      double tempDailySaving = 0.0;
      double temprecurringAmount = 0.0;
      double temptodayExpense = 0.0;
      

      int daysInMonth = DateTime(now.year, now.month + 1, 0).day;

      // Tính toán Total Balance
      final cardSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('cards')
          .get();

      for (var card in cardSnapshot.docs) {
        final balance = card.data()['balance'] ?? 0.0;
        tempTotalBalance += balance;
      }

      // Tính toán Saving Amount và Daily Saving
      final savingSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('savings')
          .get();

      for (var saving in savingSnapshot.docs) {
        final startDate = (saving.data()['startDate'] as Timestamp).toDate();
        final endDate = (saving.data()['endDate'] as Timestamp).toDate();
        final value = saving.data()['value'] ?? 0.0;
        final currentAmount = saving.data()['currentAmount'] ?? 0.0;

        DateTime effectiveStartDate = startDate.isBefore(firstDayOfMonth)
            ? firstDayOfMonth
            : startDate;

        DateTime effectiveEndDate = endDate.isAfter(lastDayOfMonth)
            ? lastDayOfMonth
            : endDate;

        int totalDays_in_savingplan = endDate.isAfter(now)
            ? endDate.difference(now).inDays + 1
            : 0;

        int totalDays_in_month = effectiveEndDate
            .difference(effectiveStartDate)
            .inDays + 1;
        


        if (totalDays_in_savingplan > 0 && totalDays_in_month > 0) {
          double thisMonthSaving = ((value - currentAmount) /
                  totalDays_in_savingplan) *
              totalDays_in_month;
          tempSavingAmount += thisMonthSaving;

          double dailySavingValue = (value - currentAmount) /
              totalDays_in_savingplan;
          tempDailySaving += dailySavingValue;
        }
      }

      final recurringSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('outcomes')
        .get();

      for (var outcome in recurringSnapshot.docs) {
      final expenseType = outcome.data()['expenseType'];
      final price = outcome.data()['value'] ?? 0.0;
      final firstPaymentDate =
          (outcome.data()['datetime'] as Timestamp?)?.toDate();

      if (firstPaymentDate == null) continue;

      // Tính ngày trả phí tiếp theo nằm trong tháng này
      DateTime nextPaymentDate;

      if (expenseType == 'Monthly') {
        // Nếu là Monthly, ngày trả phí là ngày cố định hàng tháng
        int dayOfPayment = firstPaymentDate.day;
        nextPaymentDate = DateTime(now.year, now.month, dayOfPayment);

        // Nếu ngày trả phí đã qua, chuyển sang tháng kế tiếp
        if (nextPaymentDate.isBefore(firstDayOfMonth)) {
          nextPaymentDate = DateTime(now.year, now.month + 1, dayOfPayment);
        }
      } else if (expenseType == 'Annual') {
        // Nếu là Annual, ngày trả phí là ngày cố định hàng năm
        nextPaymentDate = DateTime(now.year, firstPaymentDate.month,
            firstPaymentDate.day);

        // Nếu ngày trả phí đã qua, chuyển sang năm kế tiếp
        if (nextPaymentDate.isBefore(firstDayOfMonth)) {
          nextPaymentDate = DateTime(now.year + 1, firstPaymentDate.month,
              firstPaymentDate.day);
        }
      } else {
        continue; // Bỏ qua các loại chi phí không phải Monthly hoặc Annual
      }

      // Chỉ cộng vào nếu ngày trả phí nằm trong tháng này
      if (nextPaymentDate.isAfter(firstDayOfMonth) &&
          nextPaymentDate.isBefore(lastDayOfMonth.add(const Duration(days: 1)))) {
        temprecurringAmount += price;
      }
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final expenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('outcomes')
        .where('datetime', isGreaterThanOrEqualTo: startOfDay, isLessThanOrEqualTo: endOfDay)
        .get();

    for (var expense in expenseSnapshot.docs) {
      final amount = expense.data()['value'] ?? 0.0;
      temptodayExpense += amount;
    }

    }

      // Cập nhật trạng thái với kết quả tính toán
      setState(() {
        totalBalance = tempTotalBalance;
        savingAmount = tempSavingAmount;
        dailySaving = tempDailySaving;
        recurringAmount = temprecurringAmount;
        balanceLimit = totalBalance - savingAmount - recurringAmount;
        todayLimit = balanceLimit / daysInMonth;
        todayExpense = temptodayExpense/2;
        todayRemain = todayLimit - todayExpense;
        ratio = (((todayExpense/todayLimit) * 270) > 270) ? 270 : ((todayExpense/todayLimit) * 270);

      });
    } catch (e) {
      print("Error calculating dashboard values: $e");
    }
  }

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

  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
  List<Map<String, dynamic>> transactions = [];

  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return transactions;

    // Lấy dữ liệu từ incomes
    final incomesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('incomes')
        .get();

    for (var incomeDoc in incomesSnapshot.docs) {
      final incomeData = incomeDoc.data();
      
      String categoryId = incomeData['categoryId'] ?? '';
      print(incomeData['title']);
      print(incomeData['categoryId']);

      //Lấy thông tin category từ Firestore
      DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('category')
          .doc(categoryId)
          .get();
      
      Map<String, dynamic> categoryData = categoryDoc.data() as Map<String, dynamic>;

      transactions.add({
        "id": incomeDoc.id,
        "type": "income",
        "title": incomeData['title'] ?? "",
        "description": incomeData['description'] ?? " ",
        "category": categoryData['name'] ?? " ",
        "icon": "assets/img/icloud.png",// categoryData["icon"],
        "cardId": incomeData['cardId'],
        "datetime": (incomeData['datetime'] as Timestamp).toDate(),
        "value": incomeData['value'] ?? 0.0,
        "unit": incomeData['unit'] ?? "VND",
        "isRecurring": incomeData['isRecurring'] ?? false,
        "source": incomeData['source'],
      });
    }

    // Lấy dữ liệu từ outcomes
    final outcomesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('outcomes')
        .get();

    for (var outcomeDoc in outcomesSnapshot.docs) {
      final outcomeData = outcomeDoc.data();
      String categoryId = outcomeDoc['categoryId'] ?? '';
      print(outcomeDoc['title']);
      print(outcomeDoc['categoryId']);

      //Lấy thông tin category từ Firestore
      DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('category')
          .doc(categoryId)
          .get();
      
      Map<String, dynamic> categoryData = categoryDoc.data() as Map<String, dynamic>;
      transactions.add({
        "id": outcomeDoc.id,
        "type": "outcome",
        "title": outcomeData['title'] ?? " ",
        "description": outcomeData['description'] ?? " ",
        "category": categoryData['name'] ?? " ",
        "icon": "assets/img/icloud.png",// categoryData["icon"],
        "cardId": outcomeData['cardId'],
        "datetime": (outcomeData['datetime'] as Timestamp).toDate(),
        "value": outcomeData['value'] ?? 0.0,
        "unit": outcomeData['unit'] ?? "VND",
        "expenseType": outcomeData['expenseType'],
      });

      
    }

    // Sắp xếp giao dịch theo ngày (mới nhất -> cũ nhất)
    transactions.sort((a, b) => (b['datetime'] as DateTime).compareTo(a['datetime'] as DateTime));
  } catch (e) {
    print("Error fetching transactions: $e");
  }

  return transactions;
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
              height: media.width * 1.1,
              decoration: BoxDecoration(
                  color: TColor.gray70.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25))),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/img/home_bg.png"),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        padding:  EdgeInsets.only(bottom: media.width * 0.05),
                        width: media.width * 0.72,
                        height: media.width * 0.72,
                        child: CustomPaint(
                          painter: CustomArcPainter(end: ratio, ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Image.asset("assets/img/app_logo.png",
                          width: media.width * 0.25, fit: BoxFit.contain),
                       SizedBox(
                        height: media.width * 0.07,
                      ),
                      Text(
                        "${NumberFormat('#,##0').format(todayExpense)} ₫",
                        style: TextStyle(
                            color: TColor.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: media.width * 0.055,
                      ),
                      Text(
                        "Remaining: ${NumberFormat('#,##0').format(todayRemain)} ₫",
                        style: TextStyle(
                            color: TColor.gray40,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: media.width * 0.07,
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: TColor.border.withOpacity(0.15),
                            ),
                            color: TColor.gray60.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "${NumberFormat('#,##0').format(totalBalance)} ₫",
                            style: TextStyle(
                                color: TColor.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: StatusButton(
                                title: "Limit today",
                                value: "${NumberFormat('#,##0').format(todayLimit)} ₫",
                                statusColor: TColor.secondary,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: StatusButton(
                                title: "Recurring",
                                value: "${NumberFormat('#,##0').format(recurringAmount)} ₫",
                                statusColor: TColor.primary10,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: StatusButton(
                                title: "Saving today",
                                value: "${NumberFormat('#,##0').format(dailySaving)} ₫",
                                statusColor: TColor.secondaryG,
                                onPressed: () {},
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
Container(
  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  height: 50,
  decoration: BoxDecoration(
      color: TColor.gray70, borderRadius: BorderRadius.circular(15)),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Tách đều 2 bên
    children: [
      // Chữ "Transactions" ở lề trái
      Text(
        "Transactions",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      // Chữ "See all" ở lề phải
      GestureDetector(
        onTap: () {
          // Hành động khi bấm vào "See all"
          Navigator.push(context, MaterialPageRoute(builder: (context) => AllTransactions() ));
          print("All transactions");
        },
        child: Text(
          "See all",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
),

Container(
      height: 380, // Điều chỉnh chiều cao theo ý muốn
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No transactions found"));
          } else {
            List<Map<String, dynamic>> transactions = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                var sObj = transactions[index] as Map? ?? {};
                return TransactionRow(
                  sObj: {
                    "type": sObj["type"],
                    "title": sObj["title"],
                    "icon": sObj["icon"],
                    "value": sObj["value"],
                    "datetime": sObj["datetime"],
                  },
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionsInfoView(sObj: {
                    "id": sObj["id"],
                    "type": sObj["type"],
                    "title": sObj["title"],
                    "icon": sObj["icon"],
                    "value": sObj["value"],
                    "category": sObj["category"],
                    "datetime": sObj["datetime"],
                    "description": sObj["description"],
                    "currency": sObj["unit"],
                    "expenseType": sObj["expenseType"],
                  },),
                        
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

      SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }
}
