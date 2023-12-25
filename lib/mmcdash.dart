import 'dart:convert';
import 'dart:math' hide log;
import 'dart:typed_data';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'chart.dart';
import 'consolidated.dart';
import 'dart:developer';
import 'login.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'helper/save_file_mobile_desktop.dart'
if (dart.library.html) 'helper/save_file_web.dart' as helper;
import 'package:flutter/material.dart';

import 'menulist.dart';
import 'settings.dart';

class MyHomePage1 extends StatefulWidget {
  final String user;
  final String pass;
  final String main;
  final String logo;
  final String mcc;
  final String type;
  MyHomePage1(
      {super.key,
        required this.user,
        required this.pass,
        required this.main,
        required this.logo,
        required this.mcc,
        required this.type});
  @override
  _MyHomePage1State createState() => _MyHomePage1State();
}

var imagePaths = [];
List<Employee> employees = [];
String? selectedValue;
bool noflag = false;
late GlobalKey<SfDataGridState> _key;
var mcname = "ALL";
var users = "";

class _MyHomePage1State extends State<MyHomePage1> {
  bool abcd = false;
  late EmployeeDataSource employeeDataSource;
  final List<String> items = [
    'Time wise',
    'Trip wise',
  ];
  final List<String> itemtime = ['ALL', '6AM-6PM', '6PM-6AM', 'Custom Time'];
  List<String> cate = ['ALL'];
  List<String> typp = ['ALL'];
  Color getcol = Colors.green;
  var getime = 'ALL';
  DateTime _fromDate = DateTime.now().subtract(Duration(days: 1));
  DateTime _toDate = DateTime.now();
  TimeOfDay _fromTime = TimeOfDay.now();
  TimeOfDay _toTime = TimeOfDay.now();
  late ValueNotifier<DateTime> _fromDateNotifier;
  late ValueNotifier<DateTime> _toDateNotifier;
  String selectedValuetime = "Select Time";
  String selectedValuecat = "Select Category";
  String selectedValuetype = "ALL";
  String dropdownValue = "ALL";
  // final CustomColumnSizer _customColumnSizer = CustomColumnSizer();
  //  var data = [];
  late List<dynamic> data = [];
  late List<dynamic> datatrip = [];
  late List<dynamic> result = [];
  var datas = [];
  int sumover = 0;
  bool pdf = false;
  bool mflag = false;
  bool times = false;
  // int sumwaste = 0;
  String searchText = '';
  var filteredData = [];
  int tripcount = 0;
  int tripcomp = 0;
  int tripnot = 0;
  int ttweight = 0;
  int totalweight = 0;
  var _inputFormat = DateFormat('dd-MM-yyyy');
  int bindex = 1;
  int toggle = 0;
  var _selectedDate = DateTime.now();
  int wwwto = 0;
  int www1 = 0;
  int www2 = 0;
  int www3 = 0;
  int www4 = 0;
  int inout = 0;
  int ins = 0;
  int out = 0;
  bool search = false;
  double totalNetWeight = 0.0;
  double totalgroWeight = 0.0;
  bool isSearchVisible = false;
  var mccs;
  bool isNextRowVisible = false;
  TextEditingController order_controler = TextEditingController();
  // List<Employee> employees = [];
  // @override
  // double calculateRowHeight(List<Employee> employees) {
  //   int maxTrips = 0;
  //
  //   for (var employee in employees) {
  //     print(employee.vehicles.length);
  //     if (employee.vehicles.length > maxTrips) {
  //       maxTrips = employee.vehicles.length;
  //     }
  //   }
  //
  //   // Assume each 'trip' needs a height of 50.0 units
  //   return (maxTrips * 20.0).toDouble();
  // }
  double rowHeight = 100.0;
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    // _fromDateNotifier = ValueNotifier<DateTime>(DateTime.now().subtract(Duration(hours: 24)));
    // _toDateNotifier = ValueNotifier<DateTime>(now);
    _fromDateNotifier = ValueNotifier<DateTime>(now);
    _toDateNotifier = ValueNotifier<DateTime>(now);
    _fromTime = TimeOfDay.now();
    _toTime = TimeOfDay.now();
    selectedValue = items[0];
    selectedValuetime = itemtime[0];
    selectedValuecat = cate[0];
    // selectedValuetype = typp[0];

