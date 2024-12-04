import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trackizer/common/color_extension.dart';
import 'package:trackizer/common_widget/budgets_row.dart';
import 'package:trackizer/common_widget/custom_arc_180_painter.dart';
import 'package:intl/intl.dart';
import '../settings/settings_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackizer/common/color_extension.dart';


class SpendingBudgetsView extends StatefulWidget {
 const SpendingBudgetsView({super.key});


 @override
 State<SpendingBudgetsView> createState() => _SpendingBudgetsViewState();
}

Color getColorForExpenseType(String expenseType) {
  // Danh sách các loại chi phí và màu sắc tương ứng
  final expenseColors = {
    "Salary": "#FF5733",
    "Business": "#33FF57",
    "Investments": "#33A3FF",
    "Rent": "#FF3355",
    "Food": "#55FF33",
    "Utilities": "#3355FF",
    "Transportation": "#FFB300",
    "Entertainment": "#E91E63",
    "Shopping": "#8E44AD",
    "Healthcare": "#2ECC71",
    "Education": "#1ABC9C",
    "Insurance": "#C0392B",
    "Taxes": "#D35400",
    "Gifts": "#F1C40F",
    "Loans": "#2980B9",
    "Subscriptions": "#27AE60",
    "Repairs": "#8E44AD",
    "Grocery": "#F39C12",
    "Mobile": "#C0392B",
    "Travel": "#3498DB",
    "Miscellaneous": "#9B59B6",
    "Charity": "#1ABC9C",
    "Hobbies": "#F1C40F",
  };

  // Lấy mã màu từ danh sách hoặc mặc định là màu xám nếu không tìm thấy
  String hexColor = expenseColors[expenseType] ?? "#FF5733";

  // Chuyển đổi mã hex thành Color
  return _hexToColor(hexColor);
}

// Hàm chuyển đổi mã hex (#RRGGBB) thành Color
Color _hexToColor(String hexColor) {
  // Loại bỏ ký tự # nếu có
  hexColor = hexColor.replaceAll('#', '');
  return Color(int.parse("0xFF$hexColor"));
}



String getWeekdayLabel(int dayIndex) {
 List<String> weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
 return weekdays[(dayIndex - 1) % 7];
}




class MyWidget extends StatefulWidget {
 @override
 _SpendingBudgetsViewState createState() => _SpendingBudgetsViewState();
}


class _SpendingBudgetsViewState extends State<SpendingBudgetsView> {
 PageController _pageController = PageController(initialPage: 0);
 int currentWeekIndex = 0; // Track the current week index
   // New data structure for weeks
 Map<int, Map<int, Map<String, double>>> weeklyData = {};
 List<Map<String, dynamic>> newBudgetArr = [];


