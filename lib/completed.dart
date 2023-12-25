import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'login.dart';

class Listdata extends StatefulWidget {
  final String user;
  final String pass;
  const Listdata({super.key, required this.user, required this.pass});

  @override
  State<Listdata> createState() => _ListdataState();
}

var datas1 = [];
var imgarr = [];
var imagePaths= [];

class _ListdataState extends State<Listdata> {
  var data = [];
  var datas = [];
  int sumover = 0;
  // int sumwaste = 0;
  String searchText = '';
  var filteredData = [];
  int tripcount = 0;
  int tripcomp = 0;
  int tripnot = 0;
  int ttweight = 0;
  int totalweight = 0;
  var _inputFormat = DateFormat('dd-MM-yyyy');
  var _selectedDate = DateTime.now();
  bool sel=false;
  void initState() {
    getdata(_selectedDate);
    getimg(_selectedDate);
  }

  getimg(_selectedDate) async {
    imgarr = [];
    var map = {
      "dateFilter": DateFormat("ddMMyyyy").format(_selectedDate),
    };
    print(map);
    String url = "http://dev.igps.io/avadi_new/api/filter_image.php";
    try {
      var response = await http.post(Uri.parse(url), body: (map));
      if (response.statusCode == 200) {
        setState(() {
          var result = response.body;
          final parsedJson = jsonDecode(result);
          List<String> keysList = parsedJson.keys.toList();
          List<dynamic> valuesList = parsedJson.values.toList();
          // print(valuesList);
          imgarr = valuesList;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid user!!"),
        ));
      }
    } catch (e) {
      print(e);
    }
    print(imgarr);
  }

