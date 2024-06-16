import 'package:flutter/material.dart';
import 'package:meroapp/Constants/styleConsts.dart';

class CheckoutPage extends StatefulWidget {
  int grandTotal;
  CheckoutPage({super.key,required this.grandTotal});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _paymentMethod = 'COD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout"),
        centerTitle: true,
        backgroundColor: kThemeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
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
                title: Text('Cash on Delivery'),
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
                title: Text('Esewa'),
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
                title: Text('Khalti'),
                value: 'Khalti',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value.toString();
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width/2,
              child: ElevatedButton(
                onPressed: () {
                  print('Payment Method: $_paymentMethod');
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  primary:  appBarColor,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                        10.0),
                  ),
                ),
                child: Text(
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