    _key = GlobalKey();
    fetchAndReturnImageData();
    getvehicle();
    getEmployeeData(_selectedDate, widget.mcc).then((fetchedEmployees) {
      setState(() {
        employees = fetchedEmployees;
        users = widget.main;
        // if (employees.isNotEmpty) {
        //   rowHeight = calculateRowHeight(employees);
        // } else {
        //   rowHeight = 100.0; // Default row height if no employees
        // }
        if (widget.type == "admin") {
          if (widget.mcc.contains('ALL')) {
            mcname = "ALL";
          } else {
            mcname = widget.mcc;
          }
        } else {
          if (widget.mcc.contains('ALL')) {
            mcname = "ALL";
          } else {
            mcname = widget.mcc;
          }
        }
        // rowHeight = calculateRowHeight(employees);
      });
    });
  }

  @override
  void dispose() {
    // Dispose the notifiers when not in use
    _fromDateNotifier.dispose();
    _toDateNotifier.dispose();
    super.dispose();
  }

  var datavehi = [];
  getvehicle() async {
    datavehi = [];
    var map = {"action": "mmcvehicle_type"};
    var url = "http://dev.igps.io/swms/api/getrf_api.php";
    var response = await http.post(Uri.parse(url), body: (jsonEncode(map)));
    if (response.body == "" ||
        response.body == null ||
        response.body == "NULL" ||
        response.body == "null" ||
        response.body == "[]") {
      datavehi = [];
    } else {
      datavehi = jsonDecode(response.body);
    }
    print("dssdsddsdsd${datavehi}");
    var uniqueVehicleTypes = datavehi
        .map((item) => item['vehicle_type'].toString())
        .toSet()
        .toList();
    var uniqueCategories = datavehi
        .map((item) {
      // Check if category is 'corporation' and replace with 'corp', else use the original value
      return item['cat'] == 'Corporation with GPS'
          ? 'Corp GPS'
          : item['cat'] == "Corporation NO GPS"
          ? 'Corp NO GPS'
          : item['cat'].toString();
    })
        .toSet()
        .toList();
    typp.addAll(uniqueVehicleTypes);
    cate.addAll(uniqueCategories);
  }

  double calculateRowHeight(List<Employee> employees) {
    double minHeight = 50.0; // Minimum height for a row
    double maxHeight = 0.0;

    for (var employee in employees) {
      int numberOfVehicles = employee.vehicles
          .length; // Assuming 'vehicles' is a List in your Employee object

      // Dynamically setting base height based on the number of vehicles
      double baseHeight = minHeight +
          (numberOfVehicles *
              10.0); // For example, add 10.0 for each vehicle to the base height

      // Extra height per vehicle
      double extraHeightPerVehicle = 5.0; // Extra height for each vehicle

      double calculatedHeight =
          baseHeight + (numberOfVehicles * extraHeightPerVehicle);
      maxHeight = max(maxHeight, calculatedHeight);
    }

    return maxHeight;
  }

  Future<List<Employee>> getEmployeeData(_selectedDate, mcc) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // var sett = preferences.getString('settings') ?? "";
    var map = {};
    String url = '';
    var act = '';
    employees=[];
    List<Employee> newEmployees = [];

    List<String> outputList = mcc.split(',');

    String output = outputList.map((item) => "'$item'").join(',');
    print("bindex ---> ${mcc}");
    if (widget.main.toUpperCase() == "MMC") {
      act = "tripmmc";
    } else {
      if (selectedValue == 'Trip wise') {
        act = "select_mcc";
      } else {
        act = "datewise1";
      }
    }
    print("too${formatTimeOfDay(_fromTime)}");
    // final CustomColumnSizer _customColumnSizer = CustomColumnSizer();
    if (selectedValue == 'Trip wise') {
      map = {
        "action": act,
        "cat": "trip",
        "district": "ALL",
        "imei": "ALL",
        "over": "Daily Report",
        "panch": "ALL",
        "subzone": "ALL",
        "username": widget.main,
        "mcc": mcc,
        "category": selectedValuecat,
        "vehicle_type": selectedValuetype,
        "from": getime == "ALL"
            ? DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 00:00:00'
            : getime == "6AM-6PM"
            ? DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 06:00:00'
            : getime == "6PM-6AM"
            ? DateFormat("yyyy-MM-dd").format(_selectedDate) +
            ' 18:00:00'
            : DateFormat("yyyy-MM-dd").format(_selectedDate) +
            ' ${formatTimeOfDay(_fromTime)}',
        "to": getime == "ALL"
            ? DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 23:59:59'
            : getime == "6AM-6PM"
            ? DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 18:00:00'
            : getime == "6PM-6AM"
            ? DateFormat("yyyy-MM-dd").format(_selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day + 1)) +
            ' 06:00:00'
            : DateFormat("yyyy-MM-dd").format(_selectedDate) +
            ' ${formatTimeOfDay(_toTime)}',
      };
      url = "http://dev.igps.io/swms/api/getrf_api.php";
    } else {
      map = {
        "action": act,
        "cat": "time",
        "district": "ALL",
        "imei": "ALL",
        "over": "Daily Report",
        "panch": "ALL",
        "subzone": "ALL",
        "mcc": mcc,
        "category": selectedValuecat,
        "vehicle_type": selectedValuetype,
        "username": widget.main,
        "from": getime == "ALL"
            ? DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 00:00:00'
            : getime == "6AM-6PM"
            ? DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 06:00:00'
            : getime == "6PM-6AM"
            ? DateFormat("yyyy-MM-dd").format(_selectedDate) +
            ' 18:00:00'
            : DateFormat("yyyy-MM-dd").format(_selectedDate) +
            ' ${formatTimeOfDay(_fromTime)}',
        "to": getime == "ALL"
            ? DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 23:59:59'
            : getime == "6AM-6PM"
            ? DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 18:00:00'
            : getime == "6PM-6AM"
            ? DateFormat("yyyy-MM-dd").format(_selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day + 1)) +
            ' 06:00:00'
            : DateFormat("yyyy-MM-dd").format(_selectedDate) +
            ' ${formatTimeOfDay(_toTime)}',
      };
      url = "http://dev.igps.io/swms/api/getrf_api.php";
    }
    print(map);

    var response = await http.post(Uri.parse(url), body: (jsonEncode(map)));
    // print("hhhi --->${response.body}");
    if (response.statusCode == 200) {
      setState(() {
        bindex = 1;
        getcol = Colors.green;
        tripcount = 0;

        tripnot = 0;
        tripcomp = 0;
        ttweight = 0;
        wwwto = 0;
        www1 = 0;
        www2 = 0;
        www3 = 0;
        www4 = 0;
        out = 0;
        ins = 0;
        inout = 0;
        data = [];
        datas = [];

        // print("fgfd");
        if (response.body == "" ||
            response.body == null ||
            response.body == "NULL" ||
            response.body == "null" ||
            response.body == "[]") {
          data = [];
          noflag = true;
        } else {
          data = jsonDecode(response.body);
        }
        // data1 = jsonDecode(response.body);
        // print(data);
        log("log${data}");
        for (int s1 = 0; s1 < data.length; s1++) {
          var obj = data[s1];

          if (selectedValue == "Trip wise") {
            var vehi = obj["vehicles"];
            if (obj['vehicles'][0]['weight'] != "no") {
              datas.add(data[s1]);
            }
            int total = int.parse(vehi[vehi.length - 1]["total"]);

            if (total <= 2000) {
              // print("hiii");
              setState(() {
                wwwto++;
              });
            } else if (total > 2000 && total <= 4000) {
              // print("hiii1111");
              setState(() {
                www1++;
              });
            } else if (total > 4000 && total <= 5000) {
              setState(() {
                www2++;
              });
            } else if (total > 5000) {
              setState(() {
                www3++;
              });
            } else {}
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
              www4++;
              if (obj1["weight"] != null &&
                  obj1["weight_out"] != null &&
                  obj1["front"] != null &&
                  obj1["back"] != null &&
                  obj1["right"] != null &&
                  obj1["left"] != null &&
                  obj1["front_out"] != null &&
                  obj1["back_out"] != null &&
                  obj1["right_out"] != null &&
                  obj1["left_out"] != null) {
                inout++;
              }
              if (obj1["weight"] != null &&
                  obj1["left"] != null &&
                  obj1["front"] != null &&
                  obj1["back"] != null &&
                  obj1["right"] != null &&
                  obj1["weight_out"] == null &&
                  obj1["left_out"] == null &&
                  obj1["front_out"] == null &&
                  obj1["back_out"] == null &&
                  obj1["right_out"] == null) {
                ins++;
              }
              if (obj1["weight"] == null &&
                  obj1["left"] == null &&
                  obj1["front"] == null &&
                  obj1["back"] == null &&
                  obj1["right"] == null &&
                  obj1["weight_out"] != null &&
                  obj1["left_out"] != null &&
                  obj1["front_out"] != null &&
                  obj1["back_out"] != null &&
                  obj1["right_out"] != null) {
                out++;
              }
              if ((obj1["weight"] != "no")) {
                // sumover += int.parse(obj1["weight"]);
                if (obj1["weight"] == null) {
                  ttweight = ttweight + 0;
                }
                else {
                  if (int.parse(obj1["weight"]) <
                      int.parse(obj1["empty_weight"]) ||
                      int.parse(obj1["empty_weight"]) == 0) {
                    ttweight = ttweight + 0;
                  } else {
                    ttweight = ttweight +
                        ((int.parse(obj1["weight"]) -
                            int.parse(obj1["empty_weight"])));
                  }
                }
              }
              if (trip1 != "-") {
                tripcount++;
              }
            }
          } else {
            setState(() {
              tripcount++;
              print("sss${obj["waste_weight"]}");
              // sumover += int.parse(obj["weight"].toString());

              ttweight = ttweight + int.parse(obj["waste_weight"]);
              int waste_wt = int.parse(obj["waste_weight"]);

              if (obj["weight"] != null &&
                  obj["weight_out"] != null &&
                  obj["front"] != null &&
                  obj["back"] != null &&
                  obj["right"] != null &&
                  obj["left"] != null &&
                  obj["front_out"] != null &&
                  obj["back_out"] != null &&
                  obj["right_out"] != null &&
                  obj["left_out"] != null) {
                inout++;
              }
              else if (obj["weight"] != null &&
                  obj["left"] != null &&
                  obj["front"] != null &&
                  obj["back"] != null &&
                  obj["right"] != null &&
                  obj["weight_out"] == null &&
                  obj["left_out"] == null &&
                  obj["front_out"] == null &&
                  obj["back_out"] == null &&
                  obj["right_out"] == null) {
                ins++;
              }
              else  if (obj["weight"] == null &&
                  obj["left"] == null &&
                  obj["front"] == null &&
                  obj["back"] == null &&
                  obj["right"] == null &&
                  obj["weight_out"] != null &&
                  obj["left_out"] != null &&
                  obj["front_out"] != null &&
                  obj["back_out"] != null &&
                  obj["right_out"] != null) {
                print("fdfdfdffdfdff");
                out++;
              }
              if (waste_wt >= 0) {
                www4++;
              }
              if (waste_wt >= 0 && waste_wt <= 2000) {
                setState(() {
                  wwwto++;
                });
              } else if (waste_wt > 2000 && waste_wt <= 4000) {
                setState(() {
                  www1++;
                });
              } else if (waste_wt > 4000 && waste_wt <= 5000) {
                setState(() {
                  www2++;
                });
              } else if (waste_wt > 5000) {
                setState(() {
                  www3++;
                });
              }

              // newEmployees = data.map((e) => Employee.fromJson(e)).toList();
              // employees = newEmployees;
            });
          }
        }
        setState(() {
          // print("fff${data.map((e) => Employee.fromJson(e)).toList()}");
          newEmployees = data.map((e) => Employee.fromJson(e)).toList();

          print(order_controler.text);
          order_controler.text.isEmpty
              ? newEmployees = data.map((e) => Employee.fromJson(e)).toList()
              : newEmployees = data
              .where((element) =>
          element['vehicle_no']
              .toLowerCase()
              .contains(order_controler.text.toLowerCase()) ||
              element['vehicle_no']
                  .toString()
                  .contains(order_controler.text))
              .map((e) => Employee.fromJson(e))
              .toList();
          // print("employee${employees}");
          employees = newEmployees;
          if (employees.isNotEmpty) {
            rowHeight = calculateRowHeight(employees);
            print("reow${rowHeight}");
          } else {
            rowHeight = 100.0; // Default row height if no employees
          }
          print("employess${employees.length}");
          abcd = true;
        });
      });
    }
    print("dsfsf${tripcount}");

    return newEmployees;
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat("HH:mm:ss"); // Use any format you need
    return format.format(dt);
  }

  List<dynamic> getCategoryList(List<dynamic> inputlist) {
    List outputList = inputlist.where((o) => o['vehicles'].isNotEmpty).toList();
    return outputList;
  }

  int getTotalVehiclesCount(List<dynamic> inputList) {
    int totalVehiclesCount = 0;

    for (var item in inputList) {
      // Check if the 'vehicles' key exists and is a list
      if (item.containsKey('vehicles') && item['vehicles'] is List) {
        List vehiclesList = item['vehicles'] as List;

        // Check if the list is not empty
        if (vehiclesList.isNotEmpty) {
          totalVehiclesCount += vehiclesList.length;
        }
      } else {
        // Log for debugging purposes
        print(
            "Item does not have a 'vehicles' list or it's not a List type: $item");
      }
    }

    return totalVehiclesCount;
  }

  List<dynamic> data1 = [];
  List<dynamic> datamcc = [];
  onItemChanged(String value) {
    // print("hi");
    print(value);
    if (selectedValue == "Trip wise") {
      if ((value == "ALL" ||
          value == "inout" ||
          value == "out" ||
          value == "in")) {
        print("dsfdsfdsfdsfsfdsf");
        setState(() {
          ttweight = 0;
          tripcount = 0;
        });
        Map<int, Color> colorMap = {
          1: Colors.green,
          2: Colors.purple,
          3: Colors.blue,
          4: Colors.yellow.shade800,
          // 5: Colors.red,
        };
        getcol = colorMap[bindex] ?? Colors.grey;
      } else {}
    } else {
      Map<int, Color> colorMap = {
        1: Colors.green,
        2: Colors.purple,
        3: Colors.blue,
        4: Colors.yellow.shade800,
        // 5: Colors.red,
      };
      getcol = colorMap[bindex] ?? Colors.grey;
      // print("dsfdsfdsfdsfsfdsf");
      setState(() {
        ttweight = 0;
        tripcount = 0;
      });
    }

    data1 = [];
    datamcc = [];

    // if(selectedValue=="Trip wise"){
    //   employees = data.map((e) => Employee.fromJson(e)).toList();
    // }
    // else{
    print("sdsadd${data}");
    employees = data.map((e) => Employee.fromJson(e)).toList();
    // }
    List<dynamic> dummySearchList = employees;
    print("ddd${datatrip.runtimeType}");
    if (value.isNotEmpty) {
      dummySearchList.forEach((main) {
        // print("main---${main}");
        setState(() {
          if (selectedValue == "Time wise") {
            switch (value) {
              case "ALL":
                processMainData(main, value, 0, 2000);
                break;
              case "inout":
                processMainData(main, value, 0, 2000);
                break;
              case "in":
                processMainData(main, value, 0, 2000);
                break;
              case "out":
                processMainData(main, value, 0, 2000);
                break;
              case "<2":
                processMainData(main, value, 0, 2000);
                break;
              case "2-4":
                processMainData(main, value, 2000, 4000);
                break;
              case "4-5":
                processMainData(main, value, 4000, 5000);
                break;
              case "5>":
                processMainData(main, value, 5000, -1);
                break;
              case "ALL":
              // Process for "ALL" condition
                break;
            }
          } else {
            switch (value) {
              case "ALL":
                processMainData(main, value, 0, 2000);
                break;
              case "inout":
                processMainData(main, value, 0, 2000);
                break;
              case "in":
                processMainData(main, value, 0, 2000);
                break;
              case "out":
                processMainData(main, value, 0, 2000);
                break;
              case "<2":
                processMainData(main, value, 0, 2000);
                break;
              case "2-4":
                processMainData(main, value, 2000, 4000);
                break;
              case "4-5":
                processMainData(main, value, 4000, 5000);
                break;
              case "5>":
                processMainData(main, value, 5000, -1);
                break;
              case "ALL":
              // Process for "ALL" condition
                break;
            }
          }
        });
        // if((maindata['waste_weight'].toLowerCase()).contains(value)){
        //   dummyListData.add(maindata);
        // }
      });
    } else {
      setState(() {
        employees = data1.map((e) => Employee.fromJson(e)).toList();
        // maindata.clear();
        // datas1.clear();
        // maindata.addAll(datas);
        // datas1.addAll(datas);
      });
    }
    print("flags------------>${noflag}");
    setState(() {});
  }

  void processMainData(
      dynamic main, String value, int weightLimitLower, int weightLimitUpper) {
    print("fdfddf${main.runtimeType}");
    if (selectedValue == "Time wise") {
      if (value == "ALL") {
        int waste_wt = int.parse(main.waste_weight);
        data1.add({
          "waste_weight": main.waste_weight,
          "weight": main.weight,
          "trip": main.trip,
          "entry_dt": main.entry_dt,
          "vehicle_no": main.vehicle_no,
          "front": main.front,
          "back": main.back,
          "right": main.right,
          "left": main.left,
          "front_out": main.front_out,
          "back_out": main.back_out,
          "right_out": main.right_out,
          "left_out": main.left_out,
          "driver_name": main.driver_name,
          "empty_weight": main.empty_weight,
          "username": main.username,
          "mcc": main.mcc,
          "entry_out": main.entry_out,
          "category": main.category,
        });
        ttweight += waste_wt;
        tripcount++;
      } else if (value == "inout") {
        if (main.weight != null &&
            main.front != null &&
            main.back != null &&
            main.right != null &&
            main.left != null &&
            main.weight_out != null &&
            main.front_out != null &&
            main.back_out != null &&
            main.right_out != null &&
            main.left_out != null) {
          int waste_wt = int.parse(main.waste_weight);
          data1.add({
            "waste_weight": main.waste_weight,
            "weight": main.weight,
            "trip": main.trip,
            "entry_dt": main.entry_dt,
            "vehicle_no": main.vehicle_no,
            "front": main.front,
            "back": main.back,
            "right": main.right,
            "left": main.left,
            "front_out": main.front_out,
            "back_out": main.back_out,
            "right_out": main.right_out,
            "left_out": main.left_out,
            "driver_name": main.driver_name,
            "empty_weight": main.empty_weight,
            "username": main.username,
            "mcc": main.mcc,
            "entry_out": main.entry_out,
            "category": main.category,
          });
          ttweight += waste_wt;
          tripcount++;
        }
      } else if (value == "in") {
        if (main.weight != null &&
            main.front != null &&
            main.back != null &&
            main.right != null &&
            main.left != null &&
            main.weight_out == null &&
            main.front_out == null &&
            main.back_out == null &&
            main.right_out == null &&
            main.left_out == null) {
          print("hhihhiihihhiihhh");
          int waste_wt = int.parse(main.waste_weight);
          data1.add({
            "waste_weight": main.waste_weight,
            "weight": main.weight,
            "trip": main.trip,
            "entry_dt": main.entry_dt,
            "vehicle_no": main.vehicle_no,
            "front": main.front,
            "back": main.back,
            "right": main.right,
            "left": main.left,
            "front_out": main.front_out,
            "back_out": main.back_out,
            "right_out": main.right_out,
            "left_out": main.left_out,
            "driver_name": main.driver_name,
            "empty_weight": main.empty_weight,
            "username": main.username,
            "mcc": main.mcc,
            "entry_out": main.entry_out,
            "category": main.category,
          });
          ttweight += waste_wt;
          tripcount++;
        }
      } else if (value == "out") {
        if (main.weight == null &&
            main.front == null &&
            main.back == null &&
            main.right == null &&
            main.left == null &&
            main.weight_out != null &&
            main.front_out != null &&
            main.back_out != null &&
            main.right_out != null &&
            main.left_out != null) {
          print("fdsfdsfdsfdsfdsfdsf");
          int waste_wt = int.parse(main.waste_weight);
          data1.add({
            "waste_weight": main.waste_weight,
            "weight": main.weight,
            "trip": main.trip,
            "entry_dt": main.entry_dt,
            "vehicle_no": main.vehicle_no,
            "front": main.front,
            "back": main.back,
            "right": main.right,
            "left": main.left,
            "front_out": main.front_out,
            "back_out": main.back_out,
            "right_out": main.right_out,
            "left_out": main.left_out,
            "driver_name": main.driver_name,
            "empty_weight": main.empty_weight,
            "username": main.username,
            "mcc": main.mcc,
            "entry_out": main.entry_out,
            "category": main.category,
          });
          ttweight += waste_wt;
          tripcount++;
        }
      } else {
        int waste_wt = int.parse(main.waste_weight);
        print("low${weightLimitLower} --high${weightLimitUpper}");
        if (weightLimitLower == 0) {
          if (waste_wt >= weightLimitLower &&
              (weightLimitUpper == -1 || waste_wt <= weightLimitUpper)) {
            // data1=[];
            data1.add({
              "waste_weight": main.waste_weight,
              "weight": main.weight,
              "trip": main.trip,
              "entry_dt": main.entry_dt,
              "vehicle_no": main.vehicle_no,
              "front": main.front,
              "back": main.back,
              "right": main.right,
              "left": main.left,
              "front_out": main.front_out,
              "back_out": main.back_out,
              "right_out": main.right_out,
              "left_out": main.left_out,
              "driver_name": main.driver_name,
              "empty_weight": main.empty_weight,
              "username": main.username,
              "mcc": main.mcc,
              "entry_out": main.entry_out,
              "category": main.category,
            });
            ttweight += waste_wt;
            tripcount++;
          }
        } else {
          if (waste_wt > weightLimitLower &&
              (weightLimitUpper == -1 || waste_wt <= weightLimitUpper)) {
            // data1=[];
            data1.add({
              "waste_weight": main.waste_weight,
              "weight": main.weight,
              "trip": main.trip,
              "entry_dt": main.entry_dt,
              "entry_dt": main.entry_dt,
              "vehicle_no": main.vehicle_no,
              "front": main.front,
              "back": main.back,
              "right": main.right,
              "left": main.left,
              "front_out": main.front_out,
              "back_out": main.back_out,
              "right_out": main.right_out,
              "left_out": main.left_out,
              "driver_name": main.driver_name,
              "empty_weight": main.empty_weight,
              "username": main.username,
              "mcc": main.mcc,
              "entry_out": main.entry_out,
              "category": main.category,
            });
            ttweight += waste_wt;
            tripcount++;
          }
        }
      }
    } else {
      if (value == "ALL") {
        for (var i = 0; i < main.vehicles.length; i++) {
          var total =
          int.parse(main.vehicles[main.vehicles.length - 1]['total']);
          if (i == 0) {
            data1.add({
              "vehicle_no": main.vehicle_no,
              "username": main.username,
              "mcc": main.mcc,
              "vehicles": main.vehicles
              // Adds all vehicles, not just the current one
            });
            ttweight = ttweight + total;
          }
          tripcount++;
        }
      } else if (value == "inout") {
        List<Map<String, dynamic>> filteredVehicles = [];
        print(main.vehicles[0]["trip"]);
        for (var i = 0; i < main.vehicles.length; i++) {
          var total =
          int.parse(main.vehicles[main.vehicles.length - 1]['total']);
          var vehicle = main.vehicles[i];
          if (vehicle["weight"] != null &&
              vehicle["front"] != null &&
              vehicle['back'] != null &&
              vehicle['right'] != null &&
              vehicle['left'] != null &&
              vehicle['weight_out'] != null &&
              vehicle["front_out"] != null &&
              vehicle['back_out'] != null &&
              vehicle["right_out"] != null &&
              vehicle["left_out"] != null) {
            filteredVehicles.add({
              "front": vehicle["front"],
              "back": vehicle["back"],
              "right": vehicle["right"],
              "left": vehicle["left"],
              "front_out": vehicle["front_out"],
              "back_out": vehicle["back_out"],
              "right_out": vehicle["right_out"],
              "left_out": vehicle["left_out"],
              "entry_dt": vehicle["entry_dt"],
              "entry_out": vehicle["entry_out"],
              "weight": vehicle["weight"],
              "weight_out": vehicle["weight_out"],
              "waste_weight": vehicle["waste_weight"],
              "empty_weight": vehicle["empty_weight"],
              "trip": vehicle["trip"],
              "vehicle_no": vehicle["vehicle_no"],
              "total": vehicle["total"],
              "category": vehicle["category"],
            });
            tripcount++;
          }
          if (i == 0) {
            datamcc.add({
              "vehicle_no": main.vehicle_no,
              "username": main.username,
              "mcc": main.mcc,
              "vehicles":
              filteredVehicles // Adds all vehicles, not just the current one
            });

            ttweight += total;
            // Exit the loop after adding the first qualifying vehicle
          }
          data1 = (getCategoryList((datamcc)));
        }
      } else if (value == "in") {
        List<Map<String, dynamic>> filteredVehicles11 = [];

        for (var i = 0; i < main.vehicles.length; i++) {
          var total =
          int.parse(main.vehicles[main.vehicles.length - 1]['total']);
          var vehicle = main.vehicles[i];
          if (vehicle["weight"] != null &&
              vehicle["front"] != null &&
              vehicle['back'] != null &&
              vehicle['right'] != null &&
              vehicle['left'] != null &&
              vehicle['weight_out'] == null &&
              vehicle["front_out"] == null &&
              vehicle['back_out'] == null &&
              vehicle["right_out"] == null &&
              vehicle["left_out"] == null) {
            filteredVehicles11.add({
              "front": vehicle["front"],
              "back": vehicle["back"],
              "right": vehicle["right"],
              "left": vehicle["left"],
              "front_out": vehicle["front_out"],
              "back_out": vehicle["back_out"],
              "right_out": vehicle["right_out"],
              "left_out": vehicle["left_out"],
              "entry_dt": vehicle["entry_dt"],
              "entry_out": vehicle["entry_out"],
              "weight": vehicle["weight"],
              "weight_out": vehicle["weight_out"],
              "waste_weight": vehicle["waste_weight"],
              "empty_weight": vehicle["empty_weight"],
              "trip": vehicle["trip"],
              "vehicle_no": vehicle["vehicle_no"],
              "total": vehicle["total"],
              "category": vehicle["category"],
            });
          }
          // print("filter${filteredVehicles11}$i");

          // print("filter${filteredVehicles11}");
          if (i == 0) {
            // if (filteredVehicles11.isNotEmpty) {
            datamcc.add({
              "vehicle_no": main.vehicle_no,
              "username": main.username,
              "mcc": main.mcc,
              "vehicles": filteredVehicles11
              // Adds all vehicles, not just the current one
            });
            // Exit the loop after adding the first qualifying vehicle
            // }
            //   ttweight+=total;
          }
          data1 = (getCategoryList((datamcc)));
          //
          // log("filter${jsonEncode(datamcc)}");
          // else {
          //
          // }
        }
        tripcount = getTotalVehiclesCount((datamcc));
        ttweight = 0;
      } else if (value == "out") {
        List<Map<String, dynamic>> filteredVehicles = [];
        for (var i = 0; i < main.vehicles.length; i++) {
          var vehicle = main.vehicles[i];
          if (vehicle["weight"] == null &&
              vehicle["front"] == null &&
              vehicle['back'] == null &&
              vehicle['right'] == null &&
              vehicle['left'] == null &&
              vehicle['weight_out'] != null &&
              vehicle["front_out"] != null &&
              vehicle['back_out'] != null &&
              vehicle["right_out"] != null &&
              vehicle["left_out"] != null) {
            filteredVehicles.add({
              "front": vehicle["front"],
              "back": vehicle["back"],
              "right": vehicle["right"],
              "left": vehicle["left"],
              "front_out": vehicle["front_out"],
              "back_out": vehicle["back_out"],
              "right_out": vehicle["right_out"],
              "left_out": vehicle["left_out"],
              "entry_dt": vehicle["entry_dt"],
              "entry_out": vehicle["entry_out"],
              "weight": vehicle["weight"],
              "weight_out": vehicle["weight_out"],
              "waste_weight": vehicle["waste_weight"],
              "empty_weight": vehicle["empty_weight"],
              "trip": vehicle["trip"],
              "vehicle_no": vehicle["vehicle_no"],
              "category": vehicle["category"],
            });
          }
          print("filter${filteredVehicles}");
          if (i == 0) {
            datamcc.add({
              "vehicle_no": main.vehicle_no,
              "username": main.username,
              "mcc": main.mcc,
              "vehicles":
              filteredVehicles // Adds all vehicles, not just the current one
            });
            // Exit the loop after adding the first qualifying vehicle
          }
          data1 = (getCategoryList((datamcc)));
        }
      } else {
        var total = int.parse(main.vehicles[main.vehicles.length - 1]['total']);
        if (weightLimitLower == 0) {
          if (total >= weightLimitLower &&
              (weightLimitUpper == -1 || total <= weightLimitUpper)) {
            data1.add({
              "vehicles": main.vehicles,
              "vehicle_no": main.vehicle_no,
              "username": main.username,
              "mcc": main.mcc
            });
            // tripcount += int.parse(main.vehicles.length.toString());
            // ttweight += total;
            // print("main-${tripcount+=int.parse(main.vehicles.length.toString())}");
          }
        } else {
          if (total > weightLimitLower &&
              (weightLimitUpper == -1 || total <= weightLimitUpper)) {
            data1.add({
              "vehicles": main.vehicles,
              "vehicle_no": main.vehicle_no,
              "username": main.username,
              "mcc": main.mcc
            });
            // tripcount += int.parse(main.vehicles.length.toString());
            // ttweight += total;
          }
        }
      }
    }
    setState(() {
      if (data1.isNotEmpty) {
        employees = data1.map((e) => Employee.fromJson(e)).toList();
      } else {
        employees = data1.map((e) => Employee.fromJson(e)).toList();
        noflag = true;
      }
    });
  }

  int pageNumber = 0;
  Future<void> exportDataGridToPdf(imageBytes) async {
    print("ffd");
    pageNumber = 0;
    setState(() {
      pdf = true;
    });

    // totalNetWeight=0.0;
    PdfDocument document = _key.currentState!.exportToPdfDocument(
      headerFooterExport:
          (DataGridPdfHeaderFooterExportDetails headerFooterExport) async {
        pageNumber++;

        // print(headerFooterExport);
        if (pageNumber == 1) {
          final double width = headerFooterExport.pdfPage.getClientSize().width;
          final PdfPageTemplateElement header =
          PdfPageTemplateElement(Rect.fromLTWH(0, 0, width, 65));
          final PdfBitmap image = PdfBitmap(imageBytes);
          if (widget.main == "avadi") {
            header.graphics.drawString(
              '${widget.main.capitalize()} Automatic Weighing System Monitoring Report\n                            (${DateFormat("dd-MM-yyyy").format(_selectedDate)})\n',
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(100, 1, 350, 60),
            );
          } else {
            header.graphics.drawString(
              '${widget.user == "tuty" ? "Thoothukudi" : widget.user.capitalize()} Automatic Weighing System Monitoring Report\n                     ${mcname} -(${DateFormat("dd-MM-yyyy").format(_selectedDate)})\n',
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(50, 1, 400, 60),
            );
          }
          header.graphics.drawString(
            // 'Total Net Weight: $ttweight\nTotal Gross Weight: $totalgroWeight',
            'Total Net Weight: ${(ttweight / 1000).toInt()}(Tons)',
            PdfStandardFont(PdfFontFamily.helvetica, 13,
                style: PdfFontStyle.bold),
            bounds: const Rect.fromLTWH(
                10, 40, 300, 60), // Position adjusted to top-left corner
          );

          if (image != null) {
            // Debug: Draw a rectangle

            header.graphics.drawImage(image, Rect.fromLTWH(460, 5, 50, 60));
          } else {
            print("Image is null");
          }
          headerFooterExport.pdfDocumentTemplate.top = header;

          // totalNetWeight = 0.0;
          // totalgroWeight = 0.0;
        }
      },
      fitAllColumnsInOnePage: true,
      canRepeatHeaders: false,
      cellExport: (details) {
        if (details.columnName == "trip" && details.cellValue != null) {
          // Determine the type of details.cellValue
          final cellValue = details.cellValue!;
          String horizontalLine = "\n" + "_" * 15 + "\n";
          if (selectedValue == "Trip wise") {
            if (cellValue is String &&
                cellValue.startsWith('[') &&
                cellValue.endsWith(']')) {
              try {
                final List<Map<String, dynamic>> tripList =
                List<Map<String, dynamic>>.from(jsonDecode(cellValue));
                String tripNames = "";
                for (int i = 0; i < tripList.length; i++) {
                  tripNames += tripList[i]['trip'];
                  if (i != tripList.length - 1) {
                    tripNames += horizontalLine; // add the horizontal line
                  }
                }
                details.pdfCell.value = tripNames;

                // Apply the custom border pen to the cell's bottom border
              } catch (e) {
                details.pdfCell.value = cellValue;
              }
            } else if (cellValue is List<Map<String, dynamic>>) {
              String tripNames = "";
              for (int i = 0; i < cellValue.length; i++) {
                tripNames += cellValue[i]['trip'];
                if (i != cellValue.length - 1) {
                  tripNames += horizontalLine; // add the horizontal line
                }
              }
              details.pdfCell.value = tripNames;
            }
          } else {
            List<dynamic> resultList = [cellValue];

            if (resultList.isNotEmpty && resultList[0] is Map) {
              Map<dynamic, dynamic>? resultMap =
              resultList[0] as Map<dynamic, dynamic>?;
              if (resultMap != null && resultMap.containsKey("trip")) {
                details.pdfCell.value = resultMap["trip"];
              }
            }

            details.pdfCell.style.textBrush = PdfBrushes.black;
            details.pdfCell.style.stringFormat = PdfStringFormat(
              // alignment: PdfTextAlignment.center,
              // lineAlignment: PdfVerticalAlignment.middle,
            );
          }
        } else if (details.columnName == "time" && details.cellValue != null) {
          // Determine the type of details.cellValue
          final cellValue = details.cellValue!;
          // print(cellValue);
          if (cellValue is String &&
              cellValue.startsWith('[') &&
              cellValue.endsWith(']')) {
            try {
              // If it's a String and looks like a JSON array, attempt JSON decoding
              final List<Map<String, dynamic>> timeList =
              List<Map<String, dynamic>>.from(jsonDecode(cellValue));
              final timeStrings = timeList.map((e) {
                final String entryDt = e['entry_dt'].toString();
                final DateTime dt = DateTime.parse(
                    DateFormat('yyyy-MM-dd HH:mm:ss')
                        .parse(entryDt)
                        .toString());
                final String time = DateFormat("hh:mm a").format(dt);
                return time;
              }).toList();

              // Join the time strings with horizontal lines
              final timeWithLines = timeStrings.asMap().entries.map((entry) {
                final index = entry.key;
                final timeEntry = entry.value;
                return index == timeStrings.length - 1
                    ? timeEntry // Don't add a horizontal line for the last entry
                    : "$timeEntry\n${"_" * 15}";
              }).join('\n');

              details.pdfCell.value = timeWithLines;
              details.pdfCell.style.textBrush = PdfBrushes.black;
              details.pdfCell.style.stringFormat = PdfStringFormat(
                alignment: PdfTextAlignment.center,
                lineAlignment: PdfVerticalAlignment.middle,
              );
            } catch (e) {
              // If decoding fails, default to the original cell value
              details.pdfCell.value = cellValue;
            }
          } else if (cellValue is List<Map<String, dynamic>>) {
            // If it's already the correct type, proceed without decoding
            final timeStrings = cellValue.map((e) {
              final String entryDt = e['entry_dt'].toString();
              final DateTime dt = DateTime.parse(
                  DateFormat('yyyy-MM-dd HH:mm:ss').parse(entryDt).toString());
              final String time = DateFormat("hh:mm a").format(dt);
              return time;
            }).toList();

            // Join the time strings with horizontal lines
            final timeWithLines = timeStrings.asMap().entries.map((entry) {
              final index = entry.key;
              final timeEntry = entry.value;
              return index == timeStrings.length - 1
                  ? timeEntry // Don't add a horizontal line for the last entry
                  : "$timeEntry\n${"_" * 15}";
            }).join('\n');

            details.pdfCell.value = timeWithLines;
            details.pdfCell.style.textBrush = PdfBrushes.black;
            details.pdfCell.style.stringFormat = PdfStringFormat(
              alignment: PdfTextAlignment.center,
              lineAlignment: PdfVerticalAlignment.middle,
            );
          }
        } else if (details.columnName == "outtime" &&
            details.cellValue != null &&
            details.cellValue != "null") {
          // Determine the type of details.cellValue
          final cellValue = details.cellValue!;
          print("dsads${cellValue}");
          if (cellValue is String &&
              cellValue.startsWith('[') &&
              cellValue.endsWith(']')) {
            try {
              // If it's a String and looks like a JSON array, attempt JSON decoding
              final List<Map<String, dynamic>> timeList =
              List<Map<String, dynamic>>.from(jsonDecode(cellValue));
              final timeStrings = timeList.map((e) {
                final String entryDt = e['entry_out'].toString();
                final DateTime dt = DateTime.parse(
                    DateFormat('yyyy-MM-dd HH:mm:ss')
                        .parse(entryDt)
                        .toString());
                final String time = DateFormat("hh:mm a").format(dt);
                return time;
              }).toList();

              // Join the time strings with horizontal lines
              final timeWithLines = timeStrings.asMap().entries.map((entry) {
                final index = entry.key;
                final timeEntry = entry.value;
                return index == timeStrings.length - 1
                    ? timeEntry // Don't add a horizontal line for the last entry
                    : "$timeEntry\n${"_" * 15}";
              }).join('\n');

              details.pdfCell.value = timeWithLines;
              details.pdfCell.style.textBrush = PdfBrushes.black;
              details.pdfCell.style.stringFormat = PdfStringFormat(
                alignment: PdfTextAlignment.center,
                lineAlignment: PdfVerticalAlignment.middle,
              );
            } catch (e) {
              // If decoding fails, default to the original cell value
              details.pdfCell.value = cellValue;
            }
          } else if (cellValue is List<Map<String, dynamic>>) {
            // If it's already the correct type, proceed without decoding
            final timeStrings = cellValue.map((e) {
              final String entryDt = e['entry_out'].toString();
              print("entry${entryDt.runtimeType}");
              if (entryDt == "null") {
                final String time = "NA";
                return time;
              } else {
                final DateTime dt = DateTime.parse(
                    DateFormat('yyyy-MM-dd HH:mm:ss')
                        .parse(entryDt)
                        .toString());
                final String time = DateFormat("hh:mm a").format(dt);
                return time;
              }
            }).toList();

            // Join the time strings with horizontal lines
            final timeWithLines = timeStrings.asMap().entries.map((entry) {
              final index = entry.key;
              final timeEntry = entry.value;
              return index == timeStrings.length - 1
                  ? timeEntry // Don't add a horizontal line for the last entry
                  : "$timeEntry\n${"_" * 15}";
            }).join('\n');

            details.pdfCell.value = timeWithLines;
            details.pdfCell.style.textBrush = PdfBrushes.black;
            details.pdfCell.style.stringFormat = PdfStringFormat(
              alignment: PdfTextAlignment.center,
              lineAlignment: PdfVerticalAlignment.middle,
            );
          }
        } else if (details.columnName == "gro.wt" &&
            details.cellValue != null) {
          // Determine the type of details.cellValue
          final cellValue = details.cellValue!;

          if (cellValue is String &&
              cellValue.startsWith('[') &&
              cellValue.endsWith(']')) {
            try {
              // If it's a String and looks like a JSON array, attempt JSON decoding
              final List<Map<String, dynamic>> tripList =
              List<Map<String, dynamic>>.from(jsonDecode(cellValue));
              final tripNames = tripList.map((e) => e['weight']).toList();

              // Create a list of strings with horizontal borders
              final tripNamesWithBorders =
              tripNames.asMap().entries.map((entry) {
                final index = entry.key;
                final weight = NumberFormat.currency(
                    locale: 'en_IN', symbol: '', decimalDigits: 0)
                    .format(int.parse(entry.value));
                return index == tripNames.length - 1
                    ? "$weight" // Don't add a horizontal line for the last entry
                    : "$weight\n${"_" * 15}";
              }).toList();

              details.pdfCell.value = tripNamesWithBorders.join('\n');
              details.pdfCell.style.textBrush = PdfBrushes.black;
              details.pdfCell.style.stringFormat = PdfStringFormat(
                alignment: PdfTextAlignment.center,
                lineAlignment: PdfVerticalAlignment.middle,
              );
            } catch (e) {
              // If decoding fails, default to the original cell value
              details.pdfCell.value = cellValue;
            }
          } else if (cellValue is List<Map<String, dynamic>>) {
            // If it's already the correct type, proceed without decoding
            final tripNames = cellValue.map((e) => e['weight']).toList();

            // Create a list of strings with horizontal borders
            final tripNamesWithBorders = tripNames.asMap().entries.map((entry) {
              final index = entry.key;
              final weight = NumberFormat.currency(
                  locale: 'en_IN', symbol: '', decimalDigits: 0)
                  .format(int.parse(entry.value));
              return index == tripNames.length - 1
                  ? "$weight" // Don't add a horizontal line for the last entry
                  : "$weight\n${"_" * 15}";
            }).toList();

            details.pdfCell.value = tripNamesWithBorders.join('\n');
            details.pdfCell.style.textBrush = PdfBrushes.black;
            details.pdfCell.style.stringFormat = PdfStringFormat(
              alignment: PdfTextAlignment.center,
              lineAlignment: PdfVerticalAlignment.middle,
            );
          }
          if (cellValue is List<Map<String, dynamic>>) {
            for (var item in cellValue) {
              final weight = double.tryParse(item['weight'].toString()) ?? 0.0;
              totalgroWeight += weight;
            }
          }
        } else if (details.columnName == "net.wt" &&
            details.cellValue != null) {
          // Determine the type of details.cellValue
          final cellValue = details.cellValue!;

          if (cellValue is String &&
              cellValue.startsWith('[') &&
              cellValue.endsWith(']')) {
            try {
              final List<Map<String, dynamic>> weightList =
              List<Map<String, dynamic>>.from(jsonDecode(cellValue));
              final weightDiffs = weightList.map((e) {
                final weight = int.parse(e['weight'].toString());
                final emptyWeight = int.parse(e['empty_weight'].toString());
                return weight <= emptyWeight
                    ? '0'
                    : (weight - emptyWeight).toString();
              }).toList();

              // Add a horizontal line after each entry
              final weightDiffsWithLines =
              weightDiffs.asMap().entries.map((entry) {
                final index = entry.key;
                final diff = NumberFormat.currency(
                    locale: 'en_IN', symbol: '', decimalDigits: 0)
                    .format(int.parse(entry.value));
                return index == weightDiffs.length - 1
                    ? diff // Don't add a horizontal line for the last entry
                    : "$diff\n${"_" * 15}";
              }).toList();

              details.pdfCell.value = weightDiffsWithLines.join('\n');
              details.pdfCell.style.textBrush = PdfBrushes.black;
              details.pdfCell.style.stringFormat = PdfStringFormat(
                alignment: PdfTextAlignment.center,
                lineAlignment: PdfVerticalAlignment.middle,
              );
            } catch (e) {
              details.pdfCell.value = cellValue;
            }
          } else if (cellValue is List<Map<String, dynamic>>) {
            final weightDiffs = cellValue.map((e) {
              final weight = int.parse(e['weight'].toString()) ?? 0;
              final emptyWeight = int.parse(e['empty_weight'].toString()) ?? 0;
              return weight <= emptyWeight
                  ? '0'
                  : (weight - emptyWeight).toString();
            }).toList();

            // Add a horizontal line after each entry
            final weightDiffsWithLines =
            weightDiffs.asMap().entries.map((entry) {
              final index = entry.key;
              final diff = NumberFormat.currency(
                  locale: 'en_IN', symbol: '', decimalDigits: 0)
                  .format(int.parse(entry.value));
              return index == weightDiffs.length - 1
                  ? diff // Don't add a horizontal line for the last entry
                  : "$diff\n${"_" * 15}";
            }).toList();

            details.pdfCell.value = weightDiffsWithLines.join('\n');
            details.pdfCell.style.textBrush = PdfBrushes.black;
            details.pdfCell.style.stringFormat = PdfStringFormat(
              alignment: PdfTextAlignment.center,
              lineAlignment: PdfVerticalAlignment.middle,
            );
          }
          if (cellValue is List<Map<String, dynamic>>) {
            for (var item in cellValue) {
              final weight = double.tryParse(item['weight'].toString()) ?? 0.0;
              final emptyWeight =
                  double.tryParse(item['empty_weight'].toString()) ?? 0.0;
              final netWeight =
              weight <= emptyWeight ? 0.0 : weight - emptyWeight;
              totalNetWeight += netWeight;
            }
          }
        } else if (details.columnName == "vehicle_no" &&
            details.cellValue != null) {
          final weightDiffs = details.cellValue!;
          details.pdfCell.value = weightDiffs;
          details.pdfCell.style.textBrush = PdfBrushes.black;
          details.pdfCell.style.stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle,
          );
        }

        //
        if (details.cellType == DataGridExportCellType.columnHeader) {
          details.pdfCell.style.backgroundBrush = PdfBrushes.pink;
          details.pdfCell.style.stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle,
          );
        }
        if (details.cellType == DataGridExportCellType.row) {
          details.pdfCell.style.backgroundBrush = PdfBrushes.lightCyan;
          details.pdfCell.style.stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle,
          );
        }
      },
    );
    final List<int> bytes = await document.save();
    await helper.saveAndLaunchFile(bytes,
        '${widget.user == "tuty" ? "Thoothukudi" : widget.user.capitalize()} Aws Report(${DateFormat("dd-MM-yyyy hh:mm:ss").format(_selectedDate)}).pdf');

    document.dispose();
    setState(() {
      pdf = false;
    });
  }

  Future<void> refresh() async {
    setState(() {
      getEmployeeData(_selectedDate, widget.mcc);
    });
  }

  // Future<DateTime?> _selectDate(BuildContext context, bool isFromDate) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: isFromDate ? _fromDate : _toDate,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2025),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       if (isFromDate) {
  //         _fromDate = picked;
  //       } else {
  //         _toDate = picked;
  //       }
  //     });
  //   }
  //   return picked;
  // }
  //
  Future<TimeOfDay?> _selectTime(BuildContext context, bool isFromTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isFromTime ? _fromTime : _toTime,
    );
    if (picked != null) {
      setState(() {
        if (isFromTime) {
          _fromTime = picked;
        } else {
          _toTime = picked;
        }
      });
    }
    return picked;
  }
  //
  // Future<void> _showCustomTimeDialog(BuildContext context) async {
  //   return showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Select From and To Date and Time'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: <Widget>[
  //               ListTile(
  //                 title: Text('From: ${DateFormat('dd-MM-yyyy – hh:mm:ss').format(_fromDate)}'),
  //                 trailing: Icon(Icons.calendar_today),
  //                 onTap: () async {
  //                   DateTime? pickedDate = await _selectDate(context, true);
  //                   if (pickedDate != null) {
  //                     TimeOfDay? pickedTime = await _selectTime(context, true);
  //                     if (pickedTime != null) {
  //                       setState(() {
  //                         _fromDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
  //                         _fromTime = pickedTime;
  //                       });
  //                     }
  //                   }
  //                   setState(() {});
  //                 },
  //               ),
  //               ListTile(
  //                 title: Text('To: ${DateFormat('dd-MM-yyyy – hh:mm:ss').format(_toDate)}'),
  //                 trailing: Icon(Icons.calendar_today),
  //                 onTap: () async {
  //                   DateTime? pickedDate = await _selectDate(context, false);
  //                   if (pickedDate != null) {
  //                     TimeOfDay? pickedTime = await _selectTime(context, false);
  //                     if (pickedTime != null) {
  //                       setState(() {
  //                         _toDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
  //                         _toTime = pickedTime;
  //                       });
  //                     }
  //                   }
  //                   setState(() {});
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text('OK'),
  //             onPressed: () {
  //
  //               Navigator.of(context).pop();
  //               setState(() {
  //                 _selectedDate=_fromDate;
  //                 getEmployeeData(_selectedDate, widget.mcc);
  //               });
  //               print(_fromDate);
  //               // No additional setState needed here if the state is already updated in ListTile onTap
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget _buildDateTimePickerTile(BuildContext context, bool isFrom, String label) {
  //   ValueNotifier<DateTime> dateNotifier = isFrom ? _fromDateNotifier : _toDateNotifier;
  //
  //   return ValueListenableBuilder<DateTime>(
  //     valueListenable: dateNotifier,
  //     builder: (context, date, child) {
  //       return ListTile(
  //         title: Row(
  //           children: <Widget>[
  //             Expanded(
  //               flex: 1,
  //               child: Text(
  //                 label,
  //                 style: TextStyle(fontSize: 14),
  //               ),
  //             ),
  //             Expanded(
  //               flex: 0,
  //               child: Text(
  //                 DateFormat('dd-MM-yyyy – hh:mm:ss a').format(date),
  //                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //           ],
  //         ),
  //         trailing: Icon(Icons.calendar_today),
  //         onTap: () async {
  //           DateTime? pickedDate = await _selectDate(context, isFrom);
  //           if (pickedDate != null) {
  //             TimeOfDay? pickedTime = await _selectTime(context, isFrom);
  //             if (pickedTime != null) {
  //               setState(() {
  //                 DateTime updatedDateTime = DateTime(
  //                   pickedDate.year,
  //                   pickedDate.month,
  //                   pickedDate.day,
  //                   pickedTime.hour,
  //                   pickedTime.minute,
  //                 );
  //                 // Check if the difference is within 24 hours
  //                 if (_isValidTimeDifference(updatedDateTime, isFrom)) {
  //                   // Update the ValueNotifier
  //                   dateNotifier.value = updatedDateTime;
  //                   if (isFrom) {
  //                     _fromTime = pickedTime;
  //                   } else {
  //                     _toTime = pickedTime;
  //                   }
  //                 } else {
  //                   // Show message
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text('The time difference should be within 24 hours.'),
  //                     ),
  //                   );
  //                 }
  //               });
  //             }
  //           }
  //         },
  //       );
  //     },
  //   );
  // }
  Widget _buildDateTimePickerTile(
      BuildContext context, bool isFrom, String label) {
    ValueNotifier<DateTime> dateNotifier =
    isFrom ? _fromDateNotifier : _toDateNotifier;

    return ListTile(
      title: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 8,
            child: ValueListenableBuilder<DateTime>(
              valueListenable: dateNotifier,
              builder: (_, DateTime value, __) {
                return Text(
                  DateFormat('hh:mm:ss a').format(value),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
        ],
      ),
      trailing: Icon(Icons.access_time),
      onTap: () async {
        TimeOfDay? pickedTime = await _selectTime(context, isFrom);
        if (pickedTime != null) {
          DateTime updatedDateTime = DateTime(
            dateNotifier.value.year,
            dateNotifier.value.month,
            dateNotifier.value.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          setState(() {
            dateNotifier.value = updatedDateTime; // Update the ValueNotifier
            if (isFrom) {
              _fromTime = pickedTime;
            } else {
              _toTime = pickedTime;
            }
          });
          print("Updated Time: ${dateNotifier.value}"); // Debug print
        }
      },
    );
  }
  // bool _isValidTimeDifference(DateTime selectedDateTime, bool isFrom) {
  //   // Logic to calculate the time difference
  //   DateTime fromDateTime = _fromDateNotifier.value;
  //   DateTime toDateTime = _toDateNotifier.value;
  //   Duration difference;
  //
  //   if (isFrom) {
  //     difference = toDateTime.difference(selectedDateTime);
  //   } else {
  //     difference = selectedDateTime.difference(fromDateTime);
  //   }
  //
  //   return difference <= Duration(hours: 24);
  // }

  Future<void> _showCustomTimeDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select From and To Time'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildDateTimePickerTile(context, true, 'From'),
                _buildDateTimePickerTile(context, false, 'To'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  print("frommm${_toDate}");
                  // _selectedDate = _fromDate;  // Ensure this is the intended logic
                  getEmployeeData(_selectedDate, widget.mcc);
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<Uint8List?> fetchAndReturnImageData() async {
    final String url =
        'http://dev.igps.io/avadi_new/assets/images/${widget.logo}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return null;
  }

  Future<void> exportDataGridToPdf1() async {
    setState(() {
      pdf = true;
    });
    final Uint8List? imageData = await fetchAndReturnImageData();
    if (imageData != null) {
      await exportDataGridToPdf(imageData);
    }
  }

  void onReturnFromDchart() {
    // Function to be called when returning from Dchart screen
    // Insert your logic here
    getEmployeeData(_selectedDate, widget.mcc);
  }

  // Future<Uint8List?> _loadImageBytes(String url) async {
  //   final response = await http.get(Uri.parse(url));
  //   if (response.statusCode == 200) {
  //     return Uint8List.fromList(response.bodyBytes);
  //   } else {
  //     print("Failed to load image: ${response.statusCode}");
  //     return null;
  //   }
  // }
  // Future<Uint8List> getImages(String path, int width) async{
  //   ByteData data = await rootBundle.load(path);
  //   ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width);
  //   ui.FrameInfo fi = await codec.getNextFrame();
  //   return(await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: (widget.main == "tuty" || widget.main == "mmc")
            ? Text("AWS  (${mcname})")
            : Text("AWS"),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: exportDataGridToPdf1,
                icon: Image.asset("assets/pdf.png"),
              ),
              search
                  ? Container(
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(10.0),
                //   border: Border.all(
                //       color: Colors.red,
                //       style: BorderStyle.solid,
                //       width: 0.80),
                // ),
                padding: const EdgeInsets.fromLTRB(0, 0, 5.0, 0),
                width: MediaQuery.of(context).size.width * 0.25,
                height: MediaQuery.of(context).size.height * 0.05,
                color: Colors.white,

                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: isSearchVisible == false ? 'Search' : "",
                      labelStyle: TextStyle(color: Colors.black)),
                  controller: order_controler,
                  onTap: () {
                    isSearchVisible = true;
                  },
                  onChanged: (value) {
                    searchText = value;
                    // Update the filtered data based on search query
                    setState(() {
                      if (value.isEmpty) {
                        employees = data
                            .map((e) => Employee.fromJson(e))
                            .toList();
                        bindex = 1;
                        // datas1=filteredData;
                      } else {
                        employees = data
                            .where((element) =>
                        element['vehicle_no']
                            .toLowerCase()
                            .contains(value.toLowerCase()) ||
                            element['vehicle_no']
                                .toString()
                                .contains(value))
                            .map((e) => Employee.fromJson(e))
                            .toList();
                        if (employees.isEmpty) {
                          noflag = true;
                        }
                        print("go${employees}");
                        // datas1=filteredData;
                      }
                    });
                  },
                ),
              )
                  : SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        isSearchVisible = false;
                        // print("dfdff");
                        search = !search;
                        if (search) {
                        } else {
                          // data = order_list;
                          if (bindex == 1) {
                            onItemChanged("ALL");
                          } else if (bindex == 2) {
                            onItemChanged("<2");
                          } else if (bindex == 3) {
                            onItemChanged("2-4");
                          } else if (bindex == 4) {
                            onItemChanged("4-5");
                          } else if (bindex == 5) {
                            onItemChanged("5");
                          }
                          // employees =
                          //     data.map((e) => Employee.fromJson(e)).toList();
                          order_controler.text = "";
                        }
                      });
                    },
                    icon: Icon(Icons.search)),
              ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
              //   child: IconButton(
              //       onPressed: () {
              //         getEmployeeData(_selectedDate);
              //       },
              //       icon: Icon(Icons.refresh)),
              // ),
            ],
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
                accountName: (widget.main == "tuty" ||
                    widget.main.toUpperCase() == "MMC")
                    ? Text(
                  '${widget.main == "tuty" ? "Thoothukudi" : widget.main.toUpperCase() == "MMC" ? widget.main.toUpperCase() : widget.main.capitalize()}(${mcname.contains('ALL') ? 'ALL' : mcname})',
                  style: const TextStyle(fontSize: 20),
                )
                    : Text(
                  '${widget.main.toUpperCase()}',
                  style: const TextStyle(fontSize: 20),
                ),
                accountEmail: null,
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Image.network(
                    "http://dev.igps.io/avadi_new/assets/images/${widget.logo}",
                    width: 65,
                    height: 65,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Dashboard'),
                leading: const Icon(Icons.dashboard),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage1(
                        user: widget.user,
                        pass: widget.pass,
                        main: widget.main,
                        logo: widget.logo,
                        mcc: widget.mcc,
                        type: widget.type,
                      ),
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
                title: const Text('Chart'),
                leading: const Icon(Icons.auto_graph),
                onTap: () {
                  Navigator.pop(context); // Close the drawer or current screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Dchart(
                        user: widget.user,
                        pass: widget.pass,
                        main: widget.main,
                        logo: widget.logo,
                        mcc: widget.mcc,
                        mcname: mcname,
                        type: widget.type,
                      ),
                    ),
                  ).then((_) {
                    // Call the function here after returning from Dchart screen
                    onReturnFromDchart();
                  });
                },
              ),
              Divider(
                height: 1.2,
                color: Colors.black38,
                thickness: 1,
              ),
              ListTile(
                title: const Text('Consolidated Report'),
                leading: const Icon(Icons.padding_outlined),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Creport(
                        user: widget.user,
                        pass: widget.pass,
                        main: widget.main,
                        logo: widget.logo,
                        mcc: widget.mcc,
                        mcname: mcname,
                        type: widget.type,
                      ),
                    ),
                  ).then((_) {
                    // Call the function here after returning from Dchart screen
                    onReturnFromDchart();
                  });
                },
              ),
              Divider(
                height: 1.2,
                color: Colors.black38,
                thickness: 1,
              ),

              // Divider(
              //   height: 1.2,
              //   color: Colors.black38,
              //   thickness: 1,
              // ),
              // ListTile(
              //   title: const Text('Settings'),
              //   leading: const Icon(Icons.settings),
              //   onTap: () {
              //     Navigator.pop(context);
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => Setting(
              //             user: widget.user,
              //             pass: widget.pass,
              //             main: widget.main,
              //             logo: widget.logo,
              //             mcc: widget.mcc,
              //             mcname: mcname,
              //             type: widget.type,
              //           )),
              //     );
              //   },
              // ),

              // Divider(
              //   height: 1.2,
              //   color: Colors.black38,
              //   thickness: 1,
              // ),
              // ListTile(
              //   title: const Text('Logout'),
              //   leading: const Icon(
              //     Icons.logout,
              //   ),
              //   onTap: () async {
              //     // SharedPreferences prefrences =
              //     // await SharedPreferences.getInstance();
              //     Navigator.pop(context);
              //     showDialog(
              //         context: context,
              //         builder: (context) {
              //           return AlertDialog(
              //             title: const Text('Logout'),
              //             content:
              //             const Text('Are You Want Confirm to Logout ..'),
              //             actions: <Widget>[
              //               ElevatedButton(
              //                 onPressed: () async {
              //                   SharedPreferences prefrences =
              //                   await SharedPreferences.getInstance();
              //                   await prefrences.remove("username");
              //                   await prefrences.remove("password");
              //                   await prefrences.remove("main_user");
              //                   await prefrences.remove("mcc");
              //                   await prefrences.remove("type");
              //                   await prefrences.remove("logo");
              //                   // await prefrences.remove("location");
              //                   Navigator.pushReplacement(
              //                       context,
              //                       MaterialPageRoute(
              //                         builder: (context) => const HomeScreen(),
              //                       ));
              //                 },
              //                 child: const Text('OK'),
              //               ),
              //               ElevatedButton(
              //                   onPressed: () => Navigator.of(context).pop(),
              //                   child: const Text('Cancel')),
              //             ],
              //           );
              //         });
              //
              //     // Navigator.pushReplacement(
              //     //   context,
              //     //   MaterialPageRoute(
              //     //     builder: (context) => HomeScreen(),
              //     //   ),
              //     // );
              //   },
              // ),
              // Divider(height: 0.2,),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Card(
                        elevation: 10,
                        color: getcol,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.all(4.0),
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
                    Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      // height: MediaQuery.of(context).size.height * 0.110,
                      // padding: EdgeInsets.all(0.0),
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
                              children: [
                                Text(
                                  "${(ttweight / 1000).toInt()}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 40),
                                ),
                                Text(
                                  "Total Wt(ton)",
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
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  height: 30,
                                  padding: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    border: Border.all(
                                        color: Colors.grey,
                                        style: BorderStyle.solid,
                                        width: 0.80),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      hint: Text(
                                        'Select Item',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                      items: items
                                          .map((item) =>
                                          DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ))
                                          .toList(),
                                      value: selectedValue,
                                      onChanged: (String? value) {
                                        setState(() {
                                          selectedValue = value as String;
                                          print(selectedValue);
                                          noflag = false;
                                          bindex = 1;
                                          getcol = Colors.green;

                                          isNextRowVisible = false;
                                        });
                                        getEmployeeData(
                                            _selectedDate, widget.mcc);
                                      },
                                      buttonHeight: 40,
                                      buttonWidth: 140,
                                      itemHeight: 40,
                                    ),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.orangeAccent,
                      // padding:EdgeInsets.fromLTRB(25,5, 0, 0),
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.065,
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
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = DateTime(
                                            _selectedDate.year,
                                            _selectedDate.month,
                                            _selectedDate.day - 1);
                                        // table(imei,_selectedDate);
                                        if (mcname == "ALL") {
                                          getEmployeeData(
                                              _selectedDate, widget.mcc);
                                        } else {
                                          getEmployeeData(
                                              _selectedDate, mcname);
                                        }
                                        // selectedValue=items[0];
                                        times = true;
                                        // getimg(_selectedDate);
                                      });
                                    },
                                    child: Image.asset('assets/minus.png'))
                              // Padding(
                              //   padding: const EdgeInsets.all(0),
                              //   child: Container(
                              //     decoration: BoxDecoration(
                              //       shape: BoxShape.circle,
                              //       color: Colors.red, // inner circle color
                              //     ),
                              //     child: IconButton(
                              //         onPressed: () {
                              //           setState(() {
                              //             _selectedDate = DateTime(
                              //                 _selectedDate.year,
                              //                 _selectedDate.month,
                              //                 _selectedDate.day - 1);
                              //             // table(imei,_selectedDate);
                              //             if(mcname=="ALL") {
                              //               getEmployeeData(_selectedDate, widget.mcc);
                              //             }else{
                              //               getEmployeeData(_selectedDate, mcname);
                              //             }
                              //             // getimg(_selectedDate);
                              //           });
                              //         },
                              //         icon: Icon(
                              //           Icons.remove,
                              //           color: Colors.white,
                              //           size: 10,
                              //         )),
                              //   ),
                              // ),
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
                                    print("mcc*** ${mcname}");
                                    times = true;
                                    if (mcname == "ALL") {
                                      getEmployeeData(
                                          _selectedDate, widget.mcc);
                                    } else {
                                      getEmployeeData(_selectedDate, mcname);
                                    }
                                    // getimg(_selectedDate);

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
                                child: GestureDetector(
                                    onTap: () {
                                      DateTime now = DateTime.now();
                                      DateTime todayMidnight = DateTime(
                                          now.year, now.month, now.day);
                                      DateTime selectedDateMidnight = DateTime(
                                          _selectedDate.year,
                                          _selectedDate.month,
                                          _selectedDate.day);
                                      if (selectedDateMidnight
                                          .isBefore(todayMidnight)) {
                                        setState(() {
                                          _selectedDate = DateTime(
                                              _selectedDate.year,
                                              _selectedDate.month,
                                              _selectedDate.day + 1);
                                          print("plus ${mcname}");
                                          if (mcname == "ALL") {
                                            getEmployeeData(
                                                _selectedDate, widget.mcc);
                                          } else {
                                            getEmployeeData(
                                                _selectedDate, mcname);
                                          }
                                          times = true;
                                          // print(
                                          //     _inputFormat.format(_selectedDate));
                                        });
                                      }
                                    },
                                    child: Image.asset('assets/plus.png'))
                              // Padding(
                              //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              //   child: Container(
                              //     decoration: BoxDecoration(
                              //       shape: BoxShape.circle,
                              //       color: Colors.red, // inner circle color
                              //     ),
                              //     child: IconButton(
                              //         onPressed: () {
                              //           DateTime now = DateTime.now();
                              //           DateTime todayMidnight = DateTime(now.year, now.month, now.day);
                              //           DateTime selectedDateMidnight = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
                              //           if (selectedDateMidnight.isBefore(todayMidnight)) {
                              //             setState(() {
                              //               _selectedDate = DateTime(
                              //                   _selectedDate.year,
                              //                   _selectedDate.month,
                              //                   _selectedDate.day+1);
                              //               print("plus ${mcname}");
                              //               if(mcname=="ALL") {
                              //                 getEmployeeData(_selectedDate, widget.mcc);
                              //               }else{
                              //                 getEmployeeData(_selectedDate, mcname);
                              //               }
                              //               // print(
                              //               //     _inputFormat.format(_selectedDate));
                              //             });
                              //           }
                              //         },
                              //         icon: Icon(
                              //           Icons.add,
                              //           color: Colors.white,
                              //           size: 10,
                              //         )),
                              //   ),
                              // ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Schedule", // Replace with your actual title
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: 30,
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.0),
                                border: Border.all(
                                    color: Colors.grey,
                                    style: BorderStyle.solid,
                                    width: 0.80),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  hint: Text(
                                    'Select Item',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                  items: itemtime
                                      .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                                      .toList(),
                                  value: selectedValuetime,
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedValuetime = value as String;
                                      print(selectedValuetime);
                                      noflag = false;
                                      bindex = 1;
                                      getcol = Colors.green;
                                      getime = value;
                                      if (selectedValuetime == "Custom Time") {
                                        _showCustomTimeDialog(context);
                                      } else {
                                        getEmployeeData(
                                            _selectedDate, widget.mcc);
                                      }
                                      isNextRowVisible = false;
                                    });
                                  },
                                  buttonHeight: 40,
                                  buttonWidth:
                                  MediaQuery.of(context).size.width * 0.2,
                                  itemHeight: 40,
                                  icon: Transform.translate(
                                    offset: Offset(-8,
                                        0), // Adjust the position of the icon
                                    child: Icon(Icons.arrow_drop_down,
                                        size:
                                        20), // Adjust the size of the icon
                                    // Adjust the size of the icon
                                  ),
                                ),
                              )),
                          // times==false?Container(
                          //     width:MediaQuery.of(context).size.width*0.3,
                          //     height: 30,
                          //     padding: EdgeInsets.all(5.0),
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(30.0),
                          //       border: Border.all(
                          //           color: Colors.grey,
                          //           style: BorderStyle.solid,
                          //           width: 0.80),
                          //     ),
                          //     child: DropdownButtonHideUnderline(
                          //       child: DropdownButton2(
                          //         hint: Text(
                          //           'Select Item',
                          //           style: TextStyle(
                          //             fontSize: 14,
                          //             color: Theme.of(context).hintColor,
                          //           ),
                          //         ),
                          //         items: itemtime
                          //             .map((item) =>
                          //             DropdownMenuItem<String>(
                          //               value: item,
                          //               child: Text(
                          //                 item,
                          //                 style: const TextStyle(
                          //                   fontSize: 14,
                          //                 ),
                          //               ),
                          //             ))
                          //             .toList(),
                          //         value: selectedValuetime,
                          //         onChanged: (String? value) {
                          //           setState(() {
                          //             selectedValuetime = value as String;
                          //             print(selectedValuetime);
                          //             noflag = false;
                          //             bindex = 1;
                          //             getcol = Colors.green;
                          //             getime = value;
                          //             if (selectedValuetime == "Custom Time") {
                          //               _showCustomTimeDialog(context);
                          //             }
                          //             else{
                          //               getEmployeeData(
                          //                   _selectedDate, widget.mcc);
                          //             }
                          //             isNextRowVisible = false;
                          //           });
                          //
                          //         },
                          //         buttonHeight: 40,
                          //         buttonWidth:
                          //         MediaQuery.of(context).size.width * 0.2,
                          //         itemHeight: 40,
                          //         icon: Transform.translate(
                          //           offset: Offset(-8, 0), // Adjust the position of the icon
                          //           child: Icon(Icons.arrow_drop_down, size: 20), // Adjust the size of the icon
                          //           // Adjust the size of the icon
                          //         ),
                          //       ),
                          //     )):Container(
                          //     width:MediaQuery.of(context).size.width*0.30,
                          //     height: 30,
                          //     padding: EdgeInsets.all(5.0),
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(30.0),
                          //       border: Border.all(
                          //           color: Colors.grey,
                          //           style: BorderStyle.solid,
                          //           width: 0.80),
                          //     ),
                          //     child: DropdownButtonHideUnderline(
                          //       child: DropdownButton2(
                          //         hint: Text(
                          //           'Select Item',
                          //           style: TextStyle(
                          //             fontSize: 14,
                          //             color: Theme.of(context).hintColor,
                          //           ),
                          //         ),
                          //         items: itemtime
                          //             .map((item) =>
                          //             DropdownMenuItem<String>(
                          //               value: item,
                          //               child: Text(
                          //                 item,
                          //                 // overflow: TextOverflow.ellipsis,
                          //                 style: const TextStyle(
                          //                   fontSize: 14,
                          //                 ),
                          //               ),
                          //             ))
                          //             .toList(),
                          //         value: "ALL",
                          //         onChanged: (String? value) {
                          //           setState(() {
                          //             times=false;
                          //             selectedValuetime = value as String;
                          //             print(selectedValuetime);
                          //             noflag = false;
                          //             bindex = 1;
                          //             getcol = Colors.green;
                          //             getime = value;
                          //             if (selectedValuetime == "Custom Time") {
                          //               _showCustomTimeDialog(context);
                          //             }
                          //             else{
                          //               getEmployeeData(
                          //                   _selectedDate, widget.mcc);
                          //             }
                          //             isNextRowVisible = false;
                          //           });
                          //
                          //         },
                          //         buttonHeight: 40,
                          //         buttonWidth:
                          //         MediaQuery.of(context).size.width * 0.2,
                          //         itemHeight: 40,
                          //         icon: Transform.translate(
                          //           offset: Offset(-8, 0), // Adjust the position of the icon
                          //           child: Icon(Icons.arrow_drop_down, size: 20), // Adjust the size of the icon
                          //         // Adjust the size of the icon
                          //         ),
                          //       ),
                          //     )),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.008,
                      ),
                      Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Category", // Replace with your actual title
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.34,
                              height: 30,
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.0),
                                border: Border.all(
                                    color: Colors.grey,
                                    style: BorderStyle.solid,
                                    width: 0.80),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  hint: Text(
                                    'Select Category',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                  items: cate
                                      .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      // overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                                      .toList(),
                                  value: selectedValuecat,
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedValuecat = value as String;
                                      print(selectedValuecat);
                                      noflag = false;
                                      bindex = 1;
                                      getcol = Colors.green;
                                      // getime = value;

                                      getEmployeeData(
                                          _selectedDate, widget.mcc);

                                      // isNextRowVisible = false;
                                    });
                                  },
                                  buttonHeight: 40,
                                  buttonWidth:
                                  MediaQuery.of(context).size.width * 0.2,
                                  itemHeight: 40,
                                  icon: Transform.translate(
                                    offset: Offset(-8,
                                        0), // Adjust the position of the icon
                                    child: Icon(Icons.arrow_drop_down,
                                        size:
                                        20), // Adjust the size of the icon
                                  ),
                                ),
                              )),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.008,
                      ),
                      Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Type", // Replace with your actual title
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.35,
                            height: MediaQuery.of(context).size.height * 0.041,
                            padding: EdgeInsets.fromLTRB(5, 0, 10,
                                10), // Horizontal padding for inner spacing
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors
                                      .grey), // Optional: for visualizing the container boundary
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: toggle == 1
                                ? TextDropdownFormField(
                              options: typp,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                suffixIcon: Transform.translate(
                                  offset: Offset(12,
                                      3), // Adjust offset for left movement
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    size: 20,
                                  ),
                                ),
                                contentPadding:
                                EdgeInsets.fromLTRB(0, -8, 0, 10),
                              ),
                              dropdownHeight:
                              MediaQuery.of(context).size.height *
                                  0.2,
                              onChanged: (dynamic value) {
                                setState(() {
                                  selectedValuetype = value as String;
                                  print(selectedValuetype);
                                  getEmployeeData(
                                      _selectedDate, widget.mcc);
                                });
                              },
                            )
                                : DropdownButtonFormField<String>(
                              value: selectedValuetype,
                              isExpanded:
                              true, // Ensure the dropdown is expanded to fill the container
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Colors.black),
                              elevation: 15,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                // border: OutlineInputBorder(
                                //   borderRadius: BorderRadius.all(Radius.circular(10)),
                                // ),
                                contentPadding: EdgeInsets.fromLTRB(
                                    5,
                                    -8,
                                    12,
                                    10), // Padding inside the dropdown
                              ),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                  14), // Font size of the dropdown items
                              dropdownColor: Colors.lightBlueAccent,
                              onTap: () {
                                setState(() {
                                  toggle = 1;
                                });
                              },
                              onChanged: (String? value) {
                                if (value != null) {
                                  setState(() {
                                    selectedValuetype = value;
                                    getEmployeeData(
                                        _selectedDate, widget.mcc);
                                  });
                                }
                              },
                              items: typp.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.065,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                bindex = 1;
                                onItemChanged("ALL");
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              side: bindex == 1
                                  ? BorderSide(
                                  width: 3, color: Colors.lightBlueAccent)
                                  : BorderSide(width: 3, color: Colors.grey),
                              primary: Colors.green,
                              // Background color
                            ),
                            child: FittedBox(
                                fit: BoxFit.cover,
                                child: Text(
                                  "ALL\n(${www4.toString()})",
                                  textAlign: TextAlign.center,
                                )),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.065,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              bindex = 2;
                              onItemChanged("inout");
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            side: bindex == 2
                                ? BorderSide(
                                width: 3, color: Colors.lightBlueAccent)
                                : BorderSide(width: 3, color: Colors.grey),
                            primary: Colors.purple, // Background color
                          ),
                          child: Text(
                            "INOUT\n(${inout.toString()})",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.065,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                bindex = 3;
                                onItemChanged("in");
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                side: bindex == 3
                                    ? BorderSide(
                                    width: 3, color: Colors.lightBlueAccent)
                                    : BorderSide(width: 3, color: Colors.grey),
                                primary: Colors.blue), // Background color
                            child: Text(
                              "IN\n(${ins.toString()})",
                              textAlign: TextAlign.center,
                            )),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.065,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                bindex = 4;
                                onItemChanged("out");
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                side: bindex == 4
                                    ? BorderSide(
                                    width: 3, color: Colors.lightBlueAccent)
                                    : BorderSide(width: 3, color: Colors.grey),
                                primary:
                                Colors.yellow[800]), // Background color
                            child: Text(
                              "OUT\n(${out.toString()})",
                              textAlign: TextAlign.center,
                            )),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      IconButton(
                        icon: Icon(
                          isNextRowVisible
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            isNextRowVisible = !isNextRowVisible;
                            if (isNextRowVisible == false) {
                              bindex = 1;
                              onItemChanged("ALL");
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Visibility(
                  visible: isNextRowVisible,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.065,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              bindex = 5;
                              onItemChanged("<2");
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            side: bindex == 5
                                ? BorderSide(
                                width: 3, color: Colors.lightBlueAccent)
                                : BorderSide(width: 3, color: Colors.grey),
                            primary: Colors.purple, // Background color
                          ),
                          child: Text(" < 2Ton\n     (${wwwto.toString()})"),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.065,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                bindex = 6;
                                onItemChanged("2-4");
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                side: bindex == 6
                                    ? BorderSide(
                                    width: 3, color: Colors.lightBlueAccent)
                                    : BorderSide(width: 3, color: Colors.grey),
                                primary: Colors.blue), // Background color
                            child:
                            Text(" 2 - 4Ton\n     (${www1.toString()})")),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.065,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                bindex = 7;
                                onItemChanged("4-5");
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                side: bindex == 7
                                    ? BorderSide(
                                    width: 3, color: Colors.lightBlueAccent)
                                    : BorderSide(width: 3, color: Colors.grey),
                                primary:
                                Colors.yellow[800]), // Background color
                            child:
                            Text(" 4 - 5Ton\n      (${www2.toString()})")),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.065,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                bindex = 8;
                                onItemChanged("5>");
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                side: bindex == 8
                                    ? BorderSide(
                                    width: 3, color: Colors.lightBlueAccent)
                                    : BorderSide(width: 3, color: Colors.grey),
                                primary: Colors.red), // Background color
                            child: Text(" 5Ton>\n    (${www3.toString()})")),
                      )
                    ],
                    // Next row content goes here
                    // ...
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                RefreshIndicator(
                  onRefresh: refresh,
                  child: employees.isNotEmpty
                      ? Container(
                    height: MediaQuery.of(context).size.height * 0.565,
                    child: SfDataGridTheme(
                      data: SfDataGridThemeData(
                          gridLineColor: Colors.black26,
                          gridLineStrokeWidth: 1.0,
                          headerColor: const Color(0xff009889),
                          sortIconColor: Colors.white),
                      child: SfDataGrid(
                        source: EmployeeDataSource(
                            employees: employees, context: context),
                        key: _key,
                        columnWidthMode: ColumnWidthMode.fill,
                        rowHeight:
                        selectedValue == "Trip wise" ? rowHeight : 50,
                        headerRowHeight: 32,
                        gridLinesVisibility: GridLinesVisibility.both,
                        allowSorting:
                        selectedValue == "Trip wise" ? false : true,
                        columns: [
                          GridColumn(
                              columnName: '#',
                              width:
                              selectedValue == "Trip wise" ? 30 : 30,
                              label: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: selectedValue == "Trip wise"
                                          ? Border(
                                        left: BorderSide(
                                            color: Colors.grey,
                                            width:
                                            1.0), // Add left border
                                        right: BorderSide(
                                            color: Colors.white,
                                            width:
                                            1.0), // Add right border/ Add right border
                                      )
                                          : Border(
                                        left: BorderSide(
                                            color: Colors.white,
                                            width:
                                            1.0), // Add left border
                                        // right: BorderSide(color: Colors.white, width: 1.0), // Add right border
                                      )),
                                  child: Text(
                                    '#',overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white),
                                  ))),
                          GridColumn(
                            columnName: 'vehicle_no',
                            label: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: selectedValue == "Trip wise"
                                        ? Border(
                                      left: BorderSide(
                                          color: Colors.grey,
                                          width:
                                          1.0), // Add left border
                                      right: BorderSide(
                                          color: Colors.white,
                                          width:
                                          1.0), // Add right border/ Add right border
                                    )
                                        : Border(
                                      left: BorderSide(
                                          color: Colors.white,
                                          width:
                                          1.0), // Add left border
                                    )),
                                child: Text(
                                  'Vehicle',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white),
                                )),width:72,),
                          GridColumn(
                              columnName: 'trip',
                              label: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: selectedValue == "Trip wise"
                                          ? Border(
                                        left: BorderSide(
                                            color: Colors.grey,
                                            width:
                                            1.0), // Add left border
                                        right: BorderSide(
                                            color: Colors.white,
                                            width:
                                            1.0), // Add right border/ Add right border
                                      )
                                          : Border(
                                        left: BorderSide(
                                            color: Colors.white,
                                            width:
                                            1.0), // Add left border
                                      )),
                                  child: Text(
                                    'Trip',
                                    style: TextStyle(color: Colors.white),
                                  ))),
                          GridColumn(
                              columnName: 'time',
                              label: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: selectedValue == "Trip wise"
                                          ? Border(
                                        left: BorderSide(
                                            color: Colors.grey,
                                            width:
                                            1.0), // Add left border
                                        right: BorderSide(
                                            color: Colors.white,
                                            width:
                                            1.0), // Add right border/ Add right border
                                      )
                                          : Border(
                                        left: BorderSide(
                                            color: Colors.white,
                                            width:
                                            1.0), // Add left border
                                      )),
                                  child: Text(
                                    'In Time',
                                    style: TextStyle(color: Colors.white),
                                  ))),
                          GridColumn(
                              columnName: 'outtime',
                              label: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: selectedValue == "Trip wise"
                                          ? Border(
                                        left: BorderSide(
                                            color: Colors.grey,
                                            width:
                                            1.0), // Add left border
                                        right: BorderSide(
                                            color: Colors.white,
                                            width:
                                            1.0), // Add right border/ Add right border
                                      )
                                          : Border(
                                        left: BorderSide(
                                            color: Colors.white,
                                            width:
                                            1.0), // Add left border
                                      )),
                                  child: Text(
                                    'Out Time',
                                    style: TextStyle(color: Colors.white),
                                  ))),
                          GridColumn(
                              columnName: 'gro.wt',
                              label: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: selectedValue == "Trip wise"
                                          ? Border(
                                        left: BorderSide(
                                            color: Colors.grey,
                                            width:
                                            1.0), // Add left border
                                        right: BorderSide(
                                            color: Colors.white,
                                            width:
                                            1.0), // Add right border/ Add right border
                                      )
                                          : Border(
                                        left: BorderSide(
                                            color: Colors.white,
                                            width:
                                            1.0), // Add left border
                                      )),
                                  child: Text(
                                    'Gro.wt',
                                    style: TextStyle(color: Colors.white),
                                  ))),
                          GridColumn(
                              columnName: 'net.wt',
                              label: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: selectedValue == "Trip wise"
                                          ? Border(
                                        left: BorderSide(
                                            color: Colors.grey,
                                            width:
                                            1.0), // Add left border
                                        right: BorderSide(
                                            color: Colors.white,
                                            width:
                                            1.0), // Add right border/ Add right border
                                      )
                                          : Border(
                                        left: BorderSide(
                                            color: Colors.white,
                                            width:
                                            1.0), // Add left border
                                      )),
                                  child: Text(
                                    'Net.wt',

                                    style: TextStyle(color: Colors.white),
                                  ))),
                        ],
                      ),
                    ),
                  )
                      : (noflag == true)
                      ? Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            "No Data",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  )
                      : Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          pdf == true
              ? Center(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                child: CircularProgressIndicator(),
              ),
            ),
          )
              : Container()
        ],
      ),
    );
  }
}