 @override
 void initState() {
   super.initState();
   _initializeData();
   
 }
 Future<void> _initializeData() async {
  try {
    // Sử dụng 'await' để gọi hàm async
    newBudgetArr = await _getnewBudgetArr();
           if (newBudgetArr.isNotEmpty) {
         for (var item in newBudgetArr) {
           DateTime date = item["datetime"];
           print(date);


           int weekOfYear = _getWeekOfYear(date); // You can implement this using any package like 'intl' to get week number
           int weekday = date.weekday; // 1 for Monday, 7 for Sunday
           print(weekOfYear);
           print(weekday);
           // Initialize the week and weekday data structure if not already present
           if (!weeklyData.containsKey(weekOfYear)) {
             weeklyData[weekOfYear] = {};
           }
           if (!weeklyData[weekOfYear]!.containsKey(weekday)) {
             weeklyData[weekOfYear]![weekday] = {};
           }


           String expenseType = item["category"];
           double value = (item["value"] as num).toDouble();


           // Add the value to the respective weekday's expense type
           if (!weeklyData[weekOfYear]![weekday]!.containsKey(expenseType)) {
             weeklyData[weekOfYear]![weekday]![expenseType] = 0.0;
           }


           weeklyData[weekOfYear]![weekday]![expenseType] =
             weeklyData[weekOfYear]![weekday]![expenseType]! + value;


           print("weeklyData : ${weeklyData}");
         }
      }
    setState(() {
      // Cập nhật trạng thái hoặc giao diện khi cần
    });
  } catch (e) {
    print("Error initializing data: $e");
  }
}
 // Process data to group by weekå


int _getWeekOfYear(DateTime date) {
 // Get the first day of the year
 DateTime firstDayOfYear = DateTime(date.year, 1, 1);
  // Calculate the difference in days between the given date and the first day of the year
 int daysDifference = date.difference(firstDayOfYear).inDays;


 // Calculate the week number
 return (daysDifference / 7).floor() + 1;
}



//  List<Map<String, dynamic>> newBudgetArr = [
//    {
//      "id": "1",
//      "title": "Car Maintenance",
//      "description": "Monthly car servicing expenses",
//      "value": 200.50,
//      "unit": "USD",
//      "datetime": DateTime(2024, 11, 25),
//      "expenseType": "Auto",
//      "priority": "High",
//      "dueDate": DateTime(2024, 12, 15),
//      "isEssential": true,
//      "cardID": "CAR1234",
//      "categoryID": "CAT_AUTO"
//    },
//    {
//      "id": "2",
//      "title": "Movie Night",
//      "description": "Entertainment budget for cinema outings",
//      "value": 50.99,
//      "unit": "USD",
//      "datetime": DateTime(2024, 11, 20),
//      "expenseType": "Entertainment",
//      "priority": "Medium",
//      "dueDate": DateTime(2024, 12, 01),
//      "isEssential": false,
//      "cardID": "MOV1234",
//      "categoryID": "CAT_ENTERTAINMENT"
//    },
//    {
//      "id": "3",
//      "title": "Home Security Subscription",
//      "description": "Monthly payment for home security services",
//      "value": 45.00,
//      "unit": "USD",
//      "datetime": DateTime(2024, 11, 18),
//      "expenseType": "Security",
//      "priority": "High",
//      "dueDate": DateTime(2024, 12, 10),
//      "isEssential": true,
//      "cardID": "SEC1234",
//      "categoryID": "CAT_SECURITY"
//    },
//    {
//      "id": "4",
//      "title": "Groceries",
//      "description": "Weekly household food supplies",
//      "value": 100.75,
//      "unit": "USD",
//      "datetime": DateTime(2024, 11, 22),
//      "expenseType": "Food",
//      "priority": "Medium",
//      "dueDate": DateTime(2024, 11, 29),
//      "isEssential": true,
//      "cardID": "GRO1234",
//      "categoryID": "CAT_FOOD"
//    },
//    {
//      "id": "5",
//      "title": "Gym Membership",
//      "description": "Monthly subscription for fitness center",
//      "value": 30.00,
//      "unit": "USD",
//      "datetime": DateTime(2024, 11, 15),
//      "expenseType": "Health",
//      "priority": "Low",
//      "dueDate": DateTime(2024, 11, 30),
//      "isEssential": false,
//      "cardID": "GYM1234",
//      "categoryID": "CAT_HEALTH"
//    },
//    {
//      "id": "6",
//      "title": "Spotify",
//      "description": "Monthly car servicing expenses",
//      "value": 100.00,
//      "unit": "USD",
//      "datetime": DateTime(2024, 11, 25),
//      "expenseType": "Entertainment",
//      "priority": "High",
//      "dueDate": DateTime(2024, 12, 15),
//      "isEssential": true,
//      "cardID": "CAR1234",
//      "categoryID": "CAT_AUTO"
//    }
//  ];

