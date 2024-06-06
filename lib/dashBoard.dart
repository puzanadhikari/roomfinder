import 'package:flutter/material.dart';

import 'Constants/styleConsts.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 6,
            decoration: BoxDecoration(
                color: kThemeColor,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.elliptical(300, 100))),
            child: Center(
                child: Text("Current Location",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18))),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: TextFormField(
              decoration: KFormFieldDecoration.copyWith(
                prefixIcon: Icon(Icons.search_outlined,color: kThemeColor),
                suffixIcon: Icon(Icons.ac_unit_rounded,color: kThemeColor,),
                focusColor: kThemeColor
              ),
            ),
          )
        ],
      ),
    );
  }
}
