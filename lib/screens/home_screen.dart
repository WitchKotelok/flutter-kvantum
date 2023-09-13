import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/my_data.dart';
import 'package:flutter_application_1/providers/my_data_provider.dart';
import 'package:flutter_application_1/screens/add_data_form.dart';
import 'package:flutter_application_1/screens/data_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});
  
    @override
    _HomeScreenState createState() => _HomeScreenState();
  }
  
  class _HomeScreenState extends State<HomeScreen> {
    DateTime? selectedDate;
    
    // Реализация фильтра по данным
    void _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime.now(),
      );
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
        });
        Provider.of<MyDataProvider>(context, listen: false).getData(selectedDate);
      }
    }
  
    void _clearFilter() {
      setState(() {
        selectedDate = null;
      });
      Provider.of<MyDataProvider>(context, listen: false).getData();
    }
  
    void _viewDataDetails(BuildContext context, MyData data) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DataDetailsScreen(data: data)),
      );
    }
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Работа с SQLite'),
        ),
        body: Consumer<MyDataProvider>(
          builder: (context, provider, child) {
            final dataList = provider.dataList;
            final filteredDataList = selectedDate != null
                ? dataList
                    .where((data) =>
                        DateFormat('yyyy-MM-dd').format(data.date) ==
                        DateFormat('yyyy-MM-dd').format(selectedDate!))
                    .toList()
                : dataList.toList();
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                          : 'All dates'),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('Выбрать дату'),
                      ),
                      ElevatedButton(
                        onPressed: selectedDate != null ? _clearFilter : null,
                        child: const Text('Обновить фильтр'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredDataList.length,
                    itemBuilder: (context, index) {
                      final data = filteredDataList[index];
                      return GestureDetector(
                        onTap: () => _viewDataDetails(context, data),
                        child: Card(
                          child: ListTile(
                            title: Text(data.title),
                            subtitle:
                                Text(DateFormat('yyyy-MM-dd').format(data.date)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDataForm()),
          ),
          child: const Icon(Icons.add),
        ),
      );
    }
  }