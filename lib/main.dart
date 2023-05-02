import 'dart:collection';
import 'dart:math';

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
        title: title,
        theme: ThemeData(
          primaryColor: Colors.blue,
        ),
        home: const MainPage(title: title),
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

  Queue<Map> elementQueue() {
    // Creating a Queue
    Queue<Map> elements = Queue<Map>();

    // Adding testelement in a Queue
    //Achtung!!! BL wird immer an erster Stelle angezeigt und ist nur zum testen
    elements.add(Player.curveBL);

    Random rnd;
    int min = 0;
    int max = 5;
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

    print(elements);
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
              width: 300,
              child: ElevatedButton(
                child: Text(elementQueue().toString()),
                onPressed: () => elementQueue(),
              )),
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
    switch (value) {
      case Player.start:
        return "START";
      case Player.finish:
        return "FIN";
      case Player.straightHorizontal:
        return "horizont";
      case Player.straightVertical:
        return "vertical";
      case Player.curveBL:
        return "BL";
      case Player.curveLT:
        return "LT";
      case Player.curveRB:
        return "RB";
      case Player.curveTR:
        return "TR";

      default:
        return "none";
    }
  }

  Widget buildField(int x, int y) {
    matrix[1][2] = Player.curveTR;

    final value = matrix[x][y];
    final color = getFieldColor(value);
    print(value);

    return Container(
      margin: const EdgeInsets.all(2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(size, size),
          primary: color,
        ),
        child: Text(getPlayerType(value), style: const TextStyle(fontSize: 14)),
        onPressed: () => selectField(value, x, y),
      ),
    );
  }

  void selectField(Map value, int x, int y) {
    if (value == Player.none) {
      final newValue = lastMove == Player.X ? Player.O : Player.X;

//TODO
      setState(() {
        var helper = elementQueue();
        matrix[x][y] = "clicked" as Map;
      });

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
