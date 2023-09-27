 import 'package:flutter_application_1/models/my_data.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
    // ! Статическая переменная instance, которая содержит единственный экземпляр 
    // класса. Это позволяет использовать единственный экземпляр класса для работы 
    // c базой данных во всем приложении.
    // ! Такой архитектурный подход называется Singletone
    static final DatabaseHelper instance = DatabaseHelper._instance();
    static Database? _db;
  
    // Приватный конструктор используется для создания единственного экземпляра 
    // класса DatabaseHelper.
    DatabaseHelper._instance();
  
    // Имя таблицы для работы с данными товаров
    String table = 'products';
  
    // Если база данных создана то работаем с ней, если нет то создаем базу данных
    Future<Database> get db async {
      _db ??= await _initDb();
      return _db!;
    }
  
    // Инициализируем базу данных, создаем файл базы с названием my_database.db
    // Создаем в базе таблицу products с полями id, title, imageUrl, date
    Future<Database> _initDb() async {
      String path = await getDatabasesPath();
      path = '$path/my_database.db';
      final database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE $table(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, imageUrl TEXT, date TEXT)',
          );
        },
      );
      return database;
    }

        // Вставляем данные в БД
    Future<int> insertData(MyData data) async {
      final db = await instance.db;
      return await db.insert(instance.table, data.toMap());
    }
  
    // Получаем данные из БД
    Future<List<MyData>> getData([DateTime? selectedDate]) async {
      final db = await instance.db;
      final List<Map<String, dynamic>> maps = await db.query(
        instance.table,
        where: selectedDate != null ? 'date LIKE ?' : null,
        whereArgs: selectedDate != null
            ? ['${DateFormat('yyyy-MM-dd').format(selectedDate)}%']
            : null,
      );
  
      // Формируем список и преобразуем его в словарь, для удобный работы как 
      // с объектом
      return List.generate(maps.length, (i) {
        return MyData.fromMap(maps[i]);
      });
    }

    Future<int> deleteData(int id) async {
      final db = await instance.db;
      return await db.delete(instance.table, where: 'id LIKE ?', whereArgs: [id]);
    }

    Future<void> editData(int id, Map<String, dynamic> newData) async {
    final db = await instance.db;
    try {
      await db.update(instance.table, newData, where: 'id LIKE ?', whereArgs: [id]);
      
    } catch (e) {
      print('Ошибка + ${e}');
    }
  }
  }