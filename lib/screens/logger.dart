import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:network_logger/network_logger.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Logger',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final client = Dio();

  @override
  void initState() {
    super.initState();
    NetworkLoggerOverlay.attachTo(context);
    client.interceptors.add(DioNetworkLogger());
  }

  void example1() {
    client.get(
        'https://2embed.biz/play/play.php?imdb=tt1632708&token=d1IwTitINEdZZEVDZkE4M2FkUlJTQT09');
  }

  void example2() {
    client.get('https://jsonplaceholder.typicode.com/todos');
  }

  void example3() {
    client.delete('https://google.com/some-resource');
  }

  void example4() {
    client.post(
      'https://run.mocky.io/v3/c80877c3-8d4a-477b-9c45-a1441c34a6b6',
      data: <String, dynamic>{
        'products': 5,
        'foo': 'bar',
        'hello': [
          'world',
          'dunya',
        ]
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network Logger'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Example 1'),
            subtitle: Text('Flutter website'),
            onTap: example1,
          ),
          ListTile(
            title: Text('Example 2'),
            subtitle: Text('Json placeholder'),
            onTap: example2,
          ),
          ListTile(
            title: Text('Example 3'),
            subtitle: Text('404 or something else'),
            onTap: example3,
          ),
          ListTile(
            title: Text('Example 4'),
            subtitle: Text('Mock api'),
            onTap: example4,
          ),
        ],
      ),
    );
  }
}
