import 'package:flutter/material.dart';

/// Flutter code sample for [Switch].

void main() => runApp(const SwitchApp());

class SwitchApp extends StatelessWidget {
  const SwitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SwitchExample(),
    );
  }
}

class SwitchExample extends StatefulWidget {
  const SwitchExample({super.key});

  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchExample> {
  bool light = false;

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Text("General Settings",style: TextStyle(fontSize: 20.0,color: Colors.teal,fontWeight: FontWeight.bold,decoration: TextDecoration.underline),),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 5.0, 0, 0),
                    child: Text("Empty Weight as Weight out",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0,5.0, 0, 0),
                    child: Switch(
                      value: light,
                      activeColor: Colors.teal,
                      onChanged: (bool value) {
                        _dialogBuilder(context);
                        setState(() {
                          light = value;
                        });
                      },
                    ),
                  )
                ],
              )
            ],
          )
      ),
    );
  }
}

Future<void> _dialogBuilder(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('ALERT'),
        content: const Text(
          'Are You Sure want to Enable !!!',
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('OK'),
            onPressed: () {

              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}