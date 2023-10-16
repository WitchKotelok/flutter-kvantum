import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/my_data.dart';

class DataDetailsScreen extends StatelessWidget {
    final MyData data;
  
    const DataDetailsScreen({Key? key, required this.data}) : super(key: key);
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Подробно о товаре', style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.green,
          iconTheme: IconThemeData(color: Colors.white),
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
