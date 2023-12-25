import 'package:aws/today.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mmcdash.dart';

class menu extends StatefulWidget {
  final String user;
  final String pass;
  final String main;
  final String logo;
  final String mcc;
  final String type;
  const menu(
      {super.key,
      required this.user,
      required this.pass,
      required this.main,
      required this.logo,
      required this.mcc,
      required this.type});
  @override
  State<menu> createState() => _menuState();
}

class _menuState extends State<menu> {
  var users;
  var mccs;
  bool sflag = false;
  TextEditingController search = TextEditingController();
  String _searchResult = '';
  var maindata = [];
  List<dynamic> usersFiltered = [];
  initState() {
    sflag = false;
    super.initState();
    // nextScreen();
    users = (widget.main).split(",");
    mccs = (widget.mcc).split("&");
    print('FFFFF--->${mccs}');
    getmcc();
  }

  getmcc() {
    for (int i = 0; i < mccs.length; i++) {
      var logos = widget.logo.split("&");
      if (mccs[i].contains(',')) {
        for (int j = 0; j < mccs[i].split(",").length; j++) {
          maindata.add({
            'username': users[i].toUpperCase(),
            'mcc': mccs[i].split(",")[j],
            'logo': logos[i],
          });
          usersFiltered.add({
            'username': users[i].toUpperCase(),
            'mcc': mccs[i].split(",")[j],
            'logo': logos[i],
          });
        }
      } else {
        maindata.add({
          'username': users[i].toUpperCase(),
          'mcc': mccs[i],
          'logo': logos[i],
        });
        usersFiltered.add({
          'username': users[i].toUpperCase(),
          'mcc': mccs[i],
          'logo': logos[i],
        });
      }
    }
    print("data:${maindata}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text("ADMIN")),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    sflag = !sflag;
                    search.clear();
                    usersFiltered = maindata;
                  });
                },
                icon: Icon(Icons.search)),
          ],
        ),
        body: Column(
          children: [
            sflag
                ? Container(
                    color: Theme.of(context).primaryColor,
                    child: new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: ListTile(
                          leading: Icon(Icons.search),
                          title: TextField(
                              controller: search,
                              decoration: InputDecoration(
                                  hintText: "Search", border: InputBorder.none),
                              onChanged: (value) {
                                setState(() {
                                  _searchResult = value;
                                  print(value);
                                  usersFiltered = maindata
                                      .where((user) =>
                                          (user["username"])
                                              .toLowerCase()
                                              .contains(_searchResult) ||
                                          (user["mcc"].toLowerCase())
                                              .contains(_searchResult))
                                      .toList();
                                });
                              }),
                          trailing: IconButton(
                            icon: new Icon(Icons.cancel),
                            onPressed: () {
                              search.clear();
                              setState(() {
                                usersFiltered = maindata;
                              });
                              // onSearchTextChanged('');
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
            Expanded(
              child: ListView.builder(
                  itemCount: usersFiltered.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            if (usersFiltered[index]["mcc"] == "ALL") {
                              var indexofs = users.indexOf(usersFiltered[index]
                                      ["username"]
                                  .toLowerCase());
                              print(users);
                              usersFiltered[index]["username"].toUpperCase() == "MMC"
                                  ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyHomePage1(
                                                user:
                                                    '${usersFiltered[index]["username"].toLowerCase()}',
                                                pass: widget.pass,
                                                main:
                                                    '${usersFiltered[index]["username"].toLowerCase()}',
                                                logo:
                                                    '${usersFiltered[index]["logo"]}',
                                                mcc: mccs[indexofs],
                                                type: widget.type,
                                              )),
                                    )
                                  : Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyHomePage(
                                                user:
                                                    '${usersFiltered[index]["username"].toLowerCase()}',
                                                pass: widget.pass,
                                                main:
                                                    '${usersFiltered[index]["username"].toLowerCase()}',
                                                logo:
                                                    '${usersFiltered[index]["logo"]}',
                                                mcc: mccs[indexofs],
                                                type: widget.type,
                                              )),
                                    );
                            } else {
                              usersFiltered[index]["username"].toUpperCase() == "MMC"?
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyHomePage1(
                                          user:
                                              '${usersFiltered[index]["username"].toLowerCase()}',
                                          pass: widget.pass,
                                          main:
                                              '${usersFiltered[index]["username"].toLowerCase()}',
                                          logo:
                                              '${usersFiltered[index]["logo"]}',
                                          mcc: usersFiltered[index]["mcc"],
                                          type: widget.type,
                                        )),
                              ):Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyHomePage(
                                      user:
                                      '${usersFiltered[index]["username"].toLowerCase()}',
                                      pass: widget.pass,
                                      main:
                                      '${usersFiltered[index]["username"].toLowerCase()}',
                                      logo:
                                      '${usersFiltered[index]["logo"]}',
                                      mcc: usersFiltered[index]["mcc"],
                                      type: widget.type,
                                    )),
                              );
                            }
                          },
                          child: Card(
                            child: ListTile(
                              title: Center(
                                  child: Text(
                                      '${usersFiltered[index]['username'].toUpperCase()}-${usersFiltered[index]['mcc']}')),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ],
        ));
  }
}
