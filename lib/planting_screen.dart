import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlantingScreen extends StatefulWidget {
  const PlantingScreen({super.key});

  @override
  State<PlantingScreen> createState() => _PlantingScreenState();
}

class _PlantingScreenState extends State<PlantingScreen> {
  String? selectedCrop;
  int cropQuantity = 0;
  int cropMaxQuantity = 0;

  final _auth = FirebaseAuth.instance;

  String farmerName = "";

  final CollectionReference cropsCollection =
      FirebaseFirestore.instance.collection('crops');

  final CollectionReference farmingCropsCollection =
      FirebaseFirestore.instance.collection('farmingcrops');

  List<Map<String, dynamic>> cropData = [];

  @override
  void initState() {
    super.initState();
    User? updatedUser = _auth.currentUser;
    debugPrint('User name: ${updatedUser?.displayName}');
    farmerName = updatedUser?.displayName ?? 'Unknown';
    _fetchCropData();
  }

  Future<void> _fetchCropData() async {
    final cropsSnapshot = await cropsCollection.get();
    List<Map<String, dynamic>> tempCropData = [];

    for (var cropDoc in cropsSnapshot.docs) {
      final cropName = cropDoc['cropname'] as String;
      final cropLimit = cropDoc['croplimit'] as int;

      final farmingSnapshot = await farmingCropsCollection
          .where('cropname', isEqualTo: cropName)
          .where('farmername', isEqualTo: farmerName)
          .get();

      final farmingCount = farmingSnapshot.docs.isNotEmpty
          ? farmingSnapshot.docs.first['farmingcount'] as int
          : 0;

      tempCropData.add({
        'cropname': cropName,
        'croplimit': cropLimit,
        'farmingcount': farmingCount,
      });
    }

    setState(() {
      cropData = tempCropData;
    });
  }

  void _handleRadioValueChange(String? value) {
    setState(() {
      selectedCrop = value;

      // Fetch the selected crop's data
      final selectedCropData = cropData.firstWhere(
        (crop) => crop['cropname'] == value,
        orElse: () => {'croplimit': 0, 'farmingcount': 0},
      );
      cropMaxQuantity = selectedCropData['croplimit'];
      cropQuantity = selectedCropData['farmingcount'];
    });
  }

  Future<void> _handleSubmit() async {
    if (cropQuantity >= cropMaxQuantity) {
      // Show error if farming count reaches or exceeds the crop limit
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Crop is full. Please select another crop.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      try {
        final querySnapshot = await farmingCropsCollection
            .where('cropname', isEqualTo: selectedCrop)
            .where('farmername', isEqualTo: farmerName)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final currentCount = doc['farmingcount'] as int;

          await farmingCropsCollection.doc(doc.id).update({
            'farmingcount': currentCount + 1,
          });
        } else {
          await farmingCropsCollection.add({
            'cropname': selectedCrop,
            'farmername': farmerName,
            'farmingcount': 1,
          });
        }

        // Update crop quantity locally for immediate feedback
        setState(() {
          cropQuantity += 1;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Successfully planted $selectedCrop ($cropQuantity / $cropMaxQuantity)'),
        ));

        // Refresh crop data to ensure consistency
        await _fetchCropData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planting'),
      ),
      body: cropData.isEmpty
          ? Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/plantingbackground.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/plantingbackground.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Select a crop:',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...cropData.map((crop) {
                      final cropName = crop['cropname'];
                      final cropLimit = crop['croplimit'];
                      final farmingCount = crop['farmingcount'];

                      return RadioListTile<String>(
                        title: Text(
                          '$cropName (Planted: $farmingCount / Max: $cropLimit)',
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        value: cropName,
                        groupValue: selectedCrop,
                        onChanged: _handleRadioValueChange,
                      );
                    }),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
