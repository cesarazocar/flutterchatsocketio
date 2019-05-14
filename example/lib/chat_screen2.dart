import 'package:flutter/material.dart';
import 'package:flutter_socket_io_example/chat_message.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}





class ChatScreenState extends State<ChatScreen> {

  final TextEditingController _textController = new TextEditingController();
  final TextEditingController mUserController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  String actions = "Bienvenido al chat";
  String username;
  SocketIO socketIO;
  Icon action;
  bool _enabledUserText = true;

  @override
  void initState() {

    _connectSocket01();
    super.initState();
  }



  //imprimir mensaje en pantalla
  void _handleSubmitted(String text, String user) {
    if (text.length > 0 && user.length > 0) {
      _textController.clear();
      ChatMessage message = new ChatMessage(text: text, user: user);
      setState(() {
        _messages.insert(0, message);
      });
    }
  }

  _connectSocket01() {

    print("conectando socket 1 desde chat screen");
    socketIO =
        SocketIOManager().createSocketIO("http://192.168.1.87:3000", "/");

    //call init socket before doing anything
    socketIO.init();
    //subscribe event
    socketIO.subscribe("chat:newuser", _onNewUser);
    socketIO.subscribe("chat:message", _onMessage);
    //connect socket
    socketIO.connect();
  }

//enviar usuario conectado a server
  _newUser(String user) async {



    if (user.length > 0) {
      socketIO.sendMessage("chat:newuser", "{username:" + user + "}");
    }
  }

//enviar mensaje a server
  _sendMessage(String text, String user) async {
    if (user.length > 0 && text.length > 0) {
      //Enviarlo a socket
      socketIO.sendMessage(
          "chat:message", "{message:" + text + ",username:" + user + "}");
    }
  }

//recibir usuario conectado desde server
  _onNewUser(dynamic data) {
    print("se conecto un usuario: " + data);
    Map<String, dynamic> dataMap = jsonDecode(data);
    String username = dataMap['username'];
    setState(() {
      actions = username + " is now connected";
    });
    //actions['username'];
  }

//recibir mensaje emitido desde server
  _onMessage(dynamic data) {
    print("llego un mensaje desde el socket: " + data);
    /*
    print("llego un mensaje desde el socket: " + data);
    Map<String, dynamic> dataMapa = jsonDecode(data);
    String mensaje = dataMapa['message'];
    String username = dataMapa['username'];

    _handleSubmitted(mensaje, username);

    */
  }

  _socketStatus(dynamic data) {
    print("Socket status: " + data);
  }

  Widget _userComposerWidget() {
    return new IconTheme(
      data: new IconThemeData(color: Colors.blue),
      child: new Container(
        //input
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
                child: new TextField(
              controller: mUserController,
              decoration:
                  new InputDecoration.collapsed(hintText: "your username here"),
              //onSubmitted: _handleSubmitted,
            )),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.person_add),
                  onPressed: () => _newUser(mUserController.text)),
            )
          ],
        ),
      ),
    );
  }

  Widget _textComposerWidget() {
    //Input container

    return new IconTheme(
      data: new IconThemeData(color: Colors.green),
      child: new Container(
        //input
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                decoration:
                    new InputDecoration.collapsed(hintText: "Send a message"),
                controller: _textController,
                //onSubmitted: _handleSubmitted,
              ),
            ),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => {
                        _sendMessage(_textController.text, mUserController.text)
                      }),
            )
          ],
        ),
      ),
    );
  }

  Widget _actionsComposerWidget() {
    // widget actions

    return new IconTheme(
      data: new IconThemeData(color: Colors.green[700]),
      child: new Container(
        //input

        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: new Icon(Icons.person_pin),
              //Icons.person_pin textsms
            ),
            new Flexible(
              child: new Text(actions, style: new TextStyle(fontSize: 20.0)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Container(
          //input container
          decoration: new BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: _userComposerWidget(), //input
        ),
        new Divider(
          height: 1.0,
        ),
        new Container(
          //input container
          decoration: new BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: _actionsComposerWidget(), //llamado a widget actions
        ),
        new Divider(
          height: 1.0,
        ),
        new Flexible(
          child: new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) => _messages[index],
            itemCount: _messages.length,
          ),
        ),
        new Divider(
          height: 1.0,
        ),
        new Container(
          //input container
          decoration: new BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: _textComposerWidget(), //input
        ),
      ],
    );
  }
}
