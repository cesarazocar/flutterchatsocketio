import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final String user;
  final String type;

  ChatMessage({this.text, this.user, this.type});

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(
                child: type == 'newuser'
                    ? new IconTheme(
                        data: new IconThemeData(color: Colors.blue),
                        child: new Icon(Icons.info),
                      )
                    : type == 'closing'
                        ? new IconTheme(
                            data: new IconThemeData(color: Colors.red),
                            child: new Icon(Icons.info),
                          )
                        : new Text(user[0] + user[1]),
                backgroundColor: Colors.black,
              )),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(user,
                  style: type == 'newuser'
                      ? TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)
                      : type == 'closing'
                          ? TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)
                          : Theme.of(context).textTheme.subhead),
              new Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: new Text(text,
                    style: type == 'newuser'
                        ? TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold)
                        : type == 'closing'
                            ? TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold)
                            : Theme.of(context).textTheme.subhead),
              )
            ],
          )
        ],
      ),
    );
  }
}
