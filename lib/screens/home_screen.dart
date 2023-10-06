import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/my_data.dart';
import 'package:flutter_application_1/providers/my_data_provider.dart';
import 'package:flutter_application_1/screens/add_data_form.dart';
import 'package:flutter_application_1/screens/data_details_screen.dart';
import 'package:flutter_application_1/screens/edit_data_form.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Реализация фильтра по данным
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      Provider.of<MyDataProvider>(context, listen: false)
          .getData(_selectedDate);
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedDate = null;
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
        title: const Text('Календарь'),
        backgroundColor: Colors.green,
      ),
      body: Consumer<MyDataProvider>(
        builder: (context, provider, child) {
          final dataList = provider.dataList;
          final filteredDataList = _selectedDate != null
              ? dataList
                  .where((data) =>
                      DateFormat('yyyy-MM-dd').format(data.date) ==
                      DateFormat('yyyy-MM-dd').format(_selectedDate!))
                  .toList()
              : dataList.toList();
          return Column(
            children: [
              //!
              TableCalendar(
                locale: 'ru_RU',
                firstDay: DateTime.utc(1900, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDate, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.lightGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    return _marker(day);
                  },
                ),
              ),
              //!
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                        : 'Все'),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _selectedDate != null ? _clearFilter : null,
                      child: const Text(
                        'Все напоминания',
                        textAlign: TextAlign.center,
                      ),
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
                          subtitle: Text(
                            DateFormat('yyyy-MM-dd').format(data.date),
                          ),
                          leading: IconButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditDataForm(data: data))),
                            icon: Icon(Icons.edit),
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                Provider.of<MyDataProvider>(context,
                                        listen: false)
                                    .deleteData(data.id);
                              },
                              icon: Icon(Icons.delete)),
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

  Widget _marker(DateTime date/*, List<MyData> products*/) {

    // List<Widget> markers = [];
    // final myProducts = Provider.of<MyDataProvider>(context);
    // Map<DateTime, List<MyData>> _products = {};
    //   (element) {
    //     markers.add(Padding(
    //       padding: EdgeInsets.only(bottom: 2.0),
    //       child: Container(
    //         width: 3,
    //         height: 3,
    //         decoration: BoxDecoration(
    //           color: Colors.blue,
    //           shape: BoxShape.circle
    //         ),
    //       ),
    //     ));
    //   };

    return Row(children:/*markers*/[]);
  }
}