  getdata(_selectedDate) async {
    tripcount = 0;
    tripnot = 0;
    tripcomp = 0;
    ttweight = 0;

    data = [];
    datas = [];
    datas1 = [];
    var map = {
      "action": "select_rf",
      "district": "ALL",
      "imei": "ALL",
      "over": "Daily Report",
      "panch": "ALL",
      "subzone": "ALL",
      "username": "tuty",
      "from": DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 00:00:00',
      "to": DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 23:59:59',
    };
    print(map);
    String url = "http://dev.igps.io/avadi_new/api/getrf_api.php";
    try {
      var response = await http.post(Uri.parse(url), body: (jsonEncode(map)));
      print(response);
      if (response.statusCode == 200) {
        setState(() {
          response.body == "" || response.body == "null"
              ? data = []
              : data = jsonDecode(response.body);
          // print(data);
          for (int s1 = 0; s1 < data.length; s1++) {
            var obj = data[s1];
            var vehi = obj["vehicles"];
            if (obj['vehicles'][0]['weight'] != "no") {
              datas1.add(data[s1]);
              datas.add(data[s1]);
            }
            for (int k1 = 0; k1 < vehi.length; k1++) {
              var obj1 = vehi[k1];
              var trip1 = obj1["trip"];
              // print(obj1["weight"]);
              if (k1 == 0) {
                if ((obj1["weight"] != "no")) {
                  tripcomp++;
                } else {
                  tripnot++;
                }
              }
              if ((obj1["weight"] != "no")) {
                sumover += int.parse(obj1["weight"]);
                if(int.parse(obj1["weight"])<int.parse(obj1["empty_weight"])){
                  ttweight = ttweight +0;
                }
               else{
                  ttweight = ttweight +
                      ((int.parse(obj1["weight"]) -
                          int.parse(obj1["empty_weight"])));
                }
              }
              if (trip1 != "-") {
                tripcount++;
              }
            }
          }
          filteredData = datas;
          // calculateSums();
          sel=true;
          // totalweight=int.parse(ttweight/1000);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid user!!"),
        ));
      }
    } catch (e) {
      print(e);
    }
    print("full${filteredData.length}");
  }
  //  calculateSums() {
  //   sumover = 0;
  //   sumwaste = 0;
  //
  //   for (var row in filteredData) {
  //    for(var kk in row["vehicles"]){
  //      if(kk["weight"]!="no") {
  //
  //        if(int.parse(kk["weight"])<int.parse(kk["empty_weight"])){
  //          sumwaste+=0;
  //        }
  //        else{
  //          sumwaste+=int.parse(kk["weight"])-int.parse(kk["empty_weight"]);
  //        }
  //      }
  //    }
  //     // sumId += int.parse((row.cells[0].child as Text).data!);
  //     // sumAge += int.parse((row.cells[2].child as Text).data!);
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Automatic Wigh Machine'),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
              child: IconButton(
                  onPressed: () {
                    getdata(_selectedDate);
                  },
                  icon: Icon(Icons.refresh)),
            ),
          ],
        ),
        drawer: Drawer(
          elevation: 16.0,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    '${widget.user.toUpperCase()}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  accountEmail: null,
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      "assets/avadi_logo.png",
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Dashboard'),
                  leading: const Icon(Icons.dashboard),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Listdata(user: widget.user, pass: widget.pass),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1.2,
                  color: Colors.black38,
                  thickness: 1,
                ),

                ListTile(
                  title: const Text('Logout'),
                  leading: const Icon(
                    Icons.logout,
                  ),
                  onTap: () async {
                    // SharedPreferences prefrences =
                    // await SharedPreferences.getInstance();
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are You Want Confirm to Logout ..'),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () async {
                                  SharedPreferences prefrences =
                                      await SharedPreferences.getInstance();
                                  await prefrences.remove("username");
                                  await prefrences.remove("password");
                                  // await prefrences.remove("location");
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen(),
                                      ));
                                },
                                child: const Text('OK'),
                              ),
                              ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel')),
                            ],
                          );
                        });

                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => HomeScreen(),
                    //   ),
                    // );
                  },
                ),
                // Divider(height: 0.2,),
              ],
            ),
          ),
        ),
        body:
        SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       // color: Colors.orangeAccent,
              //       // padding:EdgeInsets.fromLTRB(25,5, 0, 0),
              //       width: MediaQuery.of(context).size.width * 0.8,
              //       // height: 10,
              //       child: Card(
              //         elevation: 10,
              //         semanticContainer: true,
              //         clipBehavior: Clip.antiAliasWithSaveLayer,
              //         color: Colors.blueAccent,
              //         margin: EdgeInsets.all(10),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(100.0),
              //         ),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             // SizedBox(
              //             //   width: 10,
              //             // ),
              //             Container(
              //               width: 40,
              //               // color: Colors.redAccent,
              //               decoration: BoxDecoration(
              //                   shape: BoxShape.circle,
              //                   border: Border.all(
              //                       width: 2, color: Colors.redAccent)),
              //               child: Padding(
              //                 padding: const EdgeInsets.all(0),
              //                 child: Container(
              //                   decoration: BoxDecoration(
              //                     shape: BoxShape.circle,
              //                     color: Colors.red, // inner circle color
              //                   ),
              //                   child: IconButton(
              //                       onPressed: () {
              //                         setState(() {
              //                           _selectedDate = DateTime(
              //                               _selectedDate.year,
              //                               _selectedDate.month,
              //                               _selectedDate.day - 1);
              //                           // table(imei,_selectedDate);
              //                           getdata(_selectedDate);
              //                           getimg(_selectedDate);
              //                         });
              //                       },
              //                       icon: Icon(
              //                         Icons.remove,
              //                         color: Colors.white,
              //                       )),
              //                 ),
              //               ),
              //             ),
              //             InkWell(
              //               child: Container(
              //                 // width: 174,
              //
              //                 // padding: EdgeInsets.fromLTRB(0, 5, 40, 0),
              //                 child: Text(
              //                   '${_inputFormat.format(_selectedDate)}',
              //                   style: TextStyle(
              //                     color: Colors.white,
              //                     fontSize: 20,
              //                     fontWeight: FontWeight.w800,
              //                   ),
              //                 ),
              //               ),
              //               onTap: () async {
              //                 DateTime? pickedDate = await showDatePicker(
              //                     context: context,
              //                     initialDate: _selectedDate,
              //                     firstDate: DateTime(1950),
              //                     //DateTime.now() - not to allow to choose before today.
              //                     lastDate: DateTime.now());
              //
              //                 if (pickedDate != null) {
              //                   setState(() {
              //                     _selectedDate = pickedDate;
              //                     getdata(_selectedDate);
              //                     getimg(_selectedDate);
              //
              //                     // boundary1(boo,
              //                     //     _selectedDate);//utput date to TextField value.
              //                   });
              //                 } else {}
              //               },
              //             ),
              //             // SizedBox(
              //             //   width: 0,
              //             // ),
              //             Container(
              //               width: 40,
              //               // color: Colors.redAccent,
              //               decoration: BoxDecoration(
              //                   shape: BoxShape.circle,
              //                   border: Border.all(
              //                       width: 2, color: Colors.redAccent)),
              //               child: Padding(
              //                 padding: const EdgeInsets.all(0),
              //                 child: Container(
              //                   decoration: BoxDecoration(
              //                     shape: BoxShape.circle,
              //                     color: Colors.red, // inner circle color
              //                   ),
              //                   child: IconButton(
              //                       onPressed: () {
              //                         if (DateFormat('dd-MM-yyyy')
              //                                 .format(_selectedDate)
              //                                 .compareTo(
              //                                     DateFormat('dd-MM-yyyy')
              //                                         .format(DateTime.now())) <
              //                             0) {
              //                           setState(() {
              //                             _selectedDate = DateTime(
              //                                 _selectedDate.year,
              //                                 _selectedDate.month,
              //                                 _selectedDate.day + 1);
              //                             getdata(_selectedDate);
              //                             getimg(_selectedDate);
              //                             print(_inputFormat
              //                                 .format(_selectedDate));
              //                           });
              //                         }
              //                       },
              //                       icon: Icon(
              //                         Icons.add,
              //                         color: Colors.white,
              //                       )),
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: MediaQuery.of(context).size.height * 0.10,
                    child: InkWell(
                      hoverColor: Colors.lightBlue.shade200,
                      splashColor: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      onTap: () {
                        getdata(_selectedDate);
                      },
                      child: Card(
                        elevation: 10,
                        color: _colorFromHex("#66bb6a"),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: null,
                                  icon: Image.asset(
                                    "assets/sum.png",
                                    color: Colors.white,
                                    height: 60,
                                    width: 150,
                                  ),
                                ),
                                // Icon(Icons.auto_graph)
                              ],
                            ),
                            Column(
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              // mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "${tripcount}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 40),
                                ),
                                Text(
                                  "Total Trip",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: MediaQuery.of(context).size.height * 0.10,
                    child: InkWell(
                      hoverColor: Colors.lightBlue.shade200,
                      splashColor: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      onTap: () {
                        getdata(_selectedDate);
                      },
                      child: Card(
                        elevation: 10,
                        color: _colorFromHex("cccc00"),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.monitor_weight_outlined,
                                  color: Colors.white,
                                  size: 50,
                                )
                              ],
                            ),
                            Column(
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              // mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FittedBox(
                                  child: Text(
                                    "${(ttweight / 1000).toInt()}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 40),
                                  ),
                                ),
                                FittedBox(
                                  child: Text(
                                    "Total Wt(ton)",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width*0.35,
                    height: MediaQuery.of(context).size.height*0.04,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1, color: Colors.black38), //<-- SEE HERE
                        ),
                        floatingLabelBehavior:
                        searchText.isEmpty ? FloatingLabelBehavior.auto : FloatingLabelBehavior.never,
                      ),

                      onChanged: (value) {
                        searchText=value;
                        // Update the filtered data based on search query
                        setState(() {
                          if (value.isEmpty) {
                            filteredData = datas;
                            datas1=filteredData;
                          } else {
                            filteredData = datas
                                .where((element) =>
                            element['vehicle_no']
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                                element['vehicle_no']
                                    .toString()
                                    .contains(value))
                                .toList();
                            print("go${filteredData}");
                            datas1=filteredData;
                          }
                        });
                      },
                    ),
                  ),
                  Container(
                    // color: Colors.orangeAccent,
                    // padding:EdgeInsets.fromLTRB(25,5, 0, 0),
                    width: MediaQuery.of(context).size.width * 0.5,
                    height:MediaQuery.of(context).size.height * 0.08,
                    child: Card(
                      elevation: 10,
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      color: Colors.blueAccent,
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // SizedBox(
                          //   width: 10,
                          // ),
                          Container(
                            width: 30,
                            // color: Colors.redAccent,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 2, color: Colors.redAccent)),
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red, // inner circle color
                                ),
                                child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedDate = DateTime(
                                            _selectedDate.year,
                                            _selectedDate.month,
                                            _selectedDate.day - 1);
                                        // table(imei,_selectedDate);
                                        getdata(_selectedDate);
                                        getimg(_selectedDate);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                      size: 10,
                                    )),
                              ),
                            ),
                          ),
                          InkWell(
                            child: Container(
                              // width: 174,

                              // padding: EdgeInsets.fromLTRB(0, 5, 40, 0),
                              child: Text(
                                '${_inputFormat.format(_selectedDate)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(1950),
                                  //DateTime.now() - not to allow to choose before today.
                                  lastDate: DateTime.now());

                              if (pickedDate != null) {
                                setState(() {
                                  _selectedDate = pickedDate;
                                  getdata(_selectedDate);
                                  getimg(_selectedDate);

                                  // boundary1(boo,
                                  //     _selectedDate);//utput date to TextField value.
                                });
                              } else {}
                            },
                          ),
                          // SizedBox(
                          //   width: 0,
                          // ),
                          Container(
                            width: 30,
                            // color: Colors.redAccent,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 2, color: Colors.redAccent)),
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red, // inner circle color
                                ),
                                child: IconButton(
                                    onPressed: () {
                                      if (DateFormat('dd-MM-yyyy')
                                          .format(_selectedDate)
                                          .compareTo(
                                          DateFormat('dd-MM-yyyy')
                                              .format(DateTime.now())) <
                                          0) {
                                        setState(() {
                                          _selectedDate = DateTime(
                                              _selectedDate.year,
                                              _selectedDate.month,
                                              _selectedDate.day + 1);
                                          getdata(_selectedDate);
                                          getimg(_selectedDate);
                                          print(_inputFormat
                                              .format(_selectedDate));
                                        });
                                      }
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 15,
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Row(
                children: [
                  Expanded(
                    child: datas.length > 0
                        ? Container(
                            height: MediaQuery.of(context).size.height*0.685,
                            child: Column(
                              children: [
                                DataTable(
                                  horizontalMargin: 12,
                                  columnSpacing: 23,
                                  border: TableBorder.all(
                                      width: 0.5,
                                      borderRadius: BorderRadius.circular(0)),
                                  // dataRowMinHeight: 30.0,
                                  dataRowMaxHeight: double.infinity,
                                  columns: [
                                    DataColumn(
                                        label: Text('#',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,color: Colors.lightBlue))),
                                    DataColumn(
                                        label: Text('Vehicle',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,color: Colors.lightBlue))),
                                    DataColumn(
                                        label: Text('Trip',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,color: Colors.lightBlue))),
                                    DataColumn(
                                        label: Center(
                                          child: Text('Time',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,color: Colors.lightBlue)),
                                        )),

                                    // )),
                                    DataColumn(
                                        label: Text('Gro.wt',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,color: Colors.lightBlue))),
                                    DataColumn(
                                        label: Text('Net.wt',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,color: Colors.lightBlue))),

                                  ],
                                  rows: []
                                  // ]
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: filteredData.length,
                                    itemBuilder: (context, x) {
                                      return Container(

                                        // width: 300,
                                        // height:MediaQuery.of(context).size.height,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(width: 1.0, color: Colors.grey),

                                          ),
                                        ),
                                        // width: 10,
                                        // height: 100,
                                        child: Row(


                                          children: [
                                            Container(
                                              width:MediaQuery.of(context).size.width*0.089,
                                              // height:filteredData[x]['vehicles'].length>=1? MediaQuery.of(context).size.height/filteredData[x]['vehicles'].length:MediaQuery.of(context).size.height*0.14,
                                              height: MediaQuery.of(context).size.height*0.072*filteredData[x]['vehicles'].length,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(width: 1.0, color: Colors.grey),
                                                ),
                                              ),

                                              child: Center(child: Text('${x + 1}')),
                                            ),
                                            Container(
                                                width:MediaQuery.of(context).size.width*0.215,
                                                height: MediaQuery.of(context).size.height*0.072*filteredData[x]['vehicles'].length,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(width: 1.0, color: Colors.grey),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(filteredData[x]
                                                    ['vehicle_no']
                                                        .length ==
                                                        13
                                                        ? '${filteredData[x]['vehicle_no'].substring(0, 8)} \n    ${filteredData[x]["vehicle_no"].substring(filteredData[x]["vehicle_no"].length - 4)}\n(Emt-${filteredData[x]['vehicles'][0]['empty_weight']})'
                                                        : '${filteredData[x]['vehicle_no'].substring(0, 7)} \n    ${filteredData[x]["vehicle_no"].substring(filteredData[x]["vehicle_no"].length - 4)}\n(Emt-${filteredData[x]['vehicles'][0]['empty_weight']})'),
                                              )
                                            ),
                                            Container(
                                              width:MediaQuery.of(context).size.width*0.141,
                                              height: MediaQuery.of(context).size.height*0.072*filteredData[x]['vehicles'].length,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(width: 1.0, color: Colors.grey),
                                                ),
                                              ),
                                              child:trips(x, context),
                                            ),
                                            Container(
                                              width:MediaQuery.of(context).size.width*0.168,
                                              height: MediaQuery.of(context).size.height*0.072*filteredData[x]['vehicles'].length,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(width: 1.0, color: Colors.grey),
                                                ),
                                              ),
                                              child:entrydt(x),
                                            ),     Container(
                                              width:MediaQuery.of(context).size.width*0.193,
                                              height: MediaQuery.of(context).size.height*0.072*filteredData[x]['vehicles'].length,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(width: 1.0, color: Colors.grey),
                                                ),
                                              ),
                                              child:weight(x),
                                            ),
                                            Container(
                                              width:MediaQuery.of(context).size.width*0.19,
                                              height: MediaQuery.of(context).size.height*0.072*filteredData[x]['vehicles'].length,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(width: 1.0, color: Colors.grey),
                                                ),
                                              ),
                                              child:wsweight(x),
                                            ),



                                            // ... more cells
                                          ],
                                        ),
                                      ); // Convert DataRow to normal Row
                                    },
                                  ),
                                ),
                                DataTable(
                                    // horizontalMargin: 12,
                                    columnSpacing: 23,
                                    border: TableBorder.all(
                                        width: 0.5,
                                        borderRadius: BorderRadius.circular(0)),
                                    // dataRowMinHeight: 30.0,
                                    dataRowMaxHeight: double.infinity,
                                    columns: [
                                      DataColumn(
                                          label: Text('',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,color: Colors.lightBlue))),
                                      DataColumn(
                                          label: Text('\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,color: Colors.lightBlue))),
                                      DataColumn(
                                          label: Text('\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,color: Colors.lightBlue))),
                                      DataColumn(
                                          label: Center(
                                            child: Text('\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}\u{00A0}',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,color: Colors.lightBlue)),
                                          )),

                                      // )),
                                      DataColumn(
                                          label: Text('${NumberFormat.currency(locale: 'en_IN',symbol: '',decimalDigits:0).format(sumover.toInt())}',
                                              style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.bold,color: Colors.lightBlue))),
                                      DataColumn(
                                          label: Text('${NumberFormat.currency(locale: 'en_IN',symbol: '',decimalDigits:0).format(ttweight.toInt())}',
                                              style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.bold,color: Colors.lightBlue))),

                                    ],
                                    rows: []
                                  // ]
                                ),

                              ],
                            ),
                          )
                        : Center(child: (datas.length==0 && sel==true)?Text("No Data"):CircularProgressIndicator()),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
