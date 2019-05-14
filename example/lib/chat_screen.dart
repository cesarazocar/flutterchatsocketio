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
  bool _connected = false;
  String actions = "Presione el boton verde para conectar";
  String username;
  SocketIO socketIO;
  Icon action;
  bool _enabledUserText = true;

  void _onSwitched(bool value) => {

        setState(() => _connected = value),

        if (_connected)
          {
            if (socketIO == null)
              {_connectSocket01()}
            else
              {socketIO.connect()},
          }else{
          socketIO.disconnect()
        },

      };

  @override
  void initState() {
    super.initState();
  }

  //imprimir mensaje en pantalla
  void _handleSubmitted(String text, String user, String type) {
    if (text.length > 0 && user.length > 0) {
      _textController.clear();
      ChatMessage message = new ChatMessage(text: text, user: user, type: type);
      setState(() {
        _messages.insert(0, message);
      });
    }
  }

  _connectSocket01() {



    socketIO =
        SocketIOManager().createSocketIO("http://192.168.1.87:3000", "/");

    //call init socket before doing anything
    socketIO.init();
    //subscribe event
    socketIO.subscribe("chat:newuser", _onNewUser);
    socketIO.subscribe("chat:message", _onMessage);
    socketIO.subscribe("chat:typing", _onTyping);
    //connect socket
    socketIO.connect();
  }

//enviar usuario conectado a server
  _newUser(String user) async {

    if (user.length > 0) {
      socketIO.sendMessage("chat:newuser", "{username:" + user + "}");
    }
    setState(() => actions = 'Bienvenido al chat $user');
  }

//enviar mensaje a server
  _sendMessage(String text, String user) async {
    if (user.length > 0 && text.length > 0) {
      //Enviarlo a socket
      socketIO.sendMessage("chat:message",
          '{"message":"' + text + '", "username": "' + user + '"}');
    }
  }

//recibir usuario conectado desde server
  _onNewUser(dynamic data) {
    print("se conecto un usuario: " + data);

    Map<String, dynamic> dataMap = jsonDecode(data);
     String username = dataMap['username'];

    _handleSubmitted('Se ha conectado', username, "newuser");
    /* usar para evento typing
    setState(() {

      actions = username + " is now connected";

    });*/
    //actions['username'];
  }

//recibir mensaje emitido desde server
  _onMessage(dynamic data) {
    Map<String, dynamic> dataMapa = jsonDecode(data);
    String mensaje = dataMapa['message'];
    String username = dataMapa['username'];

    _handleSubmitted(mensaje, username, "message");
  }

  _onTyping(dynamic data) {
    Map<String, dynamic> dataMapa = jsonDecode(data);
    String mensaje = dataMapa['message'];
    String username = dataMapa['username'];
    bool typing = dataMapa['typing'];

    if (typing) {
      setState(() {
        actions = username + " is Typing";
      });
    }
  }

  _socketStatus(dynamic data) {
    print("Socket status: " + data);
  }

  _disconnectSocket() {
    if (socketIO != null) {
      socketIO.disconnect();
    }
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
                  onPressed: () {
                    _newUser(mUserController.text);
                  }),
            ),
            new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: new Switch(
                  value: _connected,
                  activeColor: Colors.blue,
                  onChanged: _onSwitched,
                )

                /*
              new IconButton(
                  icon: new Icon(Icons.check_circle_outline),
                  color: Colors.green,


                  onPressed: () {
                    if (socketIO == null) {
                      _connectSocket01();
                    } else {
                      socketIO.connect();
                    }
                    setState(() {
                      actions = "Bienvenido al chat " + username;
                    });
                  }


                  ),*/
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
                  onPressed: () {
                    _sendMessage(_textController.text, mUserController.text);
                  }),
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
          //user container
          decoration: new BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: _userComposerWidget(), //llamado a widget user
        ),
        new Divider(
          height: 1.0,
        ),
        new Container(
          //actions container
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
          child: _textComposerWidget(), //llamado a widget input
        ),
      ],
    );
  }
}
