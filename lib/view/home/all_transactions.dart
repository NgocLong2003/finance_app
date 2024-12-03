import 'package:flutter/material.dart';
import 'package:trackizer/common/color_extension.dart';
import '../../common_widget/custom_arc_painter.dart';
import '../../common_widget/status_button.dart';
import '../../common_widget/transactions_row.dart';
import '../subscription_info/transactions_info_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../common_widget/segment_button.dart';

class AllTransactions extends StatefulWidget {
  const AllTransactions({super.key});

  @override
  State<AllTransactions> createState() => _AllTransactionsState();
}

class _AllTransactionsState extends State<AllTransactions> {
  bool isOutcome = true;

  Future<List<Map<String, dynamic>>> _fetchTransactions(String type) async {
  List<Map<String, dynamic>> transactions = [];
  

  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return transactions;

    // Lấy dữ liệu từ incomes
    if(type == "income"){
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
    }
    
    else{
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
      appBar: AppBar(
        title: Text(
          "ALL TRANSACTIONS",
          style:
              TextStyle(color: Color(0xFF8C8C9D), fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1C1C1E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
          title: "Expense",
          isActive: isOutcome,
          onPressed: () {
            setState(() {
              isOutcome = true;
            });
          },
        ),
      ),
      Expanded(
        child: SegmentButton(
          title: "Income",
          isActive: !isOutcome,
          onPressed: () {
            setState(() {
              isOutcome = false;
            });
          },
        ),
      )
    ],
  ),
),
if (isOutcome)
Container(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTransactions("outcome"),
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
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: transactions.length,
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
if (!isOutcome)
Container(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTransactions("income"),
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
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: transactions.length,
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
