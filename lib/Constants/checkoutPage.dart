import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:meroapp/Constants/styleConsts.dart';

class CheckoutPage extends StatefulWidget {
  int grandTotal;

  CheckoutPage({super.key, required this.grandTotal});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _paymentMethod = 'COD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        centerTitle: true,
        backgroundColor: kThemeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.payment),
                Text(
                  "Payment Option",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
              ],
            ),
            Card(
              elevation: 3,
              shadowColor: Colors.white60,
              child: RadioListTile(
                activeColor: kThemeColor,
                title: const Text('Cash on Delivery'),
                value: 'COD',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value.toString();
                  });
                },
              ),
            ),
            Card(
              elevation: 3,
              shadowColor: Colors.white60,
              child: RadioListTile(
                activeColor: kThemeColor,
                title: const Text('Esewa'),
                value: 'eSewa',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value.toString();
                  });
                },
              ),
            ),
            Card(
              elevation: 3,
              shadowColor: Colors.white60,
              child: RadioListTile(
                activeColor: kThemeColor,
                title: const Text('Khalti'),
                value: 'Khalti',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value.toString();
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width / 2,
              child: ElevatedButton(
                onPressed: () {
                  log('Payment Method: $_paymentMethod');
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0, backgroundColor: appBarColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  "Place your Order",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
