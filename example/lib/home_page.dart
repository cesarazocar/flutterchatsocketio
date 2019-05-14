import 'package:flutter/material.dart';
import 'package:flutter_socket_io_example/chat_screen.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Flutter Socket.io Chat"), //toolbar
        ),
        body: new ChatScreen());
  }
}
