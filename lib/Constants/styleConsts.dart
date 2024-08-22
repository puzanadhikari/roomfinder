import 'package:flutter/material.dart';

var appBarColor = Colors.lightGreen;
var kThemeColor = const Color(0xFF125F66);
const kTextStyleWhite = TextStyle(fontSize: 45.0, color: Colors.white,fontWeight: FontWeight.bold);
const kMTextColor = Color(0xff343434);
const kTextColor = Color(0xFFFDFDFD);

const kHeightSmall = SizedBox(height:12);
const kHeightMedium = SizedBox(height:30);

const kFormFieldDecoration = InputDecoration(
    labelStyle: TextStyle(color: Color(0xff041536),fontSize: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15.0))
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15.0))
  ),
  focusedBorder:OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  )
);

const kBoxDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(Radius.circular(50.0))
);
