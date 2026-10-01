import 'package:flutter/material.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offers & Promotions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text('Cylinder refill discount'),
            subtitle: Text('10% off on your first refill this month'),
          ),
          Divider(),
          ListTile(
            title: Text('Free delivery over 50 KG'),
            subtitle: Text('Orders above 50 KG qualify for free delivery'),
          ),
        ],
      ),
    );
  }
}
