import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/my_data.dart';
import 'package:flutter_application_1/utils/database_helper.dart';

class MyDataProvider extends ChangeNotifier {
    List _dataList = [];
  
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
      notifyListeners();
    }

    void deleteData(int id) async {
      await DatabaseHelper.instance.deleteData(id);
      getData();
    }

    void editData(int id,  Map<String, dynamic> newData) async {
      await DatabaseHelper.instance.editData(id, newData);
      getData();
    }
  }
