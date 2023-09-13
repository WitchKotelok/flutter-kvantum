 import 'package:intl/intl.dart';

class MyData {
    final int? id;
    final String title;
    final DateTime date;
  
    final String imageUrl;
  
    MyData({
      this.id,
      required this.title,
      required this.date,
      required this.imageUrl,
    });
  
    // ! Методы toMap() и fromMap() нужны для более удобной работы с объектами 
    // как со словарем Map
    Map<String, dynamic> toMap() {
      return {
        'id': id,
        'title': title,
        // 'date': date.toIso8601String(),
        'date': DateFormat('yyyy-MM-dd').format(date),
        'imageUrl': imageUrl,
      };
    }
  
    factory MyData.fromMap(Map<String, dynamic> map) {
      return MyData(
        id: map['id'],
        title: map['title'],
        date: DateTime.parse(map['date']),
        imageUrl: map['imageUrl'],
      );
    }
  
    // ! Метод copyWith() создает новый объект MyData на основе текущего объекта 
    // но с измененными некоторыми свойствами.
    // Например, для изменения даты или изменения текста без изменения 
    // идентификатора или URL изображения.
    MyData copyWith({
      int? id,
      String? title,
      String? imageUrl,
      DateTime? date,
      int? number,
    }) {
      return MyData(
        id: id ?? this.id,
        title: title ?? this.title,
        imageUrl: imageUrl ?? this.imageUrl,
        date: date ?? this.date,
      );
    }
  }
