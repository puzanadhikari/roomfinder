import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

import 'Constants/styleConsts.dart';
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wishlist"),
        centerTitle: true,
        backgroundColor: kThemeColor,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20,right: 20.0),
            child: Align(
              alignment: Alignment.topRight,
              child: LiteRollingSwitch(
                value: false,
                width: 100,
                textOn: 'On',
                textOff: 'Off',
                colorOn: Colors.green,
                colorOff: Colors.red,
                iconOn: Icons.done,
                iconOff: Icons.power_settings_new,
                animationDuration: const Duration(milliseconds: 100),
                onChanged: (bool state) {
                  print('turned ${(state) ? 'on' : 'off'}');
                },
                onDoubleTap: () {},
                onSwipe: () {},
                onTap: () {},
              ),
            ),
          )
        ],
      ),
    );
  }
}
