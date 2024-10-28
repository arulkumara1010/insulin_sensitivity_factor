import 'package:flutter/material.dart';
import 'food.dart'; // Import the MealDetailPage

class FoodHistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> foodHistory = [
    {
      'date': '2024-09-20',
      'meals': [
        {
          'food': 'Breakfast - idli',
          'carbs': 45,
          'time': '08:00 AM',
          'portion': '2 pieces'
        },
        {
          'food': 'Lunch - Rice, chicken',
          'carbs': 150,
          'time': '12:30 PM',
          'portion': '1 bowl'
        },
        {
          'food': 'Dinner - chapati, gravy',
          'carbs': 100,
          'time': '07:00 PM',
          'portion': '2 pieces'
        },
      ]
    },
    {
      'date': '2024-09-21',
      'meals': [
        {
          'food': 'Breakfast - idli',
          'carbs': 45,
          'time': '08:00 AM',
          'portion': '2 pieces'
        },
        {
          'food': 'Lunch - Rice, chicken',
          'carbs': 150,
          'time': '12:30 PM',
          'portion': '1 bowl'
        },
        {
          'food': 'Dinner - chapati, gravy',
          'carbs': 100,
          'time': '07:00 PM',
          'portion': '2 pieces'
        },
      ]
    },
    {
      'date': '2024-09-22',
      'meals': [
        {
          'food': 'Breakfast - idli',
          'carbs': 45,
          'time': '08:00 AM',
          'portion': '2 pieces'
        },
        {
          'food': 'Lunch - Rice, chicken',
          'carbs': 150,
          'time': '12:30 PM',
          'portion': '1 bowl'
        },
        {
          'food': 'Dinner - chapati, gravy',
          'carbs': 100,
          'time': '07:00 PM',
          'portion': '2 pieces'
        },
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        title: const Text(
          'Food and Carb History',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Container(
        color: Colors.green.shade50,
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: foodHistory.length,
          itemBuilder: (context, index) {
            final day = foodHistory[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealDetailPage(
                      date: day['date'],
                      meals: day['meals'],
                    ),
                  ),
                );
              },
              child: Card(
                color: Colors.green.shade100,
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: ${day['date']}',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      ...day['meals'].map<Widget>((meal) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                meal['food'],
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '${meal['carbs']}g Carbs',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.green,
      scaffoldBackgroundColor: const Color.fromARGB(255, 216, 247, 227),
      appBarTheme: AppBarTheme(
        color: Colors.green.shade200,
      ),
    ),
    home: FoodHistoryPage(),
  ));
}
