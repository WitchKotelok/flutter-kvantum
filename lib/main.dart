import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:provider/provider.dart';
  import 'package:sqflite/sqflite.dart';
  
  void main() {
    runApp(const MyApp());
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});
  
    @override
    Widget build(BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => MyDataProvider()..getData(),
        child: MaterialApp(
          title: 'My App',
          theme: ThemeData(
       // ! Теперь можно использовать новые компоненты из Material 3
       // ! И наконец-то выбирать любой цвет какой мы захотим для темы приложения
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 62, 183, 58),
            ),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        ),
      );
    }
  }

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
  }

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
  }

  class AddDataForm extends StatefulWidget {
    const AddDataForm({super.key});
  
    @override
    _AddDataFormState createState() => _AddDataFormState();
  }
  
  class _AddDataFormState extends State<AddDataForm> {
    // Глобальный ключ и контроллеры для работы с полями формы
    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController();
    final _imageController = TextEditingController();
    final _dateController = TextEditingController();
    DateTime _selectedDate = DateTime.now();
  
    // Очищаем контроллеры когда они не нужны, чтобы не занимать лищнюю память
    @override
    void dispose() {
      _textController.dispose();
      _imageController.dispose();
      _dateController.dispose();
      super.dispose();
    }
  
    void _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2035),
      );
      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
          _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
        });
      }
    }
  
    void _submitForm() {
      if (_formKey.currentState!.validate()) {
        final text = _textController.text.trim();
        final image = _imageController.text.trim();
        final date = _selectedDate;
        final data = MyData(
          title: text,
          imageUrl: image,
          date: date,
        );
        Provider.of<MyDataProvider>(context, listen: false).addData(data);
        Navigator.pop(context);
      }
    }
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Добавить товар'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Напишите название';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(
                    labelText: 'URL Изображения',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Вставьте URL изображения';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Дата',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () => _selectDate(context),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Выберете дату';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  class DataDetailsScreen extends StatelessWidget {
    final MyData data;
  
    const DataDetailsScreen({Key? key, required this.data}) : super(key: key);
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Подробно о товаре'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(data.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    data.date.toString(),
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

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