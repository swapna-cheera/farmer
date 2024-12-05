import 'package:flutter/material.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding JSON response

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final String _serverAddress = 'https://sgp1.blynk.cloud/';
  final String _authToken = 'uSyKmGezu9qSsMF6PJ6bucyxTmy4Xs8N';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("Demo Screen");
      fetchData();
    });
  }

  // final WebSocketChannel channel =
  Future<void> fetchData() async {
    String url = '$_serverAddress/external/api/get?token=$_authToken&pin=12';
    final uri = Uri.parse(url);
    // Define the API endpoint
    // final url = Uri.parse(
    //   //blynk-cloud.com 8442
    //   //elec.cmtc.ac.th
    //   '$_serverAddress/external/api/get?token=$_authToken&pin=V0',
    // ); // Replace with your API URL

    try {
      debugPrint('API URL : ${uri.toString()}');

      // Make the GET request
      final response = await http.get(uri);

      // Check the response status
      if (response.statusCode == 200) {
        // If the server returns a successful response, parse the JSON
        var data = jsonDecode(response.body);
        debugPrint('Response data: $data');
      } else {
        // If the server returns an error response
        debugPrint('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("new Screen"),
      ),
    );
    // return Center(
    //   child: StreamBuilder(
    //     stream: channel.stream,
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const CircularProgressIndicator();
    //       } else if (snapshot.hasError) {
    //         return Text('Error: ${snapshot.error}');
    //       } else if (snapshot.hasData) {
    //         return Text('Received: ${snapshot.data}');
    //       } else {
    //         return const Text('No data yet');
    //       }
    //     },
    //   ),
    // );
  }
}
