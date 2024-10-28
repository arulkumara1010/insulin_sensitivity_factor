import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'finalinsulin.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import the new page here

class SummaryPage extends StatefulWidget {
  final Map<String, Map<String, int>> itemCounts;

  const SummaryPage({required this.itemCounts, super.key});

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  Map<String, double> carbValues = {};
  double totalCarbs = 0;
  double choRatio = 0;

  // Fetch Carb Values and Calculate Total Carbs
  Future<void> fetchCarbValues() async {
    double total = 0;
    for (var category in widget.itemCounts.keys) {
      for (var food in widget.itemCounts[category]!.keys) {
        int count = widget.itemCounts[category]![food]!;
        if (count > 0) {
          DocumentSnapshot snapshot = await FirebaseFirestore.instance
              .collection('foodcarbs') // Ensure the collection name is correct
              .doc(food)
              .get();

          double carbs =
              (snapshot.get('carbs') as num).toDouble(); // Cast to double
          total += carbs * count;
          carbValues[food] = carbs;
        }
      }
    }
    setState(() {
      totalCarbs = total;
    });
  }

 

  // Fetch user's CHO Ratio from Firestore
  // Fetch user's CHO Ratio from Firestore
Future<void> fetchCHOData() async {
  final user = FirebaseAuth.instance.currentUser; // Get the current FirebaseAuth user
  if (user != null) {
    final userId = user.uid; // Retrieve the user ID (UID)
    print('User ID: $userId'); // Optional: To print the user ID for debugging

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      setState(() {
        choRatio = (userDoc['choRatio'] as num).toDouble(); // Retrieve CHO Ratio
        print(choRatio);
      });
    }
  } else {
    print('No user is logged in.');
  }
}


  @override
  void initState() {
    super.initState();
    fetchCarbValues(); // Fetch carb values when the page loads
    fetchCHOData(); // Fetch CHO ratio from Firestore
  }

  // Calculate Insulin Dosage
  double calculateInsulinDosage() {
    if (choRatio > 0) {
      return totalCarbs / choRatio;
    }
    return 0;
  }

  // Navigate to the InsulinDosagePage
 Future<void> saveSummaryToFirestore(double insulinDosage) async {
  final user = FirebaseAuth.instance.currentUser; // Get the current user
  if (user != null) {
    final userId = user.uid; // Get the user ID
    final summaryData = {
      'timestamp': FieldValue.serverTimestamp(), // Add a timestamp
      'totalCarbs': totalCarbs,
      'insulinDosage': insulinDosage,
      'itemCounts': widget.itemCounts.map((category, foods) => MapEntry(
          category,
          foods.map((food, count) => MapEntry(food, count)))), // Ensure nested map is properly structured
    };

    try {
      await FirebaseFirestore.instance
          .collection('users') // Your users collection
          .doc(userId) // Use the user ID to store data for this user
          .collection('history') // Create a subcollection for history
          .add(summaryData); // Store the summary data
      print('Summary saved to Firestore successfully.');
    } catch (e) {
      if (e is FirebaseException) {
        print('FirebaseException: ${e.message}');
      } else {
        print('Unknown error saving summary: $e');
      }
    }
  } else {
    print('No user is logged in. Cannot save summary.');
  }
}

  // Navigate to the InsulinDosagePage
  void goToInsulinDosagePage() async {
    double insulinDosage = calculateInsulinDosage();
    await saveSummaryToFirestore(insulinDosage); // Save the summary first
    print(insulinDosage);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsulinDosagePage(insulinDosage: insulinDosage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 35),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36.0, vertical: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Summary',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: carbValues.keys.length,
                        itemBuilder: (context, index) {
                          String food = carbValues.keys.elementAt(index);
                          int count = widget.itemCounts.entries
                              .firstWhere(
                                  (element) => element.value.containsKey(food))
                              .value[food]!;
                          return ListTile(
                            title: Text(
                              '$food (x$count)',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Carbs: ${(carbValues[food]! * count).toStringAsFixed(2)}g',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      child: Text(
                        'Total CARBS : ${totalCarbs.toStringAsFixed(2)}g',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 36.0),
                child: ElevatedButton(
                  onPressed: goToInsulinDosagePage, // Go to Insulin Dosage Page
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    "CONTINUE",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 5.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
