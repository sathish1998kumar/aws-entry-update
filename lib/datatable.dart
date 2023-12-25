import 'dart:convert';
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

class _dataState extends State<data> {
  var _inputFormat = DateFormat('dd-MM-yyyy');
  var _selectedDate = DateTime.now();
  List<Sathish_Class> finaldata = <Sathish_Class>[];
  late EmployeeDataSource employeeDataSource;
  @override
  void initState() {

    super.initState();
    getdata(_selectedDate);
  }
  getdata(_selectedDate) async {

    var map = {
      "action": "select_rf",
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
          final List<Sathish_Class> dummyData = list.map((model) => Sathish_Class.fromJson(model)).toList();

          if(dummyData.isNotEmpty) {
            setState(() {
              print("Dummy Data Length: ${dummyData.length}");
              finaldata = dummyData;
              print("ggg : ${finaldata}");
              employeeDataSource = EmployeeDataSource(finaldata: finaldata);
              print("setState called with finaldata size ${finaldata.length}");
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
    employeeDataSource = EmployeeDataSource(finaldata: finaldata);
    return Scaffold(
      appBar: AppBar(
        title: Text("Datatable"),
      ),
      body:finaldata.isEmpty?CircularProgressIndicator():Container(
        width: MediaQuery.of(context).size.width,
        child: SfDataGrid(
          source: employeeDataSource,
          columns: [
            GridColumn(
                columnName: 'imei',
                label: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerRight,
                    child: Text(
                      'imei',
                      overflow: TextOverflow.ellipsis,
                    ))),
            GridColumn(
                columnName: 'vehicle_no',
                label: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'vehicle_no',
                      overflow: TextOverflow.ellipsis,
                    ))),
            GridColumn(
                columnName: 'date',
                label: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'date',
                      overflow: TextOverflow.ellipsis,
                    ))),
            GridColumn(
                columnName: 'driver_name',
                label: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerRight,
                    child: Text(
                      'driver_name',
                      overflow: TextOverflow.ellipsis,
                    ))),
          ],
        ),
      ),
    );
  }

}
class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource({required this.finaldata});
  final List<Sathish_Class> finaldata;

  @override
  List<Object?> get dataSource => finaldata;

  @override
  DataGridRow getDataGridRow(int index) {
    print('DataGridRow for index $index is called.');
    final Sathish_Class data = finaldata[index];
    // print("hii");
    print('Data at index $index: $data');
    return DataGridRow(cells: [
      DataGridCell<dynamic>(columnName: 'imei', value: data.imei),
      DataGridCell<dynamic>(columnName: 'vehicle_no', value: data.vehicle_no),
      DataGridCell<dynamic>(columnName: 'date', value: data.date),
      DataGridCell<dynamic>(columnName: 'driver_name', value: data.driver_name),
    ]);
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    print('BuildRow is called for row: $row');
    return DataGridRowAdapter(
      cells: row.getCells().map((e) {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text(e.value.toString()),
        );
      }).toList(),
    );
  }
}

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
