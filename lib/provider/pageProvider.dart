import 'package:flutter/material.dart';

class PageProvider with ChangeNotifier {
  int _page = 0;

  int get page => _page;


  String _choice="From Main";
  String get choice =>_choice;

  void setPage(int index) {
    _page = index;
    notifyListeners();
  }

  void setChoice (String choiceFromUser){
    _choice = choiceFromUser;
    notifyListeners();
  }
}
