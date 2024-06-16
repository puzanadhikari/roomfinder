import 'package:flutter/material.dart';
import 'package:meroapp/Constants/styleConsts.dart';

import 'Constants/checkoutPage.dart';
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int grandTotal = 10000;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
        centerTitle: true,
        backgroundColor: kThemeColor,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height/1.75,
              color: Colors.grey,
              child: ListView.builder(
                // itemCount: cartProvider.cart.length,
                itemBuilder: (context, index) {
                  // var product = cartProvider.cart[index];
                  return  Card(
                    margin:
                    EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                    color: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Image.network(
                                  //   // product.image,
                                  //   // height: 70,
                                  // ),
                                  SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Apple",style: TextStyle(color: appBarColor,fontWeight: FontWeight.bold,fontSize: 15),
                                      ),
                                      SizedBox(height: 20,),
                                      Text(
                                        'Rs.500',style: TextStyle(color: appBarColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                        },
                                      ),
                                      Text(
                                        "Mango",
                                        style: TextStyle(fontSize: 16,color: appBarColor),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                        },
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                      onTap:(){
                                        // cartProvider.removeFromCart(product);
                                      },
                                      child: Icon(Icons.delete,color: appBarColor))
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),

                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 30,
              color: Colors.grey.shade300,
              child: Center(child: Text("Price Detail",style: TextStyle(color: kThemeColor),)),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Cart Total:",style: TextStyle(color: kThemeColor,fontWeight: FontWeight.bold),),
                          Text("500.0",style: TextStyle(color: kThemeColor,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Discount Total:",style: TextStyle(color: kThemeColor,fontWeight: FontWeight.bold),),
                          Text("0.0",style: TextStyle(color: kThemeColor,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Grand Total:",style: TextStyle(color: kThemeColor,fontWeight: FontWeight.bold),),
                          Text(grandTotal.toString(),style: TextStyle(color: kThemeColor,fontWeight: FontWeight.bold),),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width/2,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CheckoutPage(grandTotal: grandTotal)));
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  primary:  kThemeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                        10.0),
                  ),
                ),
                child: Text(
                  "Checkout",
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
