

// ignore_for_file: use_key_in_widget_constructors



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'summary.dart';

// Entry point of the application
void main() {
  runApp(MyApp());
}

// Main app widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const FooddetailsPage(),
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Main page where the food details are displayed with tabs
class FooddetailsPage extends StatefulWidget {
  const FooddetailsPage({super.key});

  @override
  State<FooddetailsPage> createState() => _FooddetailsPageState();
}

class _FooddetailsPageState extends State<FooddetailsPage> {
  // List of tabs for the food categories
  List<Widget> myTabs = const [
    MyTab(imagePath: 'assets/images/english-breakfast (1).png'),
    MyTab(imagePath: 'assets/images/sweets (1).png'),
    MyTab(imagePath: 'assets/images/rice-bowl (1).png'),
    MyTab(imagePath: 'assets/images/soda.png'),
  ];

  // Keeping track of item counts for each tab
  Map<String, Map<String, int>> itemCounts = {
    "Breakfast": {
      "Dosa": 0,
      "Idli": 0,
      "Poori": 0,
      "Vada": 0,
    },
    "Dessert": {
      "Cookies": 0,
      "Cake": 0,
      "Chocolate": 0,
      "Icecream": 0,
    },
    "Rice": {
      "White Rice": 0,
      "Black Rice": 0,
      "Biriyani": 0,
      "Fried Rice": 0,
    },
    "Drink": {
      "Juices": 0,
      "Coffee": 0,
      "Tea": 0,
      "Softdrink": 0,
    }
  };

  // Update item count for a specific food item in a specific category
  void updateItemCount(String category, String foodItem, int newCount) {
    setState(() {
      itemCounts[category]![foodItem] = newCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        body: Stack(
          children: [
            // Background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 18),
                  child: Row(
                    children: [
                      Text(
                        'I want to ',
                        style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      Text(
                        ' EAT',
                        style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TabBar(tabs: myTabs),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    children: [
                      BreakfastTab(itemCounts["Breakfast"]!, updateItemCount),
                      DessertTab(itemCounts["Dessert"]!, updateItemCount),
                      RiceTab(itemCounts["Rice"]!, updateItemCount),
                      DrinkTab(itemCounts["Drink"]!, updateItemCount),
                    ],
                  ),
                ),
                // NEXT button at the bottom
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryPage(itemCounts: itemCounts),
        ),
      );
                    },
                    child: const Text(
                      "NEXT",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Class for displaying the image tabs
class MyTab extends StatelessWidget {
  final String imagePath;
  const MyTab({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 80,
      child: Image.asset(imagePath),
    );
  }
}

// Tab classes for each category

class BreakfastTab extends StatelessWidget {
  final Map<String, int> itemCounts;
  final Function(String, String, int) updateItemCount;

  BreakfastTab(this.itemCounts, this.updateItemCount);

  final List breakfast = [
    ["Dosa", "assets/images/masala-dosa.png", Colors.red],
    ["Idli", "assets/images/food.png", Colors.blue],
    ["Poori", "assets/images/poori.png", Colors.purple],
    ["Vada", "assets/images/vada.png", Colors.brown],
  ];

  @override
  Widget build(BuildContext context) {

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
        childAspectRatio: 0.75,
      ),
      itemCount: breakfast.length,
      itemBuilder: (context, index) {
        return FoodItemTitle(
          foodName: breakfast[index][0],
          imageName: breakfast[index][1],
          color: breakfast[index][2],
          initialCount: itemCounts[breakfast[index][0]]!,
          onUpdateCount: (count) => updateItemCount("Breakfast", breakfast[index][0], count),
        );
      },
    );
  }
}

class DessertTab extends StatelessWidget {
  final Map<String, int> itemCounts;
  final Function(String, String, int) updateItemCount;

  DessertTab(this.itemCounts, this.updateItemCount);

  final List dessert = [
    ["Cookies", "assets/images/cookies.png", Colors.red],
    ["Cake", "assets/images/cake.png", Colors.blue],
    ["Chocolate", "assets/images/chocolate-bar.png", Colors.purple],
    ["Icecream", "assets/images/ice-cream.png", Colors.brown],
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
        childAspectRatio: 0.75,
      ),
      itemCount: dessert.length,
      itemBuilder: (context, index) {
        return FoodItemTitle(
          foodName: dessert[index][0],
          imageName: dessert[index][1],
          color: dessert[index][2],
          initialCount: itemCounts[dessert[index][0]]!,
          onUpdateCount: (count) => updateItemCount("Dessert", dessert[index][0], count),
        );
      },
    );
  }
}

class RiceTab extends StatelessWidget {
  final Map<String, int> itemCounts;
  final Function(String, String, int) updateItemCount;

  RiceTab(this.itemCounts, this.updateItemCount);

  final List rice = [
    ["White Rice", "assets/images/rice-bowl.png", Colors.red],
    ["Black Rice", "assets/images/rice (1).png", Colors.blue],
    ["Biriyani", "assets/images/food (1).png", Colors.purple],
    ["Fried Rice", "assets/images/fried-rice.png", Colors.brown],
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
        childAspectRatio: 0.75,
      ),
      itemCount: rice.length,
      itemBuilder: (context, index) {
        return FoodItemTitle(
          foodName: rice[index][0],
          imageName: rice[index][1],
          color: rice[index][2],
          initialCount: itemCounts[rice[index][0]]!,
          onUpdateCount: (count) => updateItemCount("Rice", rice[index][0], count),
        );
      },
    );
  }
}

class DrinkTab extends StatelessWidget {
  final Map<String, int> itemCounts;
  final Function(String, String, int) updateItemCount;

  DrinkTab(this.itemCounts, this.updateItemCount);

  final List drink = [
    ["Juices", "assets/images/juices.png", Colors.red],
    ["Coffee", "assets/images/coffee-cup.png", Colors.blue],
    ["Tea", "assets/images/tea.png", Colors.purple],
    ["Softdrink", "assets/images/soft-drinks.png", Colors.brown],
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
        childAspectRatio: 0.75,
      ),
      itemCount: drink.length,
      itemBuilder: (context, index) {
        return FoodItemTitle(
          foodName: drink[index][0],
          imageName: drink[index][1],
          color: drink[index][2],
          initialCount: itemCounts[drink[index][0]]!,
          onUpdateCount: (count) => updateItemCount("Drink", drink[index][0], count),
        );
      },
    );
  }
}

// Widget to display each food item with a counter
class FoodItemTitle extends StatefulWidget {
  final String foodName;
  final String imageName;
  final Color color;
  final int initialCount;
  final Function(int) onUpdateCount;

  const FoodItemTitle({
    required this.foodName,
    required this.imageName,
    required this.color,
    required this.initialCount,
    required this.onUpdateCount,
    super.key,
  });

  @override
  _FoodItemTitleState createState() => _FoodItemTitleState();
}



class _FoodItemTitleState extends State<FoodItemTitle> {
  late int itemCount;

  @override
  void initState() {
    super.initState();
    itemCount = widget.initialCount;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(widget.imageName, height: 100, width: 100),
            const SizedBox(height: 10),
            // Food name text with Inter font
            Text(
              widget.foodName,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Set the color to black
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (itemCount > 0) itemCount--;
                    });
                    widget.onUpdateCount(itemCount);
                  },
                ),
                Text(
                  itemCount.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.black, // Ensure count text is also in Inter and black
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      itemCount++;
                    });
                    widget.onUpdateCount(itemCount);
                  },
                ),
              ],
            ),
          ],
        ),
      ),

   

    );
  }
}
