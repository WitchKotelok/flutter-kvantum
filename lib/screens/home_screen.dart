import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/my_data.dart';
import 'package:flutter_application_1/providers/my_data_provider.dart';
import 'package:flutter_application_1/screens/add_data_form.dart';
import 'package:flutter_application_1/screens/data_details_screen.dart';
import 'package:flutter_application_1/screens/edit_data_form.dart';
// import 'package:flutter_application_1/utils/utils.dart';
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

  late LinkedHashMap<DateTime, List<dynamic>> kEvents;

  @override
  void initState() {
    context.read<MyDataProvider>().loadProducts();
    super.initState();
  }

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
      context.read<MyDataProvider>().getData(_selectedDate);
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  void _clearFilter() {
    setState(() {
      _selectedDate = null;
    });
    context.read<MyDataProvider>().getData();
  }

  void _viewDataDetails(BuildContext context, MyData data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DataDetailsScreen(data: data)),
    );
  }

  int getHashCode(DateTime k) => k.day * 1000000 + k.month * 10000 + k.year;

  @override
  Widget build(BuildContext context) {
    kEvents = LinkedHashMap<DateTime, List<dynamic>>(
      equals: isSameDay,
      hashCode: getHashCode,
    );

    kEvents.addAll(context.watch<MyDataProvider>().events);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Календарь', style: TextStyle(color: Colors.white),),
          ],
        ),
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
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      if (date.isBefore(DateTime.now())) {
                        // Если дата меньше текущей, используйте красный маркер
                        return Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange,
                          ),
                        );
                      } else {
                        // Иначе используйте зеленый маркер
                        return Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 16, 109, 19),
                          ),
                        );
                      }
                    }
                    return Container();
                  },
                ),
                eventLoader: _getEventsForDay,
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
                    const SizedBox(width: 20),
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
                                builder: (context) => EditDataForm(data: data),
                              ),
                            ),
                            icon: const Icon(Icons.edit_note, color: Colors.orange,),
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                context
                                    .read<MyDataProvider>()
                                    .deleteData(data.id);
                              },
                              icon: const Icon(Icons.delete_outline, color: Colors.orange,)),
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
