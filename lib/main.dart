// Add a new route to hold the favorites.

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  GolfmitAppState createState() => GolfmitAppState();

}
class GolfmitAppState extends State<MyApp> {

  StockData stocks = new StockData();
  http.Client _httpClient;

  @override
  void initState() {
    super.initState();

    _httpClient = http.Client();
    _httpClient.get(_urlToFetch()).then<Null>((http.Response response) {
      final String json = response.body;
      if (json == null) {
        debugPrint('Failed to load stock data chunk ');
        _end();
        return;
      }
      const JsonDecoder decoder = JsonDecoder();
      for (Map f in decoder.convert(json)) {
        final ExerciseJSON stock = new ExerciseJSON(f["group"], f["name"]);
        setState(() {
          stocks._symbols.add(stock);
        });
      }
      _end();

    });

  }
  void _end() {
    _httpClient?.close();
    _httpClient = null;
  }
  String _urlToFetch() {
    return 'https://j47m00tt0j.execute-api.us-east-1.amazonaws.com/dev/exercises/list';
  }
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Golfmit',
      home: new Exercises(stocks),
    );
  }
}

class StockData extends ChangeNotifier {

  final List<ExerciseJSON> _symbols = <ExerciseJSON>[];

}

class ExerciseJSON {
  String name;
  String userid;

  ExerciseJSON(this.name, this.userid);
}


class Exercises extends StatefulWidget {
  const Exercises(this.stocks);

  final StockData stocks;

  @override
  ExercisesState createState() => new ExercisesState();
}



class ExercisesState extends State<Exercises> {
  final List<ExerciseJSON> _exercises = <ExerciseJSON>[];
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
             // new
  final TextEditingController _textController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Exercises'),

      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return const Divider();
          }
          final int index = i ~/ 2;

          if (_exercises.isEmpty) {
            _exercises.addAll(widget.stocks._symbols);
          }
          if (index >= _exercises.length) {
            return null;
          }

          return _buildRow(_exercises[index]);
        });
  }

  Widget _buildRow(ExerciseJSON pair) {

    return new ListTile(
      title: new Text(
        pair.name + ':'+ pair.userid,
        style: _biggerFont,
      ),
      trailing: new Icon(
         Icons.arrow_forward ,
      ),
      onTap: _openExercise,
    );
  }

  void _openExercise() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {

          return new Scaffold(
            appBar: new AppBar(
              title: new Text("Friendlychat"),
              elevation:
                Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0, ),
            body: new Column(                                        //modified
              children: <Widget>[                                         //new
                new Flexible(                                             //new
                  child: new ListView.builder(                            //new
                    padding: new EdgeInsets.all(8.0),                     //new
                    reverse: true,                                        //new
                    itemBuilder: (_, int index) => _messages[index],      //new
                    itemCount: _messages.length,                          //new
                  ),                                                      //new
                ),                                                        //new
                new Divider(height: 1.0),                                 //new
                new Container(                                            //new
                  decoration: new BoxDecoration(
                      color: Theme.of(context).cardColor),                  //new
                  child: _buildTextComposer(),                       //modified
                ),                                                        //new
              ],                                                          //new
            ),                                                            //new
          );

        },
      ),
    );
  }
  Widget _buildTextComposer() {
    return new Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(                                            //new
        children: <Widget>[                                      //new
          new Flexible(                                          //new
            child: new TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: new InputDecoration.collapsed(
                  hintText: "Send a result"),
            ),
          ),
          new Container(                                                 //new
            margin: new EdgeInsets.symmetric(horizontal: 4.0),           //new
            child: new IconButton(                                       //new
                icon: new Icon(Icons.send),                                //new
                onPressed:  () => _handleSubmitted(_textController.text),  //new
          ),  //new
          ),
        ],                                                        //new
      ),                                                          //new
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = new ChatMessage(                         //new
      text: text,                                                  //new
    );                                                             //new
    setState(() {                                                  //new
      _messages.insert(0, message);                                //new
    });                                                            //new
  }
}

const String _name = "Your Name";

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: new CircleAvatar(child: new Text(_name[0])),
          ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(_name, style: Theme.of(context).textTheme.subhead),
              new Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: new Text(text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}