class EmployeeDataSource extends DataGridSource {
  late final List<Employee> employees;
  final BuildContext context;
  Map<int, double> rowHeights = {};
  int currentRow = 0;

  EmployeeDataSource({required this.employees, required this.context}) {}

  @override
  List<DataGridRow> get rows {
    var sortedEmployees = employees.length;
    return employees.asMap().entries.map<DataGridRow>((entry) {
      int index = entry.key;
      var e = entry.value;
      return DataGridRow(cells: [
        if (selectedValue == "Trip wise") ...[
          DataGridCell<int>(columnName: '#', value: sortedEmployees - index),
          DataGridCell<String>(
              columnName: 'vehicle_no',
              value: e.category == "Corporation NO GPS"
                  ? "Corp-No GPS"
                  : e.category == "Ourland"
                  ? "Ourland-NO GPS"
                  : e.vehicle_no),
          DataGridCell<List<Map<String, dynamic>>>(
              columnName: 'trip',
              value: e.vehicles
                  .map<Map<String, dynamic>>(
                      (v) => {'trip': v['trip'], 'index': index})
                  .toList()),
          DataGridCell<List<Map<String, dynamic>>>(
              columnName: 'time',
              value: e.vehicles
                  .map<Map<String, dynamic>>((v) => {'entry_dt': v['entry_dt']})
                  .toList()),
          DataGridCell<List<Map<String, dynamic>>>(
              columnName: 'outtime',
              value: e.vehicles
                  .map<Map<String, dynamic>>(
                      (v) => {'entry_out': v['entry_out']})
                  .toList()),
          DataGridCell<List<Map<String, dynamic>>>(
              columnName: 'gro.wt',
              value: e.vehicles
                  .map<Map<String, dynamic>>((v) => {'weight': v['weight']})
                  .toList()),
          DataGridCell<List<Map<String, dynamic>>>(
              columnName: 'net.wt',
              value: e.vehicles
                  .map<Map<String, dynamic>>((v) => {
                'empty_weight': v['empty_weight'],
                'weight': v['weight']
              })
                  .toList()),
        ] else ...[
          DataGridCell<int>(columnName: '#', value: sortedEmployees - index),
          DataGridCell<String>(
              columnName: 'vehicle_no',
              value: e.category == "Corporation NO GPS"
                  ? "Corp-No GPS"
                  : e.category == "Ourland"
                  ? "Ourland-NO GPS"
                  : e.vehicle_no),
          DataGridCell<dynamic>(
              columnName: 'trip', value: {"trip": e.trip, "index": index}),
          DataGridCell<String>(
              columnName: 'time', value: dataformater(e.entry_dt.toString())),
          DataGridCell<String>(
              columnName: 'outtime',
              value: dataformater(e.entry_out.toString())),
          DataGridCell<String>(
              columnName: 'gro.wt', value: dataformater1(e.weight.toString())),
          DataGridCell<String>(
              columnName: 'net.wt',
              value: dataformater1(e.waste_weight.toString())),
        ]
      ]);
    }).toList();
  }

