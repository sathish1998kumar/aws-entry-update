import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatefulWidget {
  final String user;
  final String pass;
  final String main;
  final String logo;
  final String mcname;
  final String type;
  final String mcc;
  const Setting(
      {super.key,
      required this.user,
      required this.pass,
      required this.main,
      required this.logo,
      required this.mcname,
      required this.type,
      required this.mcc});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool light = false;
  void initState() {
    get();
  }

  get() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var sett = preferences.getString('settings') ?? "";
    setState(() {
      print(sett);
      if (sett == "ok") {
        light = true;
      } else {
        light = false;
      }
    });
  }
  getlight(value){
    setState(() {
      light = value;
    });
  }
  Future<void> _dialogBuilder(BuildContext context,light) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text('ALERT'),
          content: Text(
            light?'Are You Sure want to Enable !!!':"Are You Sure want to Disable !!!",
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () async {
                Navigator.of(context).pop();
                // SharedPreferences prefrences =
                // await SharedPreferences.getInstance();
                // await prefrences.remove("username");
                // getlight(light);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('OK'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                getlight(light);
                if(light) {

                  prefs.setString('settings', 'ok');
                }
                else{
                  prefs.setString('settings', 'can');
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text(
                    "General Settings",
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 5.0, 0, 0),
                  child: Text(
                    "Empty Weight as Weight out",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 5.0, 0, 0),
                  child: Switch(
                    value: light,
                    activeColor: Colors.teal,
                    onChanged: (bool value) {
                      _dialogBuilder(context,value);

                    },
                  ),
                )
              ],
            )
          ],
        ));
  }
}


