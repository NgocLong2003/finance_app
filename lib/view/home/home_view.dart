import 'package:flutter/material.dart';
import 'package:trackizer/common/color_extension.dart';

import '../../common_widget/custom_arc_painter.dart';
import '../../common_widget/segment_button.dart';
import '../../common_widget/status_button.dart';
import '../../common_widget/subscription_home_row.dart';
import '../../common_widget/upcoming_bill_row.dart';
import '../settings/settings_view.dart';
import '../subscription_info/subscription_info_view.dart';
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
      print("Hello");
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
        todayExpense = temptodayExpense;
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
                        "${NumberFormat('#,##0').format(todayExpense)}",
                        style: TextStyle(
                            color: TColor.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: media.width * 0.055,
                      ),
                      Text(
                        "Remaining: ${NumberFormat('#,##0').format(todayRemain)}",
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
                            "${NumberFormat('#,##0').format(totalBalance)}",
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
                                value: "${NumberFormat('#,##0').format(todayLimit)}",
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
                                value: "${NumberFormat('#,##0').format(recurringAmount)}",
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
                                value: "${NumberFormat('#,##0').format(dailySaving)}",
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
                  color: Colors.black, borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentButton(
                      title: "Your subscription",
                      isActive: isSubscription,
                      onPressed: () {
                        setState(() {
                          isSubscription = !isSubscription;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: SegmentButton(
                      title: "Upcoming bills",
                      isActive: !isSubscription,
                      onPressed: () {
                        setState(() {
                          isSubscription = !isSubscription;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            if (isSubscription)
              ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: subArr.length,
                  itemBuilder: (context, index) {
                    var sObj = subArr[index] as Map? ?? {};

                    return SubScriptionHomeRow(
                      sObj: sObj,
                      onPressed: () {

                        Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionInfoView( sObj: sObj ) ));
                      },
                    );
                  }),
            if (!isSubscription)
              ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: subArr.length,
                  itemBuilder: (context, index) {
                    var sObj = subArr[index] as Map? ?? {};

                    return UpcomingBillRow(
                      sObj: sObj,
                      onPressed: () {},
                    );
                  }),
            const SizedBox(
              height: 110,
            ),
          ],
        ),
      ),
    );
  }
}