  @override
  double getRowHeight(int rowIndex) {
    // Custom logic to set the height based on the number of vehicles
    int numberOfVehicles = employees[rowIndex].vehicles.length;
    double baseHeight = 50.0; // Base height
    double extraHeightPerVehicle = 20.0; // Additional height per vehicle

    return baseHeight + (numberOfVehicles * extraHeightPerVehicle);
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    print("emm${row}");
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        String valueText = cell.value.toString();
        String formattedText;

        if (valueText.length == 13) {
          formattedText =
          '${valueText.substring(0, 8)} \n ${valueText.substring(valueText.length - 4)}';
        } else if (valueText.length == 12) {
          formattedText =
          '${valueText.substring(0, 7)} \n ${valueText.substring(valueText.length - 4)}';
        } else {
          formattedText =
              valueText; // No need to split if it's less than 13 characters
        }

        if (selectedValue == 'Trip wise') {
          if (cell.columnName == 'trip') {
            final List<Map<String, dynamic>> tripList = cell.value;
            return Center(
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: tripList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.5),
                    child: GestureDetector(
                      onTap: () {
                        if (users.toUpperCase() == "MMC") {
                          _handleTripClicktime(context, tripList[index],
                              tripList[index]["index"], index);
                        } else {
                          _handleTripClick(context, tripList[index],
                              tripList[index]["index"], index);
                        }
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[400],
                          ),
                          child: Center(
                            child: Text(
                              tripList[index]['trip'] ?? '-',
                              style:
                              TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          )),

                      // ListTile(titripList[index]['trip'] ?? '-'),
                    ),
                  );
                },
              ),
            );
          } else if (cell.columnName == 'time') {
            final List<Map<String, dynamic>> tripList = cell.value;
            return Center(
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: tripList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                          child: Center(
                            child: Text(
                              dataformater(
                                  tripList[index]['entry_dt'].toString() ?? '-'),
                              style: TextStyle(fontSize: 13),
                            ),
                          )),
                    ],
                  );
                },
              ),
            );
          } else if (cell.columnName == 'outtime') {
            final List<Map<String, dynamic>> tripList = cell.value;
            return Center(
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: tripList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                          child: Center(
                            child: Text(
                              dataformater(
                                  tripList[index]['entry_out'].toString() ?? '-'),
                              style: TextStyle(fontSize: 13),
                            ),
                          )),
                    ],
                  );
                },
              ),
            );
          } else if (cell.columnName == 'gro.wt') {
            final List<Map<String, dynamic>> tripList = cell.value;
            return Center(
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: tripList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        //color: Colors.orangeAccent,
                          child: Text(
                            (NumberFormat.currency(
                                locale: 'en_IN',
                                symbol: '',
                                decimalDigits: 0)
                                .format(
                                int.parse(tripList[index]['weight']==null?"0":tripList[index]['weight']))) ??
                                '-',
                            style: TextStyle(fontSize: 15),
                          )),
                    ],
                  );
                },
              ),
            );
          } else if (cell.columnName == 'net.wt') {
            final List<Map<String, dynamic>> tripList = cell.value;
            return Center(
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: tripList.length,
                itemBuilder: (context, index) {
                  int weight = int.parse(tripList[index]['weight']==null?"0":tripList[index]['weight']);
                  int emptyWeight = int.parse(tripList[index]['empty_weight']);
                  int weightDifference =
                  emptyWeight == 0 ? 0 : (weight - emptyWeight);
                  Color finalColor = getFinalColor(weightDifference);
                  return StreamBuilder<Object>(
                      stream: null,
                      builder: (context, snapshot) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  child: Center(
                                    child: Text(
                                        (int.parse(tripList[index]['weight']==null?"0":tripList[index]['weight']) <=
                                            int.parse(tripList[index]
                                            ['empty_weight']) ||
                                            int.parse(tripList[index]
                                            ['empty_weight']) ==
                                                0)
                                            ? "0"
                                            : '${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(int.parse(tripList[index]['weight']) - int.parse(tripList[index]['empty_weight']))}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: finalColor)),
                                  )),
                            ],
                          ),
                        );
                      });
                },
              ),
            );
          }
          return Center(
            // print(cell.value)
              child: Text(
                formattedText,
                style: TextStyle(
                    color: formattedText.contains("Corp-No GPS") ||
                        formattedText.contains("Ourland-NO GPS")
                        ? Colors.red
                        : Colors.black,
                    fontWeight: formattedText.contains("Corp-No GPS") ||
                        formattedText.contains("Ourland-NO GPS")
                        ? FontWeight.bold
                        : FontWeight.normal),
              ));
        } else {
          if (cell.columnName == 'trip') {
            List<dynamic> resultList = [cell.value];
            print(resultList);
            return GestureDetector(
                onTap: () async {
                  // if()
                  // print(context);
                  if (users.toUpperCase() == "MMC") {
                    _handleTripClicktime1(context, resultList[0]['index']);
                  } else {
                    _handleTripClick1(context, resultList[0]['index']);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[400],
                    ),
                    child: Center(
                        child: Text(resultList[0]['trip'] ?? '-',
                            style:
                            TextStyle(fontSize: 15, color: Colors.black))),
                  ),
                ));
          } else if (cell.columnName == 'net.wt') {
            int? parsedValue = int.tryParse(cell.value.replaceAll(",", ""));
            Color finalColor;
            if (parsedValue != null) {
              finalColor = getFinalColor(parsedValue);
            } else {
              finalColor =
                  Colors.black; // Replace with a default color of your choice
            }
            return Center(
                child: Text(
                  cell.value.toString() ?? "-",
                  style: TextStyle(color: finalColor, fontWeight: FontWeight.bold),
                ));
          }
          return Center(
              child: Text(
                cell.value.toString() ?? "-",
                style: TextStyle(
                    color: formattedText.contains("Corp-No GPS") ||
                        formattedText.contains("Ourland-NO GPS")
                        ? Colors.red
                        : Colors.black,
                    fontWeight: formattedText.contains("Corp-No GPS") ||
                        formattedText.contains("Ourland-NO GPS")
                        ? FontWeight.bold
                        : FontWeight.normal),
              ));
        }
      }).toList(),
    );
  }

  @override
  DataGridRowAdapter buildFooterRow(DataGridRow row) {
    // print("bharath");
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'gro.wt') {
          int totalWeight =
          employees.fold(0, (sum, e) => sum + int.parse(e.weight));
          return Center(child: Text('Total Weight: ${totalWeight}'));
        } else if (cell.columnName == 'net.wt') {
          int totalNetWeight =
          employees.fold(0, (sum, e) => sum + int.parse(e.waste_weight));
          return Center(child: Text('Total Net Weight: ${totalNetWeight}'));
        }
        return Center(child: Text('Footer: ${cell.columnName}'));
      }).toList(),
    );
  }
}