  Future<List<Map<String, dynamic>>> _getnewBudgetArr() async {
  List<Map<String, dynamic>> transactions = [];

  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return transactions;
      // Lấy dữ liệu từ outcomes
      final outcomesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('outcomes')
          .get();

      for (var outcomeDoc in outcomesSnapshot.docs) {
        final outcomeData = outcomeDoc.data();
        String categoryId = outcomeDoc['categoryId'] ?? '';

        //Lấy thông tin category từ Firestore
        DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('category')
            .doc(categoryId)
            .get();
        
        Map<String, dynamic> categoryData = categoryDoc.data() as Map<String, dynamic>;
        categoryData['color'] = "0xFF"+ categoryData['color'];
        transactions.add({
          "id": outcomeDoc.id,
          "type": "outcomes",
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


 List card = [
   {
     "id": "11ea",
     "name":"VPbank",
     "balance":"1200",
     "currency":"USD"
   }
 ];


 // Calculate the maximum value across all weeks
double getMaxY(Map<int, Map<int, Map<String, double>>> weeklyData) {
 double maxY = 0;


 for (var weekData in weeklyData.values) {
   for (var dayData in weekData.values) {
     for (var value in dayData.values) {
       if (value > maxY) {
         maxY = value;
       }
     }
   }
 }


 return maxY;
}




 @override
 Widget build(BuildContext context) {
   print(weeklyData);
   double maxY = getMaxY(weeklyData);


   var media = MediaQuery.sizeOf(context);
   return Scaffold(
     backgroundColor: TColor.gray,
     body: SingleChildScrollView(
       child: Stack(
         children:[
         Positioned(
           top: media.width * -1.585,  // Adjust to position circle
           left: media.width * -0.5,   // Adjust to center horizontally
           child: Container(
             width: media.width * 2,   // Circle size
             height: media.width * 2,  // Circle size
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: const Color(0xFF22222B).withOpacity(1),  // Semi-transparent circle
             ),
           ),
         ),


                // Circle overlay
         Positioned(
           top: media.width * -1.6,  // Adjust to position circle
           left: media.width * -0.5,   // Adjust to center horizontally
           child: Container(
             width: media.width * 2,   // Circle size
             height: media.width * 2,  // Circle size
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: const Color(0xFF282834).withOpacity(1),  // Semi-transparent circle
             ),
           ),
         ),


       Column(
         children: [
           Padding(
             padding: const EdgeInsets.only(top: 35, right: 10),
             child: Row(
               children: [
                 const Spacer(),
                 IconButton(
                     onPressed: () {
                       Navigator.push(
                           context,
                           MaterialPageRoute(
                               builder: (context) => const SettingsView()));
                     },
                     icon: Image.asset("assets/img/settings.png",
                         width: 25, height: 25, color: TColor.gray30))
               ],
             ),
           ),


           //Balance box
 Padding(
 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
 child: InkWell(
   borderRadius: BorderRadius.circular(16),
   onTap: () {},
   child: Container(
     padding: const EdgeInsets.all(12), // Padding inside the box
     decoration: BoxDecoration(
       color: Color.fromARGB(255, 23, 23, 26), // Background color
       border: Border.all(
         color: TColor.border.withOpacity(0.1), // Border with slight opacity
       ),
       borderRadius: BorderRadius.circular(16),
     ),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         // Title Section
         Text(
           "Your balance",
           style: TextStyle(
             color: TColor.white,
             fontWeight: FontWeight.bold,
             fontSize: 11,
           ),
         ),
         const SizedBox(height: 15), // Space between title and balance
         // Current Balance Section
         Row(
           children: [
             Text(
               "\$${card[0]['balance']}", // Displaying balance with "$" prefix
               style: TextStyle(
                 color: TColor.white,
                 fontWeight: FontWeight.bold,
                 fontSize: 24, // Balance text size
               ),
             ),
             const SizedBox(width: 4), // Small space before currency
             Text(
               card[0]['currency'], // Displaying currency
               style: TextStyle(
                 color: TColor.white.withOpacity(0.7), // Lighter text for currency
                 fontSize: 14,
               ),
             ),
           ],
         ),
         const SizedBox(height: 15),
       ],
     ),
   ),
 ),
),


           const SizedBox(height: 20),
          
 Padding(
 padding: const EdgeInsets.symmetric(horizontal: 20), // Adjust horizontal padding as needed
 child: Container(
   alignment: Alignment.centerLeft,
   child: Text(
     "Analysis", // Text content
     style: TextStyle(
       color: TColor.white,
       fontWeight: FontWeight.bold,
       fontSize: 21,
     ),
   ),
 ),
),




Padding(
 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
 child: InkWell(
   borderRadius: BorderRadius.circular(16),
   onTap: () {},
   child: Container(
     padding: const EdgeInsets.all(12), // Adjusted for full content visibility
     decoration: BoxDecoration(
       color: Color.fromARGB(255, 23, 23, 26),
       border: Border.all(
         color: TColor.border.withOpacity(0.1),
       ),
       borderRadius: BorderRadius.circular(16),
     ),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         // Title Section
         Padding(
           padding: const EdgeInsets.only(bottom: 8.0), // Spacing between title and chart
           child: Text(
             "Costs",
             style: TextStyle(
               color: TColor.white,
               fontWeight: FontWeight.bold,
               fontSize: 16,
             ),
           ),
         ),
         // Stacked Bar Chart Section
         SizedBox(
 height: MediaQuery.sizeOf(context).width * (3 / 7), // Keeps chart sizing consistent
 child: PageView.builder(
   controller: _pageController,
   itemCount: weeklyData.keys.length, // Number of weeks
   reverse: true, // Reverse swiping direction
   onPageChanged: (index) {
     setState(() {
       currentWeekIndex = index; // Update the current week index when swiped
     });
   },
   itemBuilder: (context, weekIndex) {
     List<int> descendingWeeks = weeklyData.keys.toList()..sort((a, b) => b.compareTo(a));
     int weekNumber = descendingWeeks[weekIndex];


     Map<int, Map<String, double>> chartData = weeklyData[weekNumber] ?? {};


     // Calculate the total sum of all expenses for the current week
     double maxTotalExpense = 0;
     for (var week in weeklyData.values) {
       for (var dayData in week.values) {
         double weekTotalExpense = dayData.values.fold(0.0, (sum, expense) => sum + expense);
         if (weekTotalExpense > maxTotalExpense) {
           maxTotalExpense = weekTotalExpense;
         }
       }
     }


     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
       child: BarChart(
         BarChartData(
           maxY: maxTotalExpense, // Set maxY to the maximum total expense across all weeks
           barGroups: List.generate(7, (day) {
             Map<String, double> expenses = chartData[day] ?? {};


             double currentStackHeight = 0; // Keeps track of the current height of the stack


             return BarChartGroupData(
               x: day,
               barRods: [
                 BarChartRodData(
                   fromY: 0,
                   toY: expenses.values.fold(0.0, (total, value) => total + value), // Sum of all expenses for the day
                   rodStackItems: expenses.entries.map((expenseEntry) {
                     double start = currentStackHeight;
                     double end = start + expenseEntry.value;
                     currentStackHeight = end;


                     return BarChartRodStackItem(
                       start,
                       end,
                       getColorForExpenseType(expenseEntry.key),
                     );
                   }).toList(),
                   width: 16,
                   borderRadius: BorderRadius.only(
                     topLeft: Radius.circular(5),
                     topRight: Radius.circular(5),
                   ),
                 ),
               ],
             );
           }),
           titlesData: FlTitlesData(
             bottomTitles: AxisTitles(
               sideTitles: SideTitles(
                 showTitles: true,
                 getTitlesWidget: (value, meta) {
                   return Text(
                     getWeekdayLabel(value.toInt()), // Use the getWeekdayLabel method
                     style: TextStyle(
                       color: TColor.white,
                       fontWeight: FontWeight.bold,
                     ),
                   );
                 },
               ),
             ),
             leftTitles: AxisTitles(
               sideTitles: SideTitles(
                 showTitles: true,
                 getTitlesWidget: (value, meta) {
                 if (value % 50 == 0 || value == 0) {
                   String displayValue;


                   if (value >= 1000000) {
                     displayValue = '${(value / 1000000).toStringAsFixed(1)}M';
                   } else if (value >= 1000) {
                     displayValue = '${(value / 1000).toStringAsFixed(1)}k';
                   } else {
                     displayValue = '\$${value.toInt()}';
                   }


                   return Text(
                     displayValue,
                     style: TextStyle(
                       color: TColor.white,
                       fontWeight: FontWeight.bold,
                       fontSize: 9,
                     ),
                     softWrap: false,
                     overflow: TextOverflow.visible,
                   );
                 }
                 return const SizedBox.shrink();
               },


               ),
             ),
             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
           ),
           borderData: FlBorderData(
             border: Border.all(color: TColor.border.withOpacity(0.2)),
             show: false,
           ),
           gridData: FlGridData(
             show: true,
             drawVerticalLine: false,
             drawHorizontalLine: true,
             horizontalInterval: 50,
             getDrawingHorizontalLine: (value) {
               return FlLine(
                 color: TColor.white.withOpacity(0.3),
                 strokeWidth: 1,
                 dashArray: [4, 0],
               );
             },
             checkToShowHorizontalLine: (value) => value % 50 == 0 || value == 0,
           ),
         ),
       ),
     );
   },
 ),
),


         const SizedBox(height: 16),
         // Legend Section
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 8),
           child: Column(
             children: buildLegendForCurrentWeek(),
           ),
         ),
       ],
     ),
   ),
 ),
),


//Donut chart
Padding(
 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
 child: InkWell(
   borderRadius: BorderRadius.circular(16),
   onTap: () {}, // Add action if needed
   child: Container(
     padding: const EdgeInsets.all(12), // Adjusted to ensure full chart visibility
     decoration: BoxDecoration(
       color: Color.fromARGB(255, 23, 23, 26), // Same background color as the bar chart
       border: Border.all(
         color: TColor.border.withOpacity(0.1), // Matching border color
       ),
       borderRadius: BorderRadius.circular(16), // Same border radius
     ),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         // Title Section
         Padding(
           padding: const EdgeInsets.only(bottom: 8.0), // Spacing between title and chart
           child: Text(
             "Categories",
             style: TextStyle(
               color: TColor.white,
               fontWeight: FontWeight.bold,
               fontSize: 16,
             ),
           ),
         ),
         // Snail Donut Chart Section
         SizedBox(
           height: MediaQuery.sizeOf(context).width * (3 / 7) + 20, // Adjusted height for better fit
           child: PageView.builder(
             controller: _pageController, // Using the same PageController for both charts
             itemCount: weeklyData.keys.length, // Number of weeks
             reverse: true, // Reverse swiping direction
             onPageChanged: (index) {
               setState(() {
                 currentWeekIndex = index; // Update the current week index when swiped
               });
             },
             itemBuilder: (context, weekIndex) {
               // Sort the weeks in descending order
               List<int> descendingWeeks = weeklyData.keys.toList()..sort((a, b) => b.compareTo(a));
               int weekNumber = descendingWeeks[weekIndex]; // Get the week number


               // Get the data for the current week
               Map<int, Map<String, double>> chartData = weeklyData[weekNumber] ?? {};


               // Calculate the total sum of all expenses for the current week
               double totalExpenseForCurrentWeek = chartData.values.fold(0.0, (sum, dayData) {
                 return sum + dayData.values.fold(0.0, (daySum, expense) => daySum + expense);
               });


               // Prepare data for the snail donut chart (PieChartSectionData)
               List<PieChartSectionData> sections = chartData.values.expand((dayData) {
                 return dayData.entries.map((expenseEntry) {
                   String expenseType = expenseEntry.key;
                   double value = expenseEntry.value;
                   double percentage = value / totalExpenseForCurrentWeek * 100;


                   return PieChartSectionData(
                     value: percentage,
                     color: getColorForExpenseType(expenseEntry.key), // Function to return color
                     radius: 40 + (percentage * 0.5), // Radius grows with percentage for snail effect
                     title: '${percentage.toStringAsFixed(1)}%',
                     titleStyle: TextStyle(
                       fontSize: 14,
                       fontWeight: FontWeight.bold,
                       color: TColor.white, // Text color for percentage
                     ),
                   );
                 });
               }).toList();


               return PieChart(
                 PieChartData(
                   sectionsSpace: 2, // Space between sections for better snail effect
                   centerSpaceRadius: 20, // Smaller center for snail-like appearance
                   startDegreeOffset: 180, // Adjusted starting angle
                   sections: sections,
                 ),
               );
             },
           ),
         ),
       ],
     ),
   ),
 ),
),


           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
             child: InkWell(
               borderRadius: BorderRadius.circular(16),
               onTap: () {},
               child: Container(
                 height: 64,
                 padding: const EdgeInsets.all(10),
                 decoration: BoxDecoration(
                   border: Border.all(
                     color: TColor.border.withOpacity(0.1),
                   ),
                   borderRadius: BorderRadius.circular(16),
                 ),
                 alignment: Alignment.center,
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text(
                       "Your budgets are on track 👍",
                       style: TextStyle(
                           color: TColor.white,
                           fontSize: 14,
                           fontWeight: FontWeight.w600),
                     ),
                   ],
                 ),
               ),
             ),
           ),
          
           const SizedBox(
             height: 110,
           ),
         ],
       ),
       
       ])
     ),
   );
 }




 // Group data by weekday
 Map<int, Map<String, double>> processChartData() {
   Map<int, Map<String, double>> weeklyData = {};


   for (var item in newBudgetArr) {
     DateTime date = item["datetime"];
     int weekday = date.weekday; // 1 for Monday, 7 for Sunday


     if (!weeklyData.containsKey(weekday)) {
       weeklyData[weekday] = {};
     }


     String expenseType = item["expenseType"];
     double value = item["value"];


     if (!weeklyData[weekday]!.containsKey(expenseType)) {
       weeklyData[weekday]![expenseType] = 0.0;
     }


     weeklyData[weekday]![expenseType] = weeklyData[weekday]![expenseType]! + value;
   }


   return weeklyData;
 }


 Map<int, Map<String, double>> processChartDataWithAllDays() {
   Map<int, Map<String, double>> chartData = {};
  
   // Initialize all days (0 to 6 for Sun to Sat) with empty maps
   for (int i = 0; i < 7; i++) {
     chartData[i] = {}; // Make sure each day has its own map
   }
  
   // Fill in actual data
   newBudgetArr.forEach((entry) {
     DateTime date = entry["datetime"];
     int weekday = (date.weekday - 1) % 7;  // Make Sunday = 0, Monday = 1, etc.
     String expenseType = entry["expenseType"];
     double value = entry["value"];


     // Ensure the day has an entry before adding the value
     if (!chartData.containsKey(weekday)) {
       chartData[weekday] = {}; // Initialize if not already initialized
     }
     if (!chartData[weekday]!.containsKey(expenseType)) {
       chartData[weekday]![expenseType] = 0;
     }
     chartData[weekday]![expenseType] = chartData[weekday]![expenseType]! + value;
   });


   return chartData;
 }


   // Function to build the legend for the current week
 List<Widget> buildLegendForCurrentWeek() {
   List<int> descendingWeeks = weeklyData.keys.toList()..sort((a, b) => b.compareTo(a));
   int currentWeek = descendingWeeks[currentWeekIndex];


   // Get chart data for the current week
   Map<int, Map<String, double>> chartData = weeklyData[currentWeek] ?? {};


   // Calculate totals for the current week
   Map<String, double> currentWeekTotals = calculateTotalsForWeek(chartData);


   return currentWeekTotals.entries.map((entry) {
     String expenseType = entry.key;
     double totalValue = entry.value;


     return Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
         Row(
           children: [
             Container(
               width: 12,
               height: 12,
               decoration: BoxDecoration(
                 color: getColorForExpenseType(expenseType),
                 borderRadius: BorderRadius.circular(6),
               ),
             ),
             const SizedBox(width: 8),
             Text(
               expenseType,
               style: TextStyle(
                 color: TColor.white,
                 fontWeight: FontWeight.bold,
               ),
             ),
           ],
         ),
         Text(
           "\$${totalValue.toStringAsFixed(2)}",
           style: TextStyle(
             color: TColor.white,
             fontWeight: FontWeight.bold,
           ),
         ),
       ],
     );
   }).toList();
 }


 // Function to calculate totals for the current week
 Map<String, double> calculateTotalsForWeek(Map<int, Map<String, double>> chartData) {
   Map<String, double> totals = {};


   // Iterate over the days and sum up the totals for each expense type
   chartData.forEach((day, expenses) {
     expenses.forEach((expenseType, value) {
       if (totals.containsKey(expenseType)) {
         totals[expenseType] = totals[expenseType]! + value;
       } else {
         totals[expenseType] = value;
       }
     });
   });


   return totals;
 }


}
