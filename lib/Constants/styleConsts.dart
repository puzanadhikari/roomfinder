import 'package:flutter/material.dart';

var appBarColor = Colors.lightGreen;
var kThemeColor = const Color(0xFF125F66);
const kTextStyleWhite = TextStyle(fontSize: 45.0, color: Colors.white,fontWeight: FontWeight.bold);
const kMTextColor = Color(0xff343434);
const kTextColor = Color(0xFFFDFDFD);

const kHeightSmall = SizedBox(height:12);
const kHeightMedium = SizedBox(height:30);

InputDecoration kFormFieldDecoration = InputDecoration(
  labelStyle: const TextStyle(
      color: Colors.grey,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(
      color: Colors.grey.shade300,
      width: 2.0,
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(
      color: Colors.grey.shade300,
      width: 2.0,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(
      color: kThemeColor,
      width: 1,
    ),
  ),
  filled: true,
  fillColor: Colors.grey.shade50,
  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
  floatingLabelBehavior: FloatingLabelBehavior.auto,
  hintStyle: TextStyle(
    color: Colors.grey.shade400,
    fontSize: 16,
    fontStyle: FontStyle.italic,
  ),
);

const kBoxDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(Radius.circular(50.0))
);
