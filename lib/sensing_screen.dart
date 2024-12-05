import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SensingScreen extends StatefulWidget {
  const SensingScreen({super.key});

  @override
  State<SensingScreen> createState() => _SensingScreenState();
}

class _SensingScreenState extends State<SensingScreen> {
  final CollectionReference sensorsCollection =
      FirebaseFirestore.instance.collection('sensorsdata');

  @override
  Widget build(BuildContext context) {
    precacheImage(
      const AssetImage('lib/assets/sensingbg.jpg'),
      context,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensors Overview'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/sensingbg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: sensorsCollection
                .orderBy('timestamp', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No data available'));
              }

              final data =
                  snapshot.data!.docs.first.data() as Map<String, dynamic>;

              // Extract data
              final Map<String, dynamic> sensorsData = {
                'Motor On/Off': data['motor'] ? 'On' : 'Off',
                'Solenoid Valve': data['solenoidvalve'],
                'Soil Moisture': data['soilmoisture'],
                'Temperature & Humidity': data['temperaturehumidity'],
                'Water Level Indicator': data['waterlevelindicator'],
              };

              return ListView.builder(
                itemCount: sensorsData.length,
                itemBuilder: (context, index) {
                  String subject = sensorsData.keys.elementAt(index);
                  String value = sensorsData[subject].toString();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
