import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food API Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  // Base URL and endpoint of the API
  final String baseUrl = "https://api.nal.usda.gov/fdc";
  final String searchEndpoint = "/v1/foods/search";
  final String apiKey = "67to5FIMinRwAp1qjkiPSg3AXaMkhS9w6P2kxG9U"; // Replace with your actual API key

  // Function to handle search API call
  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('$baseUrl$searchEndpoint?api_key=$apiKey&query=${Uri.encodeComponent(query)}&pageSize=25&pageNumber=1&sortBy=dataType.keyword&sortOrder=asc');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _searchResults = json.decode(response.body)['foods'];
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error making API request: $error');
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Function to fetch food details by FDC ID
  Future<void> _fetchFoodDetails(String fdcId) async {
    final url = Uri.parse('$baseUrl/v1/food/$fdcId?api_key=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final foodDetails = json.decode(response.body);

        // Filter the relevant nutrient information for carbohydrates and total sugars
        final carbsInfo = foodDetails['foodNutrients'].where((nutrient) {
          final nutrientName = nutrient['nutrientName'].toLowerCase();
          return nutrientName.contains('carbohydrate') || nutrientName.contains('sugar');
        }).toList();

        // Show only carbohydrates and sugars info
        _showFoodDetailsDialog(foodDetails['description'], carbsInfo);
      } else {
        print('Error fetching food details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error making API request: $error');
    }
  }

  // Function to show food details (carbs and sugars) in a dialog
  void _showFoodDetailsDialog(String description, List<dynamic> carbsInfo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(description),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: carbsInfo.map((nutrient) {
              return Text('${nutrient['nutrientName']}: ${nutrient['value']} ${nutrient['unitName']}');
            }).toList(),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food API Search"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for food...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _performSearch(_searchController.text);
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return ListTile(
                          title: Text(item['description']),
                          subtitle: Text(item['dataType']),
                          onTap: () {
                            _fetchFoodDetails(item['fdcId'].toString()); // Fetch details for the tapped item
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