void _handleTripClick1(BuildContext context, index) {
  var file_name;
  if (employees[index].username == 'avadi') {
    file_name = "/files/" + employees[index].username + "/";
  } else {
    file_name = "/files/" +
        employees[index].username +
        "/" +
        employees[index].mcc +
        "/";
  }
  String frontImage = file_name + employees[index].front;
  String backImage = file_name + employees[index].back;
  String rightImage = file_name + employees[index].right;
  String leftImage = file_name + employees[index].left;
  String vehicle = employees[index].vehicle_no ?? '-';
  String driver = employees[index].driver_name ?? '-';
  String weight = employees[index].weight ?? '-';
  String emptyWeight = employees[index].empty_weight ?? '-';
  String trip = employees[index].trip ?? '-';
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation1, animation2) => ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: double.infinity,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          Dialog(
            backgroundColor: Colors.grey[300],
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  decoration: BoxDecoration(
                    color: _colorFromHex("254C7C"),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.001,
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: "${vehicle}(${driver})\n"),
                            WidgetSpan(
                              child: Text(
                                "${trip}",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        // textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                      // SizedBox(
                      //   width: 50,
                      // ),
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
                SizedBox(height: 5),
                InkWell(
                  onTap: () {
                    imagePaths = [];
                    Navigator.pop(context);
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                    _showImageDialog(context, 0, imagePaths, "cat");
                  },
                  child: Column(
                    children: [
                      Text(
                        "Front",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${frontImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          // Return an alternative image here
                          return Image.asset(
                            'assets/photo-gallery.png', // Path to your placeholder image
                            height: MediaQuery.of(context).size.height * 0.165,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill,
                          );
                        },
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    imagePaths = [];
                    Navigator.pop(context);
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                    _showImageDialog(context, 1, imagePaths, "cat");
                  },
                  child: Column(
                    children: [
                      Text(
                        "Back",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${backImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          // Return an alternative image here
                          return Image.asset(
                            'assets/photo-gallery.png', // Path to your placeholder image
                            height: MediaQuery.of(context).size.height * 0.165,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill,
                          );
                        },
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    imagePaths = [];
                    Navigator.pop(context);
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                    _showImageDialog(context, 3, imagePaths, "cat");
                  },
                  child: Column(
                    children: [
                      Text(
                        "Left",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${leftImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          // Return an alternative image here
                          return Image.asset(
                            'assets/photo-gallery.png', // Path to your placeholder image
                            height: MediaQuery.of(context).size.height * 0.165,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill,
                          );
                        },
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    imagePaths = [];
                    Navigator.pop(context);
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                    _showImageDialog(context, 2, imagePaths, "cat");
                  },
                  child: Column(
                    children: [
                      Text(
                        "Right",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${rightImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          // Return an alternative image here
                          return Image.asset(
                            'assets/photo-gallery.png', // Path to your placeholder image
                            height: MediaQuery.of(context).size.height * 0.165,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill,
                          );
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: FittedBox(
                              child: Text(
                                "Gross weight - Empty weight=Net weight",
                                style: TextStyle(fontSize: 15.0),
                              )),
                        ),
                        Text(
                          '(${weight}  -  ${emptyWeight} =${int.parse(weight!) - int.parse(emptyWeight!)})',
                          style: TextStyle(fontSize: 15.0),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
    barrierColor: Colors.black54,
    barrierDismissible: false,
    barrierLabel: 'This dialog cannot be dismissed by tapping on the barrier.',
    transitionDuration: Duration(milliseconds: 200),
  );
}

void _handleTripClicktime1(BuildContext context, int index) {
  print(employees[index].mcc);
  var file_name;
  if (employees[index].username == 'avadi') {
    file_name = "/files/" + employees[index].username! + "/";
  } else {
    file_name = "/files/" +
        employees[index].username! +
        "/" +
        employees[index].mcc! +
        "/";
  }

  String frontImage = file_name + (employees[index].front?? "-");
  String backImage = file_name + (employees[index].back?? "-");
  String rightImage = file_name + (employees[index].right?? "-");
  String leftImage = file_name + (employees[index].left?? "-");
  String frontImageOut = file_name + (employees[index].front_out ?? "-");
  String backImageOut = file_name + (employees[index].back_out ?? "-");
  String rightImageOut = file_name + (employees[index].right_out ?? "-");
  String leftImageOut = file_name + (employees[index].left_out ?? "-");
  String vehicle = employees[index].vehicle_no ?? '-';
  String driver = employees[index].driver_name ?? '-';
  String weight = employees[index].weight==null?"0":employees[index].weight ?? '-';
  String emptyWeight = employees[index].empty_weight ?? '0';
  String trip = employees[index].trip ?? '-';
  // Other variable declarations...

  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return DefaultTabController(
        length: 2,
        child: Dialog(
          backgroundColor: Colors.grey[300],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tab bar
              Container(
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                  color: _colorFromHex("254C7C"),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.001,
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: "${vehicle}(${driver})\n",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                              WidgetSpan(
                                child: Text(
                                  "${trip}",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          // textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   width: 50,
                    // ),
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
              // SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.04, // Adjust the height as needed
                  child: TabBar(
                    indicatorColor: Colors.blue,
                    labelColor:
                    Colors.black, // Color of the text for selected tab
                    unselectedLabelColor: Colors
                        .grey[300], // Color of the text for unselected tabs
                    labelStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold), // Font size for the text
                    tabs: [
                      Tab(text: 'In'),
                      Tab(text: 'Out'),
                    ],
                  ),
                ),
              ),
              // Tab bar view
              Expanded(
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                            _showImageDialog(context, 0, imagePaths, "in");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Front IN",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImage}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                            _showImageDialog(context, 1, imagePaths, "in");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Back IN",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImage}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                            _showImageDialog(context, 3, imagePaths, "in");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Left IN",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImage}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                            _showImageDialog(context, 2, imagePaths, "in");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Right IN",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImage}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width:
                                  MediaQuery.of(context).size.width * 0.65,
                                  child: FittedBox(
                                      child: Text(
                                        "Gross weight - Empty weight=Net weight",
                                        style: TextStyle(fontSize: 15.0),
                                      )),
                                ),
                                Text(
                                  '(${weight}  -  ${emptyWeight} =${weight=="0"?"0":(int.parse(weight!) - int.parse(emptyWeight!))})',
                                  style: TextStyle(fontSize: 15.0),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}');

                            _showImageDialog(context, 0, imagePaths, "out");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Front OUT",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}');

                            _showImageDialog(context, 1, imagePaths, "out");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Back OUT",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}');

                            _showImageDialog(context, 3, imagePaths, "out");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Left OUT",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}');

                            _showImageDialog(context, 2, imagePaths, "out");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Right OUT",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width:
                                  MediaQuery.of(context).size.width * 0.65,
                                  child: FittedBox(
                                      child: Text(
                                        "Gross weight - Empty weight=Net weight",
                                        style: TextStyle(fontSize: 15.0),
                                      )),
                                ),
                                Text(
                                  '(${weight}  -  ${emptyWeight} =${weight=="0"?"0":(int.parse(weight!) - int.parse(emptyWeight!))})',
                                  style: TextStyle(fontSize: 15.0),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              // Other widgets...
            ],
          ),
        ),
      );
    },
    barrierColor: Colors.black54,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    transitionDuration: Duration(milliseconds: 200),
  );
}

void _handleTripClick(
    BuildContext context, Map<String, dynamic> tripData, index, index1) {
  print(employees[index].vehicles);
  var file_name;
  if (employees[index].username == 'avadi') {
    file_name = "/files/" + employees[index].username + "/";
  } else {
    file_name = "/files/" +
        employees[index].username +
        "/" +
        employees[index].mcc +
        "/";
  }
  String frontImage =
      file_name + employees[index].vehicles[index1]["front"] ?? '-';
  String backImage =
      file_name + employees[index].vehicles[index1]["back"] ?? '-';
  String rightImage =
      file_name + employees[index].vehicles[index1]["right"] ?? '-';
  String leftImage =
      file_name + employees[index].vehicles[index1]["left"] ?? '-';
  String vehicle = employees[index].vehicles[index1]["vehicle_no"] ?? '-';
  String driver = employees[index].vehicles[index1]["driver_name"] ?? '-';
  String weight = employees[index].vehicles[index1]["weight"] ?? '-';
  String emptyWeight = employees[index].vehicles[index1]["empty_weight"] ?? '-';
  String trip = employees[index].vehicles[index1]["trip"] ?? '-';
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation1, animation2) => ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: double.infinity,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          Dialog(
            backgroundColor: Colors.grey[300],
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  decoration: BoxDecoration(
                    color: _colorFromHex("254C7C"),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.001,
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: "${vehicle}(${driver})\n"),
                            WidgetSpan(
                              child: Text(
                                "${trip}",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        // textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                      //
                      // SizedBox(
                      //   width: 50,
                      // ),
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
                SizedBox(height: 5),
                // titlePadding: const EdgeInsets.all(0),
                InkWell(
                  onTap: () {
                    imagePaths = [];
                    Navigator.pop(context);
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                    _showImageDialog(context, 0, imagePaths, "cat");
                  },
                  child: Column(
                    children: [
                      Text(
                        "Front",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${frontImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          // Return an alternative image here
                          return Image.asset(
                            'assets/photo-gallery.png', // Path to your placeholder image
                            height: MediaQuery.of(context).size.height * 0.165,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill,
                          );
                        },
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    imagePaths = [];
                    Navigator.pop(context);
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                    _showImageDialog(context, 1, imagePaths, "cat");
                  },
                  child: Column(
                    children: [
                      Text(
                        "Back",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${backImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          // Return an alternative image here
                          return Image.asset(
                            'assets/photo-gallery.png', // Path to your placeholder image
                            height: MediaQuery.of(context).size.height * 0.165,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill,
                          );
                        },
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    imagePaths = [];
                    Navigator.pop(context);
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                    _showImageDialog(context, 3, imagePaths, "cat");
                  },
                  child: Column(
                    children: [
                      Text(
                        "Left",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${leftImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          // Return an alternative image here
                          return Image.asset(
                            'assets/photo-gallery.png', // Path to your placeholder image
                            height: MediaQuery.of(context).size.height * 0.165,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill,
                          );
                        },
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    imagePaths = [];
                    Navigator.pop(context);
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                    imagePaths.add(
                        'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                    _showImageDialog(context, 2, imagePaths, "cat");
                  },
                  child: Column(
                    children: [
                      Text(
                        "Right",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${rightImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          // Return an alternative image here
                          return Image.asset(
                            'assets/photo-gallery.png', // Path to your placeholder image
                            height: MediaQuery.of(context).size.height * 0.165,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fill,
                          );
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: FittedBox(
                              child: Text(
                                "Gross weight - Empty weight=Net weight",
                                style: TextStyle(fontSize: 15.0),
                              )),
                        ),
                        Text(
                          '(${weight}  -  ${emptyWeight} =${int.parse(weight!) - int.parse(emptyWeight!)})',
                          style: TextStyle(fontSize: 15.0),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
    barrierColor: Colors.black54,
    barrierDismissible: false,
    barrierLabel: 'This dialog cannot be dismissed by tapping on the barrier.',
    transitionDuration: Duration(milliseconds: 200),
  );
}

void _handleTripClicktime(
    BuildContext context, Map<String, dynamic> tripData, index, index1) {
  print("sss${employees[index].vehicles}");
  var file_name;
  if (employees[index].username == 'avadi') {
    file_name = "/files/" + employees[index].username + "/";
  } else {
    file_name = "/files/" +
        employees[index].username +
        "/" +
        employees[index].mcc +
        "/";
  }
  String frontImage =
      file_name + (employees[index].vehicles[index1]["front"] ?? '-');
  String backImage =
      file_name + (employees[index].vehicles[index1]["back"] ?? '-');
  String rightImage =
      file_name + (employees[index].vehicles[index1]["right"] ?? '-');
  String leftImage =
      file_name + (employees[index].vehicles[index1]["left"] ?? '-');
  String frontImageOut =
      file_name + (employees[index].vehicles[index1]["front_out"] ?? '-');
  String backImageOut =
      file_name + (employees[index].vehicles[index1]["back_out"] ?? '-');
  String rightImageOut =
      file_name + (employees[index].vehicles[index1]["right_out"] ?? '-');
  String leftImageOut =
      file_name + (employees[index].vehicles[index1]["left_out"] ?? '-');
  String vehicle = employees[index].vehicles[index1]["vehicle_no"] ?? '-';
  String driver = employees[index].vehicles[index1]["driver_name"] ?? '-';
  String weight = employees[index].vehicles[index1]["weight"]==null?"0":employees[index].vehicles[index1]["weight"]?? '-';
  String emptyWeight = employees[index].vehicles[index1]["empty_weight"] ?? '-';
  String trip = employees[index].vehicles[index1]["trip"] ?? '-';
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return DefaultTabController(
        length: 2,
        child: Dialog(
          backgroundColor: Colors.grey[300],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tab bar
              Container(
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                  color: _colorFromHex("254C7C"),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.001,
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: "${vehicle}(${driver})\n",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                              WidgetSpan(
                                child: Text(
                                  "${trip}",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          // textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   width: 50,
                    // ),
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
              // SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.04, // Adjust the height as needed
                  child: TabBar(
                    indicatorColor: Colors.blue,
                    labelColor:
                    Colors.black, // Color of the text for selected tab
                    unselectedLabelColor: Colors
                        .grey[300], // Color of the text for unselected tabs
                    labelStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold), // Font size for the text
                    tabs: [
                      Tab(text: 'In'),
                      Tab(text: 'Out'),
                    ],
                  ),
                ),
              ),
              // Tab bar view
              Expanded(
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                            _showImageDialog(context, 0, imagePaths, "in");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Front IN",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImage}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                            _showImageDialog(context, 1, imagePaths, "in");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Back IN",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImage}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                            _showImageDialog(context, 3, imagePaths, "in");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Left IN",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImage}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImage}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImage}');

                            _showImageDialog(context, 2, imagePaths, "in");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Right IN",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImage}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width:
                                  MediaQuery.of(context).size.width * 0.65,
                                  child: FittedBox(
                                      child: Text(
                                        "Gross weight - Empty weight=Net weight",
                                        style: TextStyle(fontSize: 15.0),
                                      )),
                                ),
                                Text(
                                  '(${weight}  -  ${emptyWeight} =${weight=="0"?"0":(int.parse(weight!) - int.parse(emptyWeight!))})',
                                  style: TextStyle(fontSize: 15.0),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}');

                            _showImageDialog(context, 0, imagePaths, "out");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Front OUT",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}');

                            _showImageDialog(context, 1, imagePaths, "out");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Back OUT",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}');

                            _showImageDialog(context, 3, imagePaths, "out");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Left OUT",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            imagePaths = [];
                            Navigator.pop(context);
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}');

                            _showImageDialog(context, 2, imagePaths, "out");
                          },
                          child: Column(
                            children: [
                              Text(
                                "Right OUT",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}',
                                height:
                                MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  // Return an alternative image here
                                  return Image.asset(
                                    'assets/photo-gallery.png', // Path to your placeholder image
                                    height: MediaQuery.of(context).size.height *
                                        0.165,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width:
                                  MediaQuery.of(context).size.width * 0.65,
                                  child: FittedBox(
                                      child: Text(
                                        "Gross weight - Empty weight=Net weight",
                                        style: TextStyle(fontSize: 15.0),
                                      )),
                                ),
                                Text(
                                  '(${weight}  -  ${emptyWeight} =${weight=="0"?"0":(int.parse(weight!) - int.parse(emptyWeight!))})',
                                  style: TextStyle(fontSize: 15.0),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              // Other widgets...
            ],
          ),
        ),
      );
    },
    barrierColor: Colors.black54,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    transitionDuration: Duration(milliseconds: 200),
  );
}

void _showImageDialog(
    BuildContext context, int index, List<dynamic> imagePaths, cat) {
  var txt = 'Front';
  int currentIndex = index;
  PhotoViewScaleStateController? scaleStateController;
  PhotoViewController photoViewController;
  photoViewController = PhotoViewController();
  scaleStateController = PhotoViewScaleStateController();
  void goBack() {
    photoViewController.scale = photoViewController.initial.scale;
  }

  if (index == 0) {
    if (cat == "cat") {
      txt = 'Front';
    } else if (cat == "in") {
      txt = 'Front IN';
    } else {
      txt = 'Front OUT';
    }
  } else if (index == 1) {
    if (cat == "cat") {
      txt = 'Back';
    } else if (cat == "in") {
      txt = 'Back IN';
    } else {
      txt = 'Back OUT';
    }
  } else if (index == 2) {
    if (cat == "cat") {
      txt = 'Right';
    } else if (cat == "in") {
      txt = 'Right IN';
    } else {
      txt = 'Right OUT';
    }
  } else {
    if (cat == "cat") {
      txt = 'Left';
    } else if (cat == "in") {
      txt = 'Left IN';
    } else {
      txt = 'Left OUT';
    }
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
                    ),
                    scaleStateController: scaleStateController,
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 150,
                  child: Text(
                    txt,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 30,
                  child: ElevatedButton(
                    child: Text("Reset"),
                    onPressed: () {
                      photoViewController.scale =
                          photoViewController.initial.scale;
                    },
                  ),
                ),
                Positioned(
                  top: 5,
                  left: 10,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      )),
                ),
                Positioned(
                  bottom: 20,
                  left: 90,
                  child: ElevatedButton(
                    child: Text("Prev"),
                    onPressed: () {
                      setState(() {
                        if (currentIndex >= 1 && currentIndex <= 3) {
                          currentIndex =
                              (currentIndex - 1 + imagePaths.length) %
                                  imagePaths.length;
                          if (currentIndex == 0) {
                            if (cat == "cat") {
                              txt = 'Front';
                            } else if (cat == "in") {
                              txt = 'Front IN';
                            } else {
                              txt = 'Front OUT';
                            }
                          } else if (currentIndex == 1) {
                            if (cat == "cat") {
                              txt = 'Back';
                            } else if (cat == "in") {
                              txt = 'Back IN';
                            } else {
                              txt = 'Back OUT';
                            }
                          } else if (currentIndex == 2) {
                            if (cat == "cat") {
                              txt = 'Right';
                            } else if (cat == "in") {
                              txt = 'Right IN';
                            } else {
                              txt = 'Right OUT';
                            }
                          } else if (currentIndex == 3) {
                            if (cat == "cat") {
                              txt = 'Left';
                            } else if (cat == "in") {
                              txt = 'Left IN';
                            } else {
                              txt = 'Left OUT';
                            }
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
                        if (currentIndex >= 0 && currentIndex < 3) {
                          currentIndex = (currentIndex + 1) % imagePaths.length;
                          if (currentIndex == 0) {
                            if (cat == "cat") {
                              txt = 'Front';
                            } else if (cat == "in") {
                              txt = 'Front IN';
                            } else {
                              txt = 'Front OUT';
                            }
                          } else if (currentIndex == 1) {
                            if (cat == "cat") {
                              txt = 'Back';
                            } else if (cat == "in") {
                              txt = 'Back IN';
                            } else {
                              txt = 'Back OUT';
                            }
                          } else if (currentIndex == 2) {
                            if (cat == "cat") {
                              txt = 'Right';
                            } else if (cat == "in") {
                              txt = 'Right IN';
                            } else {
                              txt = 'Right OUT';
                            }
                          } else if (currentIndex == 3) {
                            if (cat == "cat") {
                              txt = 'Left';
                            } else if (cat == "in") {
                              txt = 'Left IN';
                            } else {
                              txt = 'Left OUT';
                            }
                          }
                        }
                      });
                    },
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

dataformater(String dt) {
  // print("dddd${dt}");
  if (dt == null || dt.isEmpty || dt == "null") {
    return "NA";
  } else {
    DateTime fromdate =
    DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dt).toString());
    String parsedfromdate = DateFormat("hh:mma").format(fromdate);
    return parsedfromdate;
  }
}

dataformater1(String dt) {
  // print(dt);
  if (dt == null || dt.isEmpty || dt == "null") {
    return "NA";
  } else {
    String parsedfromdate =
    (NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0)
        .format(int.parse(dt)));
    return parsedfromdate;
  }
}

Color _colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}

Color getFinalColor(int weightDifference) {
  if (weightDifference <= 2000) {
    return Colors.green;
  } else if (weightDifference > 2000 && weightDifference <= 4000) {
    return Colors.lightBlue;
  } else if (weightDifference > 4000 && weightDifference <= 5000) {
    return Colors.yellow.shade700;
  } else if (weightDifference > 5000) {
    return Colors.red;
  }
  return Colors.black; // default color
}

Map<String, dynamic> buildTempArray(Map<String, dynamic> data) {
  return {
    'sno': data['sno'],
    'category': data['category'],
    'trip': data['trip'],
    'weight': data['weight'],
    'empty_weight': data['empty_weight'],
    'vehicle_no': data['vehicle_no'],
    'driver_name': data['driver_name'],
    'entry_dt': data['entry_dt'],
    'left': data['left'],
    'right': data['right'],
    'back': data['back'],
    'front': data['front'],
    'left_out': data['left_out'],
    'right_out': data['right_out'],
    'back_out': data['back_out'],
    'front_out': data['front_out'],
    'weight_out': data['weight_out'],
    'entry_out': data['entry_out'],
    'waste_weight': data['waste_weight'],
    'total': data['total'].toString()
  };
}

// Map<String, dynamic> buildTempArray1(Employee data) {
//   return {
//     'trip': data.trip,
//     'weight': data.weight,
//     'empty_weight': data.empty_weight,
//     'vehicle_no': data.vehicle_no,
//     'driver_name': data.driver_name,
//     'entry_dt': data.entry_dt,
//     'left': data.left,
//     'right': data.right,
//     'back': data.back,
//     'front': data.front,
//     'left_out': data.left_out,
//     'right_out': data.right_out,
//     'back_out': data.back_out,
//     'front_out': data.front_out,
//     'weight_out': data.weight_out,
//     'entry_out': data.entry_out,
//     'waste_weight': data.waste_weight,
//     'total': data.total.toString()
//   };
// }
class Employee {
  final dynamic vehicle_no;
  final dynamic driver_name;
  final dynamic imei;
  final dynamic date;
  final List<Map<String, dynamic>> vehicles;
  final dynamic trip;
  final dynamic entry_dt;
  final dynamic empty_weight;
  final dynamic weight;
  final dynamic weight_out;
  final dynamic waste_weight;
  final dynamic front;
  final dynamic back;
  final dynamic right;
  final dynamic left;
  final dynamic front_out;
  final dynamic back_out;
  final dynamic right_out;
  final dynamic left_out;
  final dynamic total;
  final dynamic username;
  final dynamic mcc;
  final dynamic entry_out;
  final dynamic category;
  final dynamic vehicle_type;

  Employee({
    required this.vehicle_no,
    required this.driver_name,
    required this.imei,
    required this.date,
    required this.vehicles,
    required this.trip,
    required this.entry_dt,
    required this.empty_weight,
    required this.weight,
    required this.weight_out,
    required this.waste_weight,
    required this.front,
    required this.back,
    required this.right,
    required this.left,
    required this.front_out,
    required this.back_out,
    required this.right_out,
    required this.left_out,
    required this.total,
    required this.username,
    required this.mcc,
    required this.entry_out,
    required this.category,
    required this.vehicle_type,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
        vehicle_no: json['vehicle_no'],
        driver_name: json['driver_name'],
        imei: json['imei'],
        date: json['date'],
        trip: json['trip'],
        entry_dt: json['entry_dt'],
        empty_weight: json['empty_weight'],
        weight: json['weight'],
        waste_weight: json['waste_weight'],
        weight_out: json['weight_out'],
        front: json['front'],
        back: json['back'],
        right: json['right'],
        left: json['left'],
        front_out: json['front_out'],
        back_out: json['back_out'],
        right_out: json['right_out'],
        left_out: json['left_out'],
        total: json['total'],
        username: json['username'],
        mcc: json['mcc'],
        entry_out: json['entry_out'],
        category: json['category'],
        vehicle_type: json['vehicle_type'],
        vehicles: json["vehicles"] != null
            ? List<Map<String, dynamic>>.from(json['vehicles'])
            : []);
  }
}
