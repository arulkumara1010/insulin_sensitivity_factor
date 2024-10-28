import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> mealHistory = []; // Store meal history data

  // Fetch meal history from Firestore
  Future<void> fetchMealHistory() async {
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      final userId = user.uid; // Get the user ID
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users') // Your users collection
            .doc(userId)
            .collection('history') // Subcollection for history
            .orderBy('timestamp', descending: true) // Order by timestamp
            .get();

        mealHistory = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        setState(() {}); // Update the UI with the fetched data
      } catch (e) {
        print('Error fetching meal history: $e');
      }
    } else {
      print('No user is logged in.');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMealHistory(); // Fetch history data when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"), // Use the same background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0), // Add padding to prevent overflow
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.black),
                  title: Text(
                    'Meal History',
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  centerTitle: true,
                ),
                Expanded(
                  child: mealHistory.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(color: Colors.greenAccent),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(bottom: 16.0), // Add padding to avoid border crossing
                          itemCount: mealHistory.length,
                          itemBuilder: (context, index) {
                            final mealData = mealHistory[index];
                            final totalCarbs = mealData['totalCarbs'] ?? 0.0;
                            final insulinDosage = mealData['insulinDosage'] ?? 0.0;
                            final timestamp = (mealData['timestamp'] as Timestamp).toDate(); // Convert Firestore Timestamp to DateTime
                            final formattedDate = DateFormat.yMMMd().add_jm().format(timestamp); // Format the date

                            final itemCounts = (mealData['itemCounts'] as Map<String, dynamic>).map(
                              (key, value) => MapEntry(
                                key,
                                Map<String, int>.from(value as Map<String, dynamic>),
                              ),
                            );

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              color: Colors.white, // White background for the card
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Carbs: ${totalCarbs.toStringAsFixed(2)}g',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black, // Text in black
                                      ),
                                    ),
                                    Text(
                                      'Insulin Dosage: ${insulinDosage.toStringAsFixed(2)} units',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Colors.black, // Text in black
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Date & Time: $formattedDate',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Colors.black, // Text in black
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Food Items:',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black, // Text in black
                                      ),
                                    ),
                                    ...itemCounts.entries.map((entry) {
                                      final category = entry.key;
                                      final foodItems = entry.value;

                                      // Filter out food items with a count of 0
                                      final filteredFoodItems = foodItems.entries.where((foodEntry) => foodEntry.value > 0);

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (filteredFoodItems.isNotEmpty) // Only show category if it has food items with count > 0
                                            Text(
                                              '$category:',
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black, // Text in black
                                              ),
                                            ),
                                          ...filteredFoodItems.map((foodEntry) {
                                            return Text(
                                              '${foodEntry.key} (x${foodEntry.value})',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: Colors.black, // Text in black
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