// Widget decorateCell(Widget child) {
//   return Expanded(
//     child: Container(
//       // width: 100,
//       // height: 100,
//       decoration: BoxDecoration(
//         border: Border(
//           right: BorderSide(width: 1.0, color: Colors.grey),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: child,
//       ),
//     ),
//   );
// }

Widget trips(index, BuildContext context) => Column(
      children: [
        for (int x = 0; x < datas1[index]['vehicles'].length; x++) ...[
          Container(
            child: InkWell(
              onTap: () {
                var index0 = imgarr.indexOf(
                    "/files/avadi/" + datas1[index]['vehicles'][x]["front"]);
                var index1 = imgarr.indexOf(
                    "/files/avadi/" + datas1[index]['vehicles'][x]["back"]);
                var index2 = imgarr.indexOf(
                    "/files/avadi/" + datas1[index]['vehicles'][x]["right"]);
                var index3 = imgarr.indexOf(
                    "/files/avadi/" + datas1[index]['vehicles'][x]["left"]);
                _showMyDialog(context, index0, index1, index2, index3,
                    datas1[index]['vehicle_no'], datas1[index]['driver_name'],datas1[index]['vehicles'][x]["weight"],datas1[index]['vehicles'][x]["empty_weight"]);
              },
              child: Chip(
                  label: FittedBox(
                    child: Text(
                '${datas1[index]['vehicles'][x]['trip']}',
                style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
                  )),
            ),
          )
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text('${datas1[index]['vehicles'][x]['trip']}',style: TextStyle(
          //       fontWeight: FontWeight.bold,color: Colors.black
          //   ),),
          // ),
        ],
      ],
    );

Widget entrydt(index) => Column(
      children: [
        for (int x = 0; x < datas1[index]['vehicles'].length; x++) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: FittedBox(
              child: Text(
                '${dataformater(datas1[index]['vehicles'][x]['entry_dt'])}',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),

          ),
          SizedBox(height: 18,),
        ],
      ],
    );
Widget emptywt(index) => Column(
      children: [
        for (int x = 0; x < datas1[index]['vehicles'].length; x++) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: Text(
              '${NumberFormat.currency(locale: 'en_IN',symbol: '',decimalDigits:0).format(datas1[index]['vehicles'][x]['empty_weight'])}',
              // '${datas1[index]['vehicles'][x]['empty_weight']}',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          SizedBox(height: 18,),
        ],
      ],
    );

Widget weight(index) => Column(
      children: [
        for (int x = 0; x < datas1[index]['vehicles'].length; x++) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: Text(
              '${NumberFormat.currency(locale: 'en_IN',symbol: '',decimalDigits:0).format(int.parse(datas1[index]['vehicles'][x]['weight']))}',
              // '${datas1[index]['vehicles'][x]['weight']}',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          SizedBox(height: 18,),
        ],
      ],
    );
Widget wsweight(index) => Column(
      children: [
        for (int x = 0; x < datas1[index]['vehicles'].length; x++) ...[
          // if(datas1[index]['vehicles'][x]['weight'] !="no")...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: Text(
              int.parse(datas1[index]['vehicles'][x]['weight'])<int.parse(datas1[index]['vehicles'][x]['empty_weight'])?"0":
              '${NumberFormat.currency(locale: 'en_IN',symbol: '',decimalDigits:0).format(int.parse(datas1[index]['vehicles'][x]['weight']) - int.parse(datas1[index]['vehicles'][x]['empty_weight']))}',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          SizedBox(height: 18,),
// ]
        ],
      ],
    );
Future<void> _showMyDialog(BuildContext context, int index0, int index1,
    int index2, int index3, String? vehicle, String? driver,String? weight,String? empty_wgt) async {
  return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return ConstrainedBox(
          constraints: BoxConstraints(   maxWidth: MediaQuery.of(context).size.width * 2, // Changed width constraint
            maxHeight: MediaQuery.of(context).size.height * 0.8, ),
          child: AlertDialog(
            title: Container(
              // height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 5,
              color: _colorFromHex("254C7C"),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "${vehicle}\n(${driver})",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
            titlePadding: const EdgeInsets.all(0),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 5,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [

                            Text("front"),
                            InkWell(
                              onTap: (){
                                imagePaths=[];
                                Navigator.pop(context);
                                imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index0]}');
                                imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index1]}');
                                imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index2]}');
                                imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index3]}');

                                _showImageDialog(context,0,imagePaths);

                              },
                              child: Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${imgarr[index0]}',
                                height: 100, width: 125,
                                loadingBuilder: (BuildContext context, Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null)
                                    return child;
                                  else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress.expectedTotalBytes ?? 1)
                                            : null,
                                      ),
                                    );
                                  }
                                },
                                // Existing code for context
                                // ...
                              ),
                            ),
                          ]),
                          Column(
                            children: [
                              Text("Back"),
                              InkWell(
                                onTap: (){
                                  imagePaths=[];
                                  Navigator.pop(context);
                                  imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index0]}');
                                  imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index1]}');
                                  imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index2]}');
                                  imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index3]}');

                                  _showImageDialog(context,1,imagePaths);

                                },
                                child: Image.network(
                                  'http://dev.igps.io/avadi_new/image.php?path=${imgarr[index1]}',
                                  height: 100, width: 125,
                                  loadingBuilder: (BuildContext context, Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null)
                                      return child;
                                    else {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                              (loadingProgress.expectedTotalBytes ?? 1)
                                              : null,
                                        ),
                                      );
                                    }
                                  },
                                  // Existing code for context
                                  // ...
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(children: [
                            Text("Right"),
                            InkWell(
                              onTap: (){
                                imagePaths=[];
                                Navigator.pop(context);
                                imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index0]}');
                                imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index1]}');
                                imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index2]}');
                                imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index3]}');

                                _showImageDialog(context,2,imagePaths);

                              },
                              child: Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${imgarr[index2]}',
                                height: 100, width: 125,
                                loadingBuilder: (BuildContext context, Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null)
                                    return child;
                                  else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress.expectedTotalBytes ?? 1)
                                            : null,
                                      ),
                                    );
                                  }
                                },
                                // Existing code for context
                                // ...
                              ),
                            ),
                          ]),
                          Column(
                            children: [
                              Text("Left"),
                              InkWell(
                                onTap: (){
                                  imagePaths=[];
                                  Navigator.pop(context);
                                  imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index0]}');
                                  imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index1]}');
                                  imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index2]}');
                                  imagePaths.add('http://dev.igps.io/avadi_new/image.php?path=${imgarr[index3]}');

                                  _showImageDialog(context,3,imagePaths);

                                },
                                child: Image.network(
                                  'http://dev.igps.io/avadi_new/image.php?path=${imgarr[index3]}',
                                  height: 100, width: 125,
                                  loadingBuilder: (BuildContext context, Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null)
                                      return child;
                                    else {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                              (loadingProgress.expectedTotalBytes ?? 1)
                                              : null,
                                        ),
                                      );
                                    }
                                  },
                                  // Existing code for context
                                  // ...
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            children: [
                              Container(
                               width:MediaQuery.of(context).size.width*0.65,
                                child: FittedBox(

                                    child: Text("Gross weight - Empty weight=Net weight",style: TextStyle(fontSize: 15.0),)),
                              ),
                              Text('(${weight}  -  ${empty_wgt} =${int.parse(weight!)-int.parse(empty_wgt!)})',style: TextStyle(fontSize: 15.0),)
                            ],
                          )

                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        );
      });
}
void _showImageDialog(BuildContext context, int index, List<dynamic> imagePaths) {
  var txt='Front';
  int currentIndex = index;
  PhotoViewScaleStateController ?scaleStateController;
  PhotoViewController photoViewController;
  photoViewController = PhotoViewController();
  // photoViewController.dispose();
  scaleStateController = PhotoViewScaleStateController();
  void goBack(){
    print("call");
    // scaleStateController?.scaleState = PhotoViewScaleState.originalSize;
    // scaleStateController?.scaleState = PhotoViewScaleState.originalSize;
    photoViewController.scale = photoViewController.initial.scale;
  }
  if(index==0){
     txt='Front';
  }
  else if(index==1){
    txt='Back';
  }
  else if(index==2){
    txt='Right';
  }
  else {
     txt='Left';
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: EdgeInsets.all(0),
            child: Stack(
              children: [
                Positioned.fill(
                  child: PhotoView(
                    controller: photoViewController,
                    imageProvider: NetworkImage(
                      imagePaths[currentIndex],
                    ),scaleStateController: scaleStateController,
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  ),
                ),
                Positioned(
                  top:20,
                  left:150,
                  child: Text(txt,style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold,fontSize: 30.0),),
                ),
                Positioned(
                  top:5,
                  right:30,
                  child: ElevatedButton(
                    child: Text("Reset"),
                    onPressed: () {
                      photoViewController.scale = photoViewController.initial.scale;
                    },
                  ),
                ),
                Positioned(
                  top:5,
                  left:10,
                  child: IconButton(onPressed: () {
                    Navigator.pop(context);
                  }, icon:Icon(Icons.close,color: Colors.white,)),
                ),
                Positioned(
                  bottom: 20,
                  left: 90,
                  child: ElevatedButton(
                    child: Text("Prev"),
                    onPressed: () {
                      setState(() {
                        if(currentIndex>=1 && currentIndex<=3) {

                          currentIndex =
                              (currentIndex - 1 + imagePaths.length) %
                                  imagePaths.length;
                          if(currentIndex==0){
                            txt='Front';
                          } else if(currentIndex==1){
                            txt='Back';
                          } else if(currentIndex==2){
                            txt='Right';
                          }else if(currentIndex==3){
                            txt='Left';
                          }
                        }
                      });
                    },
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 90,
                  child: ElevatedButton(
                    child: Text("Next"),
                    onPressed: () {
                      setState(() {
                        if(currentIndex>=0 && currentIndex<3) {

                          currentIndex =
                              (currentIndex + 1) % imagePaths.length;
                          if(currentIndex==0){
                            txt='Front';
                          } else if(currentIndex==1){
                            txt='Back';
                          } else if(currentIndex==2){
                            txt='Right';
                          }else if(currentIndex==3){
                            txt='Left';
                          }
                        }
                      });
                    },
                  ),
                ),
                Positioned(
                  bottom:20,
                  right:20,
                  child: IconButton(onPressed: () {
                    Navigator.pop(context);
                  }, icon:Icon(Icons.close_rounded,color: Colors.white,)),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
// void _showImageDialog(BuildContext context, int index, List<dynamic> imagePaths) {
//   int currentIndex = index;
//   var txt='Front';
//   showDialog(
//     context: context,
//     builder: (context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return Dialog(
//             insetPadding: EdgeInsets.all(15),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(txt,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
//                 AspectRatio(
//                   aspectRatio: 16 / 12, // Adjust according to your needs
//                   child: InteractiveViewer(
//                     minScale: 0.1,
//                     maxScale: 3.5,
//                     child: Image.network(
//                       imagePaths[currentIndex],
//                       loadingBuilder: (BuildContext context, Widget child,
//                           ImageChunkEvent? loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return Center(
//                           child: CircularProgressIndicator(
//                             value: loadingProgress.expectedTotalBytes != null
//                                 ? loadingProgress.cumulativeBytesLoaded /
//                                 (loadingProgress.expectedTotalBytes ?? 1)
//                                 : null,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           if(currentIndex>=1 && currentIndex<=3) {
//
//                             currentIndex =
//                                 (currentIndex - 1 + imagePaths.length) %
//                                     imagePaths.length;
//                             if(currentIndex==0){
//                               txt='Front';
//                             } else if(currentIndex==1){
//                               txt='Back';
//                             } else if(currentIndex==2){
//                               txt='Right';
//                             }else if(currentIndex==3){
//                               txt='Left';
//                             }
//                           }
//                         });
//                       },
//                       child: Text("Prev"),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           if(currentIndex>=0 && currentIndex<3) {
//
//                             currentIndex =
//                                 (currentIndex + 1) % imagePaths.length;
//                             if(currentIndex==0){
//                               txt='Front';
//                             } else if(currentIndex==1){
//                               txt='Back';
//                             } else if(currentIndex==2){
//                               txt='Right';
//                             }else if(currentIndex==3){
//                               txt='Left';
//                             }
//                           }
//                         });
//                       },
//                       child: Text("Next"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }
dataformater(String dt) {
  // if (dt == "null") {
  //   return "NA";
  // } else {
  DateTime fromdate =
      DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dt).toString());
  String parsedfromdate = DateFormat("hh:mm a").format(fromdate);
  return parsedfromdate;
  // }
}

Color _colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}
