import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Get.toNamed('/nerbyPharmacies'),
            child: const Text('Go to Nearby Pharmacies'),
          ),
        ],
      ),
    );
  }
}
