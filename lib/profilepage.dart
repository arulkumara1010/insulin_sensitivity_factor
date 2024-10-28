import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  // Controllers for the editable fields
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _carbRatioController = TextEditingController();
  TextEditingController _longActingInsulinController = TextEditingController();

  // Edit mode toggles
  bool isEditingHeight = false;
  bool isEditingWeight = false;
  bool isEditingCarbRatio = false;
  bool isEditingInsulin = false;

  // Fetch user details from Firestore
  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        userData = snapshot.data() as Map<String, dynamic>?;
        isLoading = false;

        // Set initial values for the controllers
        _heightController.text = userData!['height']?.toString() ?? '';
        _weightController.text = userData!['weight']?.toString() ?? '';
        _carbRatioController.text = userData!['choRatio']?.toString() ?? '';
        _longActingInsulinController.text =
            userData!['longactinginsulin']?.toString() ?? '';
      });
    }
  }

  // Save the updated details to Firestore
  Future<void> _saveUserData(String field) async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Get the current user document to retrieve any needed fields (e.g., averageInsulin)
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      // Prepare the map for updated fields
      Map<String, dynamic> updatedData = {};

      if (field == 'height') {
        updatedData['height'] = double.tryParse(_heightController.text);
      }

      if (field == 'weight') {
        updatedData['weight'] = double.tryParse(_weightController.text);
      }

      if (field == 'choRatio') {
        updatedData['choRatio'] = double.tryParse(_carbRatioController.text);
      }

      if (field == 'longactinginsulin') {
        double longActingInsulin =
            double.tryParse(_longActingInsulinController.text) ?? 0;

        // Save longactinginsulin
        updatedData['longactinginsulin'] = longActingInsulin;

        // Get the averageInsulin from the user document (or provide a default value if it's not available)
        double averageInsulin = (userDoc['averageInsulin'] ?? 0).toDouble();

        // Recalculate choRatio and correctionFactor
        double choRatio = 500 / (longActingInsulin + averageInsulin);
        double correctionFactor = 1800 / (longActingInsulin + averageInsulin);

        // Update the choRatio and correctionFactor as well
        updatedData['choRatio'] = choRatio;
        updatedData['correctionFactor'] = correctionFactor;
      }

      // Update Firestore document with the new data
      await _firestore.collection('users').doc(user.uid).update(updatedData);
      _loadUserData();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$field updated successfully!')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Fetch user details when the page loads
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
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: MediaQuery.of(context).size.width / 2 - 170,
            child: SizedBox(
              width: 340,
              height: 45,
              child: Row(
                children: [
                  if (isLoading)
                    const CircularProgressIndicator()
                  else if (userData != null)
                    Text(
                      "${userData!['name']}'s Profile",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 100.0), // Space before profile photo
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        userData != null && userData!['photoUrl'] != null
                            ? NetworkImage(userData!['photoUrl'])
                            : AssetImage("assets/images/default_profile.png")
                                as ImageProvider,
                  ),
                  const SizedBox(height: 20.0),
                  if (userData != null) ...[
                    Text(
                      userData!['name'] ?? 'Name',
                      style: GoogleFonts.inter(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      userData!['email'] ?? 'Email',
                      style: GoogleFonts.inter(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40.0),

                    // Height with edit button
                    _buildProfileDetailWithEdit(
                      'Height',
                      _heightController,
                      isEditingHeight,
                      () => setState(() => isEditingHeight = !isEditingHeight),
                      'height',
                    ),

                    // Weight with edit button
                    _buildProfileDetailWithEdit(
                      'Weight',
                      _weightController,
                      isEditingWeight,
                      () => setState(() => isEditingWeight = !isEditingWeight),
                      'weight',
                    ),

                    // Carb Ratio with edit button
                    _buildProfileDetailWithEdit(
                      'Carb Ratio',
                      _carbRatioController,
                      isEditingCarbRatio,
                      () => setState(
                          () => isEditingCarbRatio = !isEditingCarbRatio),
                      'choRatio',
                    ),

                    // Long-Acting Insulin with edit button
                    _buildProfileDetailWithEdit(
                      'Long-Acting Insulin',
                      _longActingInsulinController,
                      isEditingInsulin,
                      () =>
                          setState(() => isEditingInsulin = !isEditingInsulin),
                      'longactinginsulin',
                    ),
                  ] else
                    Text(
                      'No user data available',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build the profile detail with an edit button
  Widget _buildProfileDetailWithEdit(
      String title,
      TextEditingController controller,
      bool isEditing,
      VoidCallback toggleEditMode,
      String fieldName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title:',
            style: GoogleFonts.inter(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          isEditing
              ? Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: TextFormField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.save, color: Colors.green),
                        onPressed: () {
                          toggleEditMode(); // Exit edit mode
                          _saveUserData(fieldName); // Save the updated data
                        },
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    // Here you display the rounded value
                    Text(
                      double.parse(controller.text)
                          .toStringAsFixed(2), // Ensure two decimal places
                      style: GoogleFonts.inter(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.black, size: 15),
                      onPressed: toggleEditMode, // Enter edit mode
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
