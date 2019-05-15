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
  TextEditingController mUserController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  bool _socketConnected = false;

  String actions = "Active el switch para conectar";
  Icon _actionIcon = new Icon(Icons.cloud_off);
  Color _actionIconColor = Colors.red;
  String username;
  SocketIO socketIO;

  bool _enabledUserText = false;
  bool _enabledText = false;
  String _inputHint = "Type a message";
  bool typing = false;
  Color _userIconColor = Colors.black12;

  void _onSwitched(bool value) => {
        setState(() => {_socketConnected = value}),
        if (_socketConnected)
          {
            if (socketIO == null)
              {_connectSocket01()}
            else
              {socketIO.connect()},
            setState(() {
              actions = "Ingresa tu nombre de usuario";
              _actionIconColor = Colors.green;
              _actionIcon = new Icon(Icons.arrow_drop_up);
              _enabledUserText = true;
              _userIconColor = Colors.indigo;
              _inputHint = "Type a message";
            })
          }
        else
          {
            socketIO.disconnect(),
            _inputHint = "please connect first",
            _actionIcon = new Icon(Icons.cloud_off),
            _actionIconColor = Colors.red,
            actions = "Estás desconectado, conectar",
            _userIconColor = Colors.black12,
            _enabledText = false,
            _enabledUserText = false
          },
      };

  @override
  void initState() {
    super.initState();
  }

//imprimir mensajes en pantalla
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
    socketIO.subscribe("chat:closing", _onClosing);
    //connect socket
    socketIO.connect();
  }

//enviar usuario conectado a server
  _newUser(String user) async {
    if (user.length > 0) {
      socketIO.sendMessage("chat:newuser", "{username:" + user + "}");
      setState(() => {
            actions = 'Bienvenido al chat $user',
            _actionIcon = new Icon(Icons.person_pin)
          });
    }
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
    String username = dataMapa['username'];
    typing = dataMapa['typing'];
    if (typing) {
      print("$username is typing true");
      setState(() {
        actions = username + " is Typing";
        _actionIcon = new Icon(Icons.textsms);
      });
    } else {
      print("$username is typing false");
      setState(() {
        actions = "";
        _actionIcon = new Icon(Icons.person_pin);
        _actionIcon = null;
      });
    }
  }

  _onClosing(dynamic data) {
    Map<String, dynamic> dataMapa = jsonDecode(data);
    String username = dataMapa['username'];
    _handleSubmitted("left the room", username, "closing");
  }

  _disconnectSocket() {
    if (socketIO != null) {
      socketIO.disconnect();
    }
  }

//user widget
  Widget _userComposerWidget() {
    return new IconTheme(
      data: new IconThemeData(color: Colors.indigo),
      child: new Container(
        //input
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
                child: new TextField(
              controller: mUserController,
              enabled: _enabledUserText,
              decoration:
                  new InputDecoration.collapsed(hintText: "your username here"),
            )),
            new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconTheme(
                  data: new IconThemeData(color: _userIconColor),
                  child: new IconButton(
                      icon: new Icon(Icons.person_add),
                      onPressed: () {
                        if (_enabledUserText) {
                          _newUser(mUserController.text);
                          setState(() {
                            _enabledText = true;
                            _enabledUserText = !_enabledUserText;
                            _userIconColor = Colors.black12;
                          });
                          print("enabled user text state : ");
                        } else {
                          _showSnackBar(context,"Connect first");
                          print("icon disabled");
                        }
                      }),
                )),
            new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: new Switch(
                  value: _socketConnected,
                  activeColor: Colors.indigo,
                  onChanged: _onSwitched,
                ))
          ],
        ),
      ),
    );
  }

//actions widget
  Widget _actionsComposerWidget() {
    return new IconTheme(
      data: new IconThemeData(color: _actionIconColor),
      child: new Container(
        //input
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child:
        new Row(
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _actionIcon,
            ),
            new Flexible(
              child: new Text(actions, style: new TextStyle(fontSize: 20.0)),
            ),
      if(!_socketConnected)
      new Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: new IconTheme(
          data: new IconThemeData(color: Colors.red),
          child: new Icon(Icons.arrow_drop_up),
        )
      )
          ],
        ),
      ),
    );
  }

//input widget
  Widget _textComposerWidget() {
    return new IconTheme(
      data: new IconThemeData(color: Colors.teal),
      child: new Container(
        //input
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                  decoration:
                      new InputDecoration.collapsed(hintText: _inputHint),
                  controller: _textController,
                  enabled: _enabledText

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

  void _showSnackBar(BuildContext context, String txt) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(txt),
        action: SnackBarAction(
            label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}
