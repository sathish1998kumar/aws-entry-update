import 'dart:convert';
import 'dart:developer';
// import 'dart:js';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'data.dart';

class data extends StatefulWidget {
  final String user;
  final String pass;
  const data({super.key, required this.user, required this.pass});

  @override
  State<data> createState() => _dataState();
}
var imgarr=[];
class _dataState extends State<data> {
  List<Employee> employees = <Employee>[];
  late EmployeeDataSource employeeDataSource;
  final CustomColumnSizer _customColumnSizer = CustomColumnSizer();
  var _inputFormat = DateFormat('dd-MM-yyyy');
  var _selectedDate = DateTime.now();
  bool hasVehicleData=false;
  @override
  void initState() {
    super.initState();
     getEmployeeData();
    getimg(_selectedDate);
    employeeDataSource = EmployeeDataSource(employeeData: employees, context: context);
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
  getEmployeeData() async {

    var map = {
      "action": "select_rfid",
      "district": "ALL",
      "imei": "ALL",
      "over": "Daily Report",
      "panch": "ALL",
      "subzone": "ALL",
      "username": "avadi",
      "from": DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 00:00:00',
      "to": DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 23:59:59',
    };
    print(map);
    String url = "http://dev.igps.io/avadi_new/api/getrf_api.php";
    try {
      var response = await http.post(Uri.parse(url), body: (jsonEncode(map)));
      print(response);
      if (response.statusCode == 200) {

        Iterable list = jsonDecode(response.body);
        final List<Employee> dummyData = list.map((model) => Employee.fromJson(model)).toList();

        if(dummyData.isNotEmpty) {
          setState(() {
            log("Dummy Data Length: ${dummyData}");
            // for (int s1 = 0; s1 < dummyData.length; s1++) {
            //   var obj = dummyData[s1];
            //
            //   var vehi = obj.vehicles;
            //   for (int k1 = 0; k1 < vehi.length; k1++) {
            //     var obj1 = vehi[k1];
            //     print("dfdfd${obj1}");
            //     // var trip1 = obj1["trip"];
            //     // // print(obj1["weight"]);
            //     // if (k1 == 0) {
            //     if ((obj1["weight"] != "no")) {
            //
            //     }
            //     // else {
            //     //
            //     //   }
            //     // }
            //
            //   }
            // }

            employees = dummyData;
            print("ggg : ${employees}");
         if(employees.any((e) => e.vehicles[0]["weight"]!="no")){
           hasVehicleData=true;
           print("hasVehicleData${hasVehicleData}");
         }
            employeeDataSource = EmployeeDataSource(employeeData: employees, context: context);
            print("setState called with finaldata size ${employees.length}");
          });

        } else {
          print("No data received.");
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid user!!"),
        ));
      }
    } catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syncfusion Flutter DataGrid'),
      ),
      body: SfDataGrid(
        source: employeeDataSource,
        columnWidthMode: ColumnWidthMode.fill,
        columnSizer: _customColumnSizer,
        onQueryRowHeight: (RowHeightDetails details) {
          return details.getIntrinsicRowHeight(details.rowIndex);
        },
        columns:<GridColumn>[
          // GridColumn(
          //     columnName: 'vehicle_no',
          //     label: Container(
          //         padding: EdgeInsets.all(16.0),
          //         alignment: Alignment.center,
          //         child: Text(
          //           'vehicle_no',
          //         ))),
          // GridColumn(
          //     columnName: 'imei',
          //     label: Container(
          //         padding: EdgeInsets.all(8.0),
          //         alignment: Alignment.center,
          //         child: Text('imei'))),
          // GridColumn(
          //     columnName: 'date',
          //     label: Container(
          //         padding: EdgeInsets.all(8.0),
          //         alignment: Alignment.center,
          //         child: Text(
          //           'date',
          //           overflow: TextOverflow.ellipsis,
          //         ))),
          GridColumn(
              columnName: 'vehicle_no',
              label: Container(

                  padding: EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('vehicle_no'))),
          GridColumn(
              columnName: 'trip',
              label: Container(
                  // padding: EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('trip'))),
          GridColumn(
              columnName: 'weight',
              label: Container(
                  // padding: EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('weight'))),

          GridColumn(
              columnName: 'Net.wt',
              label: Container(
                  // padding: EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('Net.Wt'))),
        ],
        // onQueryRowHeight: (details) {
        //   return details.getIntrinsicRowHeight(details.rowIndex);
        // },
      ),
    );
  }



}
class Employee {
  dynamic vehicle_no;
  dynamic driver_name;
  dynamic imei;
  dynamic date;
  dynamic vehicles;



  Employee(
      {
        this.vehicle_no,
        this.driver_name,
        this.imei,
        this.date,
        this.vehicles,
      });

  Employee.fromJson(Map<String, dynamic> json) {

    if (json['vehicles'] is List && json['vehicles'][0]["weight"] != "no") {
      vehicle_no = json['vehicle_no'] ?? '';
      driver_name = json['driver_name'] ?? '';
      imei = json['imei'] ?? '';
      date = json['date'] ?? '';
      // vehicles = List<Map<String, dynamic>>.from(json['vehicles']);
      vehicles = json["vehicles"];
    } else {
      // Initialize to default values or keep them null, based on your class properties
      vehicle_no = '';
      driver_name = '';
      imei = '';
      date = '';
      vehicles = [];
    }

    // else{
    //
    // }
    // vehicles = (json['vehicles'] is List && json['vehicles'][0]["weight"] != "no")
    //     ? List<Map<String, dynamic>>.from(json['vehicles'])
    //     : [];
    // vehicles = json['vehicles'];

  }
//

// }
}
void _handleTripClick(BuildContext context, Map<String, dynamic> tripData) {
  String frontImage = tripData['front'] ?? '-';
  String backImage = tripData['back'] ?? '-';
  String weight = tripData['weight'] ?? '-';
  String emptyWeight = tripData['empty_weight'] ?? '-';
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Trip Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Front Image: $frontImage'),
            Text('Back Image: $backImage'),
            Text('Weight: $weight'),
            Text('Empty Weight: $emptyWeight'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}
/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
// class EmployeeDataSource extends DataGridSource {
//   /// Creates the employee data source class with required details.
//   EmployeeDataSource({required List<Employee> employeeData}) {
//     _employeeData = employeeData
//         .map<DataGridRow>((e) => DataGridRow(cells: [
//       // DataGridCell<dynamic>(columnName: 'vehicle_no', value: e.vehicle_no),
//       // DataGridCell<dynamic>(columnName: 'imei', value: e.imei),
//       // DataGridCell<dynamic>(
//       //     columnName: 'date', value: e.date),
//       DataGridCell<dynamic>(columnName: 'driver_name', value: e.driver_name),
//       DataGridCell<dynamic>(columnName: 'vehicles', value: e.vehicles),
//     ]))
//         .toList();
//   }
class EmployeeDataSource extends DataGridSource {
  final BuildContext context;
  // int currentRowIndex = -1;
  // int? clickedRowIndex;
  // int? clickedCellIndex;
  EmployeeDataSource({required this.context,required List<Employee> employeeData}) {
    _employeeData = employeeData.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<dynamic>(columnName: 'vehicle_no', value: e.vehicle_no),
      // DataGridCell<List<Map<String, dynamic>>>(
      //     columnName: 'trip', value: e.vehicles.map((en) => en as Map<String, dynamic>).toList()),

      // DataGridCell<dynamic>(
      //     columnName: 'trip',
      //     value: {
      //       'front': e.vehicles.map((v) => v['front']).toList(),
      //       'left': e.vehicles.map((v) => v['left']).toList(),
      //       'right': e.vehicles.map((v) => v['right']).toList(),
      //       'back': e.vehicles.map((v) => v['back']).toList(),
      //       'trip': e.vehicles.map((v) => v['trip']).toList(),
      //     }),
      DataGridCell<dynamic>(columnName: 'trip', value: e.vehicles.map((v) => v['trip']).toList()),
      DataGridCell<dynamic>(columnName: 'weight', value: e.vehicles.map((v) => v['weight']).toList()),

      DataGridCell<dynamic>(columnName: 'Net.wt', value: e.vehicles.map((v) => v["weight"]!="no"?(int.parse(v['weight'])- int.parse(v['empty_weight'])).toString():0).toList()),
      // DataGridCell<dynamic>(columnName: 'empty_weight', value: e.vehicles.map((v) => v['empty_weight']).toList().join('\n')),
    ])).toList();
  }
  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

 List arr=[];
  @override
  DataGridRowAdapter buildRow(DataGridRow row,) {

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'trip') {
          print(("cell${cell.value}"));
          final  tripList = cell.value;
          return ListView.builder(
            itemCount: tripList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _handleTripClick(context, tripList[index]);
                },
                child: Text(tripList[index]['trip'] ?? '-'),
              );
            },
          );
        }
        return Text(cell.value.toString());
      }).toList(),
    );
  }
  // DataGridRowAdapter buildRow(DataGridRow row) {
  //   return DataGridRowAdapter(
  //     cells: row.getCells().map<Widget>((cell) {
  //       if (cell.columnName == 'trip') {
  //         print(("cell${cell.value}"));
  //         final List<Map<String, dynamic>> tripList = cell.value;
  //         return ListView.builder(
  //           itemCount: tripList.length,
  //           itemBuilder: (context, index) {
  //             return GestureDetector(
  //               onTap: () {
  //                 _handleTripClick(context, tripList[index]);
  //               },
  //               child: Text(tripList[index]['trip'] ?? '-'),
  //             );
  //           },
  //         );
  //       }
  //       return Text(cell.value.toString());
  //     }).toList(),
  //   );
  // }
  // void _showTripDetailsDialog(Map<String, List<String>> tripData) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Trip Details'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.max,
  //
  //         children: [
  //
  //           _buildTripItems('Front', tripData['front'] ?? []),
  //           _buildTripItems('Left', tripData['left'] ?? []),
  //          _buildTripItems('Right', tripData['right'] ?? []),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: Text('Close'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildTripItems(String label, List<String> items) {
    print("label${label}");
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        SizedBox(height: 4),
        Container(
          height: 102, // 14 being the text size
          width: 200,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  items[index],
                  style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}
class CustomColumnSizer extends ColumnSizer {
  @override
  double computeCellHeight(GridColumn column, DataGridRow row,
      Object? cellValue, TextStyle textStyle) {
    // if (column.columnName == 'trip') {
    //
    // } else if (column.columnName == 'weight'||column.columnName == 'Net.wt') {
    //   cellValue =
    //       NumberFormat.simpleCurrency(decimalDigits: 0).format(cellValue);
    // }
//     print("cell${cellValue}");
// print("height${super.computeCellHeight(column, row, cellValue, textStyle)}");
    return super.computeCellHeight(column, row, cellValue, textStyle);
  }
}
