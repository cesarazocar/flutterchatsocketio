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
                  //icono

                  child: type == 'newuser'
                      ? new IconTheme(
                          data: new IconThemeData(color: Colors.green),
                          child: new Icon(Icons.info),
                        )
                      : new Text(/*_username[0]*/ user[0] + user[1]))),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(/*_username*/ user,
                  style: Theme.of(context).textTheme.subhead),
              new Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: new Text(text),
              )
            ],
          )
        ],
      ),
    );
  }
}
