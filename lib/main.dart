import 'dart:collection';
import 'dart:math';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/utils.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'Pipe Dream';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Zeit: 00:59',
        theme: ThemeData(
          primaryColor: Colors.blue,
        ),
        home: const MainPage(title: 'Zeit: 00:59'),
      );
}

class MainPage extends StatefulWidget {
  final String title;

  const MainPage({
    required this.title,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class Player {
  static const none = {'t': 0, 'r': 0, 'b': 0, 'l': 0, 'm': 0};
  static const straightVertical = {'t': 1, 'r': 0, 'b': 1, 'l': 0, 'm': 1};
  static const straightHorizontal = {'t': 0, 'r': 1, 'b': 0, 'l': 1, 'm': 1};
  static const curveTR = {'t': 1, 'r': 1, 'b': 0, 'l': 0, 'm': 1};
  static const curveRB = {'t': 0, 'r': 1, 'b': 1, 'l': 0, 'm': 1};
  static const curveBL = {'t': 0, 'r': 0, 'b': 1, 'l': 1, 'm': 1};
  static const curveLT = {'t': 1, 'r': 0, 'b': 0, 'l': 1, 'm': 1};
  static const start = {'t': 0, 'r': 0, 'b': 1, 'l': 0, 'm': 1};
  static const finish = {'t': 1, 'r': 0, 'b': 0, 'l': 0, 'm': 1};

  static const X = 'X';
  static const O = 'O';
}

class _MainPageState extends State<MainPage> {
//hier muss alles rein, was setState() braucht

  Queue<Map> elements = Queue<Map>();

  String showQueue() {
    String buffer = '';
    for (int i = 1; i < elements.length; i++) {
      buffer = getPlayerType(elements.elementAt(i)) + '\n' + buffer;
    }
    return buffer;
  }

  Queue<Map> elementQueue() {
    // Creating a Queue

    // Adding testelement in a Queue
    //Achtung!!! BL wird immer an erster Stelle angezeigt und ist nur zum testen
    //elements.add(Player.curveBL);

    print(elements.length);
    int add = 1;
    if (elements.length == 0)
      add = 5;
    else
      elements.removeFirst();

    for (int i = 0; i < add; i++) {
      Random rnd;
      int min = 0;
      int max = 6;
      rnd = Random();
      var r = min + rnd.nextInt(max - min);

      switch (r) {
        case 0:
          elements.add(Player.curveTR);
          break;
        case 1:
          elements.add(Player.curveRB);
          break;
        case 2:
          elements.add(Player.curveBL);
          break;
        case 3:
          elements.add(Player.curveLT);
          break;
        case 4:
          elements.add(Player.straightHorizontal);
          break;
        case 5:
          elements.add(Player.straightVertical);
          break;
        default:
          elements.add(Player.none);
      }
    }

    print(getPlayerType(elements.first));
    setState(() {
      elements;
    });

    return elements;
  }

  static const double size = 80;

  Map<String, int> lastMove = Player.none;
  late List<List<Map>> matrix;

  @override
  void initState() {
    super.initState();

    setEmptyFields();
  }

  //Spielfeldgröße
  void setEmptyFields() => setState(
        () => matrix = List.generate(
          7,
          (_) => List.generate(9, (_) => Player.none),
        ),
      );

  //layout
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Color.fromARGB(255, 123, 143, 160),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          Container(
            color: Colors.yellow,
            height: double.infinity,
            width: 110,
            // child: ElevatedButton(
            //   child: Text(showQueue()),
            //   onPressed: () => false,
            // )
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () => false, child: Text(showQueue())),
                Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: ElevatedButton(
                        onPressed: () {
                          setEmptyFields();
                        },
                        child: Text("Restart")))
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: Utils.modelBuilder(matrix, (x, value) => buildRow(x)),
          ),
        ],
      ));

  Widget buildRow(int x) {
    final values = matrix[x];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: Utils.modelBuilder(
        values,
        (y, value) => buildField(x, y),
      ),
    );
  }

  Color getFieldColor(Map value) {
    switch (value) {
      case {'t': 0, 'r': 0, 'b': 0, 'l': 0, 'm': 0}:
        return Colors.red;
      case Player.none:
        return Colors.green;

      default:
        return Colors.blue;
    }
  }

  String getPlayerType(Map value) {
    //source: https://www.w3.org/TR/xml-entity-names/025.html
    String playertype = "";
    if (!(Platform.isMacOS)) {
      switch (value) {
        case Player.start:
          playertype = "^";
          break;
        case Player.finish:
          playertype = "U";
          break;
        case Player.straightHorizontal:
          playertype = "|";
          break;
        case Player.straightVertical:
          playertype = "-";
          break;
        case Player.curveBL:
          playertype = "7";
          break;
        case Player.curveLT:
          playertype = "J";
          break;
        case Player.curveRB:
          playertype = "F";
          break;
        case Player.curveTR:
          playertype = "L";
          break;
      }
    } else {
      switch (value) {
        case Player.start:
          playertype = "╥";
          break;
        case Player.finish:
          playertype = "╨";
          break;
        case Player.straightHorizontal:
          playertype = "║";
          break;
        case Player.straightVertical:
          playertype = "═";
          break;
        case Player.curveBL:
          playertype = "╗";
          break;
        case Player.curveLT:
          playertype = "╝";
          break;
        case Player.curveRB:
          playertype = "╔";
          break;
        case Player.curveTR:
          playertype = "╚";
          break;
      }
    }

    return playertype;
  }

  Widget buildField(int x, int y) {
    matrix[0][8] = Player.start;
    matrix[6][0] = Player.finish;

    final value = matrix[x][y];
    final color = getFieldColor(value);
    // print(value);

    return Container(
      margin: const EdgeInsets.all(2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(size, size),
          primary: color,
        ),
        child: Text(getPlayerType(value),
            style: const TextStyle(fontSize: 40, fontFamily: 'Courier')),
        onPressed: () => selectField(value, x, y),
      ),
    );
  }

  void selectField(Map value, int x, int y) {
    if (matrix[x][y] == Player.none) {
      setState(() {
        matrix[x][y] = elementQueue().first;
      });
    }

    if (value == Player.none) {
      final newValue = lastMove == Player.X ? Player.O : Player.X;

//TODO

      // setState(() {
      //   lastMove = newValue;
      //   matrix[x][y] = newValue;
      // });

      // if (isWinner(x, y)) {
      //   showEndDialog('Player $newValue Won');
      // }
      //  else if (isEnd()) {
      //   showEndDialog('Undecided Game');
      // }
    }
  }

  bool isEnd() =>
      matrix.every((values) => values.every((value) => value != Player.none));

//das in der Art vielleicht als Enddialog für das Ergebnis des Spiels
  Future showEndDialog(String title) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text('Press to Restart the Game'),
          actions: [
            ElevatedButton(
              onPressed: () {
                setEmptyFields();
                Navigator.of(context).pop();
              },
              child: Text('Restart'),
            )
          ],
        ),
      );
}
