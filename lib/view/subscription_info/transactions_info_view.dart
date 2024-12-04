import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:trackizer/common_widget/secondary_boutton.dart';
import '../../common/color_extension.dart';
import '../../common_widget/editable_row.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionsInfoView extends StatefulWidget {
  final Map sObj;
  const TransactionsInfoView({super.key, required this.sObj});

  @override
  State<TransactionsInfoView> createState() => _TransactionsInfoViewState();
}

class _TransactionsInfoViewState extends State<TransactionsInfoView> {
  late Map<String, dynamic> sObj;

  @override
  void initState() {
    super.initState();
    sObj = Map.from(widget.sObj); // Copy dữ liệu ban đầu từ widget
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: TColor.gray,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xff282833).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      height: media.width * 0.9,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: TColor.gray70,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Image.asset("assets/img/back.png",
                                    width: 20, height: 20, color: TColor.gray30),
                              ),
                              Text(
                                "Subscription info",
                                style: TextStyle(
                                    color: TColor.gray30, fontSize: 16),
                              ),
                              IconButton(
                                onPressed: () {
                                  FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser?.uid)
                                  .collection(sObj["type"])
                                  .doc(sObj["id"])
                                  .delete();
                        Navigator.pop(context);
                        setState(() {});
                                  //delete trong database
                                  Navigator.pop(context);
                                },
                                icon: Image.asset("assets/img/Trash.png",
                                    width: 25, height: 25, color: TColor.gray30),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Image.asset(
                            widget.sObj["icon"],
                            width: media.width * 0.25,
                            height: media.width * 0.25,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            sObj["title"],
                            style: TextStyle(
                                color: TColor.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            "${NumberFormat('#,##0').format(sObj["value"])} ₫",
                            style: TextStyle(
                                color: TColor.gray30,
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: TColor.border.withOpacity(0.1),
                              ),
                              color: TColor.gray60.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                EditableRow(
                                  title: "Name",
                                  value: sObj["title"],
                                  onValueChanged: (newValue) {
                                    setState(() {
                                      sObj["title"] = newValue;
                                    });
                                  },
                                ),
                                EditableRow(
                                  title: "Value",
                                  value: sObj["value"].toString(),
                                  onValueChanged: (newValue) {
                                    setState(() {
                                      sObj["value"] = double.tryParse(newValue) ?? sObj["value"];
                                    });
                                  },
                                ),
                                EditableRow(
                                  title: "Description",
                                  value: sObj["description"],
                                  onValueChanged: (newValue) {
                                    setState(() {
                                      sObj["description"] = newValue;
                                    });
                                  },
                                ),
                                EditableRow(
                                  title: "Category",
                                  value: sObj["category"],
                                  onValueChanged: (newValue) {
                                    setState(() {
                                      sObj["category"] = newValue;
                                    });
                                  },
                                ),
                                EditableRow(
                                  title: "First payment",
                                  value: DateFormat("dd MMM yyyy").format(sObj["datetime"]),
                                  onValueChanged: (newValue) {
                                    setState(() {
                                      sObj["datetime"] = DateFormat("dd MMM yyyy").parse(newValue);
                                    });
                                  },
                                ),
                                if (sObj["type"] == "outcomes")
                                  EditableRow(
                                    title: "Expense Type",
                                    value: sObj["expenseType"],
                                    onValueChanged: (newValue) {
                                      setState(() {
                                        sObj["expenseType"] = newValue;
                                      });
                                    },
                                  ),
                                EditableRow(
                                  title: "Currency",
                                  value: sObj["currency"],
                                  onValueChanged: (newValue) {
                                    setState(() {
                                      sObj["currency"] = newValue;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SecondaryButton(
                              title: "Save",
                              onPressed: () {
                          FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .collection(sObj["type"])
                            .doc(sObj["id"])
                            .update({
                          'title': sObj["title"],
                          'description': sObj["description"],
                          'value': sObj["value"],
                        });
                        Navigator.pop(context);
                                
                              }),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20, left: 4, right: 4),
                height: media.width * 0.9 + 15,
                alignment: Alignment.bottomCenter,
                child: Row(children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: TColor.gray,
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  Expanded(
                      child: DottedBorder(
                    dashPattern: const [5, 10],
                    padding: EdgeInsets.zero,
                    strokeWidth: 1,
                    child: SizedBox(
                      height: 0,
                    ),
                    radius: const Radius.circular(16),
                    color: TColor.gray,
                  )),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: TColor.gray,
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
