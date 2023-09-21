import 'package:flutter/material.dart';

class TableSelectionModel extends ChangeNotifier {
  int _selectedTableId = 0;

  int get selectedTableId => _selectedTableId;

  void selectTable(int tableId) {
    _selectedTableId = tableId;
    notifyListeners();
  }
}
