import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/my_data.dart';
import 'package:flutter_application_1/utils/database_helper.dart';

class MyDataProvider extends ChangeNotifier {
  List _dataList = [];
  Map<DateTime, List> _events = {};

  Map<DateTime, List> get events => _events;

  List get dataList => _dataList;

  // ! Получить товар из базы данных и обновить список на экране
  void getData([DateTime? selectedDate]) async {
    final dataList = await DatabaseHelper.instance.getData(selectedDate);
    _dataList = dataList;
    notifyListeners();
  }

  // ! Добавить товар в базу данных и обновить список на экране
  void addData(MyData data) async {
    final id = await DatabaseHelper.instance.insertData(data);
    final newData = data.copyWith(id: id);
    _dataList.add(newData);
    loadProducts();
    notifyListeners();
  }

  void deleteData(int id) async {
    await DatabaseHelper.instance.deleteData(id);
    loadProducts();
    getData();
  }

  void editData(int id, Map<String, dynamic> newData) async {
    await DatabaseHelper.instance.editData(id, newData);
    loadProducts();
    getData();
  }

  void loadProducts() async {
    _events = {};

    List<MyData> products = await DatabaseHelper.instance.getData();
    for (MyData product in products) {
      if (_events[product.date] == null) _events[product.date] = [];
      _events[product.date]?.add(product);
    }
  }
}
