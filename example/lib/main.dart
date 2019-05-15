import 'package:flutter/material.dart';
import 'package:flutter_socket_io_example/home_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "SocketIO Chat App",
        theme: new ThemeData(primarySwatch: Colors.teal),//indigo,teal,amber
        home: new HomePage()
    );
  }
}

