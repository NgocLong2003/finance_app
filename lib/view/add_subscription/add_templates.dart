import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';

// Function to add sample cards for the logged-in user.
Future<void> addSampleCardsForUser(BuildContext context) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    // Reference to the Firestore collection for cards for this user
    CollectionReference cardsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cards');

    // Query to check if any card exists for this user
    QuerySnapshot querySnapshot = await cardsCollection.get();

    if (querySnapshot.docs.isEmpty) {
      // If no cards exist, create 3 new sample cards for this user
      List<Map<String, dynamic>> sampleCards = [
        {
          'name': 'Nguyen Van A',
          'number': '001203000',
          'type': 'Credit',
          'balance': 12000,
          'currency': 'VND',
          'bankName': 'TP Bank',
          'expiryDate': getRandomDate(),
        },
        {
          'name': 'Nguyen Van A',
          'number': '002304000',
          'type': 'Debit',
          'balance': 150,
          'currency': 'VND',
          'bankName': 'ACB',
          'expiryDate': getRandomDate(),
        },
        {
          'name': 'Nguyen Van A',
          'number': '003405000',
          'type': 'Momo Account',
          'balance': 823,
          'currency': 'VND',
          'bankName': 'Momo',
          'expiryDate': getRandomDate(),
        },
      ];

      // Add each sample card to the collection for this user
      for (var card in sampleCards) {
        await cardsCollection.add(card);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sample cards added successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cards already exist for this user')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error adding cards: $e')),
    );
  }
}

// Function to generate a random expiry date.
DateTime getRandomDate() {
  Random random = Random();
  int year = DateTime.now().year + random.nextInt(5); // Random year within the next 5 years
  int month = random.nextInt(12) + 1; // Random month between 1 and 12
  int day = random.nextInt(28) + 1; // Random day between 1 and 28
  return DateTime(year, month, day);
}

// Function to add sample categories for the logged-in user.
Future<void> addSampleCategoriesForUser(BuildContext context) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    // Reference to the Firestore collection for categories for this user
    CollectionReference categoryCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('category');

    // Query to check if any category exists for this user
    QuerySnapshot querySnapshot = await categoryCollection.get();

    if (querySnapshot.docs.isEmpty) {
      // If no categories exist, create 3 income categories and 20 outcome categories for this user
      List<Map<String, dynamic>> incomeCategories = [
        {'name': 'Salary', 'type': 'income', 'icon': 'assets/icons/income/salary.png', 'color': '#FF5733', 'isCustom': false},
        {'name': 'Business', 'type': 'income', 'icon': 'assets/icons/income/business.png', 'color': '#33FF57', 'isCustom': false},
        {'name': 'Investments', 'type': 'income', 'icon': 'assets/icons/income/investments.png', 'color': '#33A3FF', 'isCustom': false},
      ];

    List<Map<String, dynamic>> outcomeCategories = [
      {'name': 'Rent', 'type': 'outcome', 'icon': 'assets/icons/outcome/rent.png', 'color': '#FF3355', 'isCustom': false},
      {'name': 'Food', 'type': 'outcome', 'icon': 'assets/icons/outcome/food.png', 'color': '#55FF33', 'isCustom': false},
      {'name': 'Utilities', 'type': 'outcome', 'icon': 'assets/icons/outcome/utilities.png', 'color': '#3355FF', 'isCustom': false},
      {'name': 'Transportation', 'type': 'outcome', 'icon': 'assets/icons/outcome/transportation.png', 'color': '#FFB300', 'isCustom': false},
      {'name': 'Entertainment', 'type': 'outcome', 'icon': 'assets/icons/outcome/entertainment.png', 'color': '#E91E63', 'isCustom': false},
      {'name': 'Shopping', 'type': 'outcome', 'icon': 'assets/icons/outcome/shopping.png', 'color': '#8E44AD', 'isCustom': false},
      {'name': 'Healthcare', 'type': 'outcome', 'icon': 'assets/icons/outcome/healthcare.png', 'color': '#2ECC71', 'isCustom': false},
      {'name': 'Education', 'type': 'outcome', 'icon': 'assets/icons/outcome/education.png', 'color': '#1ABC9C', 'isCustom': false},
      {'name': 'Insurance', 'type': 'outcome', 'icon': 'assets/icons/outcome/insurance.png', 'color': '#C0392B', 'isCustom': false},
      {'name': 'Taxes', 'type': 'outcome', 'icon': 'assets/icons/outcome/taxes.png', 'color': '#D35400', 'isCustom': false},
      {'name': 'Gifts', 'type': 'outcome', 'icon': 'assets/icons/outcome/gifts.png', 'color': '#F1C40F', 'isCustom': false},
      {'name': 'Loans', 'type': 'outcome', 'icon': 'assets/icons/outcome/loans.png', 'color': '#2980B9', 'isCustom': false},
      {'name': 'Subscriptions', 'type': 'outcome', 'icon': 'assets/icons/outcome/subscriptions.png', 'color': '#27AE60', 'isCustom': false},
      {'name': 'Repairs', 'type': 'outcome', 'icon': 'assets/icons/outcome/repairs.png', 'color': '#8E44AD', 'isCustom': false},
      {'name': 'Grocery', 'type': 'outcome', 'icon': 'assets/icons/outcome/grocery.png', 'color': '#F39C12', 'isCustom': false},
      {'name': 'Mobile', 'type': 'outcome', 'icon': 'assets/icons/outcome/mobile.png', 'color': '#C0392B', 'isCustom': false},
      {'name': 'Travel', 'type': 'outcome', 'icon': 'assets/icons/outcome/travel.png', 'color': '#3498DB', 'isCustom': false},
      {'name': 'Miscellaneous', 'type': 'outcome', 'icon': 'assets/icons/outcome/miscellaneous.png', 'color': '#9B59B6', 'isCustom': false},
      {'name': 'Charity', 'type': 'outcome', 'icon': 'assets/icons/outcome/charity.png', 'color': '#1ABC9C', 'isCustom': false},
      {'name': 'Hobbies', 'type': 'outcome', 'icon': 'assets/icons/outcome/hobbies.png', 'color': '#F1C40F', 'isCustom': false},
    ];


      // Combine and add all categories to the collection for this user
      for (var category in incomeCategories + outcomeCategories) {
        await categoryCollection.add(category);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sample categories added successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Categories already exist for this user')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error adding categories: $e')),
    );
  }
}
