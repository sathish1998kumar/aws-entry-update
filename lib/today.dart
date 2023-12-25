import 'dart:convert';
import 'dart:math';
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
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'chart.dart';
import 'consolidated.dart';
import 'login.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'helper/save_file_mobile_desktop.dart'
if (dart.library.html) 'helper/save_file_web.dart' as helper;
import 'package:flutter/material.dart';

import 'menulist.dart';

class MyHomePage extends StatefulWidget {
  final String user;
  final String pass;
  final String main;
  final String logo;
  final String mcc;
  final String type;
  MyHomePage({super.key, required this.user, required this.pass, required this.main, required this.logo,required this.mcc,required this.type});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

var imagePaths = [];
List<Employee> employees = [];
String? selectedValue;
bool noflag = false;
late GlobalKey<SfDataGridState> _key;
var mcname ="ALL";
var users="";
class _MyHomePageState extends State<MyHomePage> {
  bool abcd = false;
  late EmployeeDataSource employeeDataSource;
  final List<String> items = [
    'Time wise',
    'Trip wise',

  ];
  Color getcol=Colors.green;
  // final CustomColumnSizer _customColumnSizer = CustomColumnSizer();
  //  var data = [];
  late List<dynamic> data = [];
  var datas = [];
  int sumover = 0;
  bool pdf=false;
  bool mflag=false;
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

  var _selectedDate = DateTime.now();
  int wwwto = 0;
  int www1 = 0;
  int www2 = 0;
  int www3 = 0;
  int www4 = 0;
  bool search = false;
  double totalNetWeight = 0.0;
  double totalgroWeight = 0.0;
  bool isSearchVisible = false;
  var mccs;



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
    selectedValue = items[0];

    _key = GlobalKey();
    fetchAndReturnImageData();
    getEmployeeData(_selectedDate,widget.mcc).then((fetchedEmployees) {
      setState(() {
        employees = fetchedEmployees;
        users=widget.main;
        // if (employees.isNotEmpty) {
        //   rowHeight = calculateRowHeight(employees);
        // } else {
        //   rowHeight = 100.0; // Default row height if no employees
        // }
        if(widget.type=="admin") {
          if (widget.mcc.contains('ALL')) {
            mcname = "ALL";
          } else {
            mcname = widget.mcc;
          }
        }
        else{
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
  double calculateRowHeight(List<Employee> employees) {
    double minHeight = 50.0; // Minimum height for a row
    double maxHeight = 0.0;

    for (var employee in employees) {
      int numberOfVehicles = employee.vehicles.length; // Assuming 'vehicles' is a List in your Employee object

      // Dynamically setting base height based on the number of vehicles
      double baseHeight = minHeight + (numberOfVehicles * 10.0); // For example, add 10.0 for each vehicle to the base height

      // Extra height per vehicle
      double extraHeightPerVehicle = 5.0; // Extra height for each vehicle

      double calculatedHeight = baseHeight + (numberOfVehicles * extraHeightPerVehicle);
      maxHeight = max(maxHeight, calculatedHeight);
    }

    return maxHeight;
  }

  Future<List<Employee>> getEmployeeData(_selectedDate,mcc) async {


    var map = {};
    String url = '';
    var act='';
    List<Employee> newEmployees = [];

    List<String> outputList = mcc.split(',');

    String output = outputList.map((item) => "'$item'").join(',');
    print("bindex ---> ${mcc}");
    if(widget.main.toUpperCase()=="MMC"){
      act="datawise10";
    }
    else{
      if (selectedValue == 'Trip wise') {
        act="select_mcc";
      }
      else{
        act="datewise1";
      }

    }
    // final CustomColumnSizer _customColumnSizer = CustomColumnSizer();
    if (selectedValue == 'Trip wise') {
      map = {
        "action": act,
        "cat":"trip",
        "district": "ALL",
        "imei": "ALL",
        "over": "Daily Report",
        "panch": "ALL",
        "subzone": "ALL",
        "username": widget.main,
        "mcc":mcc,
        "from": DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 00:00:00',
        "to": DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 23:59:59',
      };
      url = "http://dev.igps.io/swms/api/getrf_api.php";
    } else {
      map = {
        "action":act,
        "cat":"time",
        "district": "ALL",
        "imei": "ALL",
        "over": "Daily Report",
        "panch": "ALL",
        "subzone": "ALL",
        "mcc":mcc,
        "username": widget.main,
        "from": DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 00:00:00',
        "to": DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 23:59:59',
      };
      url = "http://dev.igps.io/swms/api/getrf_api.php";
    }
    print(map);

    var response = await http.post(Uri.parse(url), body: (jsonEncode(map)));
    // print("hhhi --->${response.body}");
    if (response.statusCode == 200) {
      setState(() {
        bindex=1;
        getcol=Colors.green;
        tripcount = 0;

        tripnot = 0;
        tripcomp = 0;
        ttweight = 0;
        wwwto = 0;
        www1 = 0;
        www2 = 0;
        www3 = 0;
        www4 = 0;
        data = [];
        datas = [];

        // print("fgfd");
        if(response.body==""|| response.body==null || response.body=="NULL" || response.body=="null"|| response.body=="[]"){
          data=[];
          noflag=true;
        }
        else{
          data = jsonDecode(response.body);
        }
        // data1 = jsonDecode(response.body);
        // print(data);
        for (int s1 = 0; s1 < data.length; s1++) {
          var obj = data[s1];

          if (selectedValue == "Trip wise") {
            var vehi = obj["vehicles"];
            if (obj['vehicles'][0]['weight'] != "no") {
              datas.add(data[s1]);
            }
            int total = int.parse(vehi[vehi.length - 1]["total"]);
            // if(vehi.length==1){
            //   print("hi");
            //          rowHeight=20.0;
            //        }
            //         if(vehi.length==2){
            //          rowHeight==50.0;
            //        }
            //         if(vehi.length==3){
            //          rowHeight==100.0;
            //        }
            //        if(vehi.length==4){
            //          rowHeight==150.0;
            //        }

            if (total >= 0) {
              www4++;
            }
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
              if ((obj1["weight"] != "no")) {
                sumover += int.parse(obj1["weight"]);
                if (int.parse(obj1["weight"]) <
                    int.parse(obj1["empty_weight"])|| int.parse(obj1["empty_weight"])==0) {
                  ttweight = ttweight + 0;
                } else {
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
          else {
            setState(() {
              tripcount++;
              print("sss${obj["waste_weight"]}");
              sumover += int.parse(obj["weight"]);
              ttweight = ttweight + int.parse(obj["waste_weight"]);
              int waste_wt = int.parse(obj["waste_weight"]);
              print(waste_wt);
              if (waste_wt >= 0) {
                www4++;
              }
              if (waste_wt <= 2000) {
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
          order_controler.text.isEmpty? newEmployees =
              data.map((e) => Employee.fromJson(e)).toList(): newEmployees = data
              .where((element) =>
          element['vehicle_no']
              .toLowerCase()
              .contains( order_controler.text.toLowerCase()) ||
              element['vehicle_no']
                  .toString()
                  .contains( order_controler.text))
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
    // List<Employee> dummySearchList = employees;

    // if((maindata['waste_weight'].toLowerCase()).contains(value)){
    //   dummyListData.add(maindata);
    // }

    //   setState(() {
    //     employees = data1.map((e) => Employee.fromJson(e)).toList();
    //     // maindata.clear();
    //     // datas1.clear();
    //     // maindata.addAll(dummyListData);
    //     // datas1.addAll(dummyListData);
    //   });
    //
    //
    //
    // setState(() {});
    // } catch (e) {
    //   print(e);
    // }
    return newEmployees;
  }

  // void updateData(DateTime newDate) async {
  //   List<Employee> newEmployees = await getEmployeeData(newDate);
  //   setState(() {
  //
  //     employeeDataSource.updateEmployees(employees);
  //   });
  // }
  onItemChanged(String value) {
    // print("hi");
    print(value);
    setState(() {
      ttweight=0;
      tripcount=0;
    });

    List<dynamic> data1 = [];
    // List<Employee> newEmployees1 = [];
    // // newEmployees1=employees;
    // print(newEmployees1);
    if(bindex==1){
      getcol=Colors.green;
    }
    else if(bindex==2){
      getcol=Colors.purple;
    }
    else if(bindex==3){
      getcol=Colors.blue;
    }
    else if(bindex==4){
      getcol=Colors.yellow.shade800;
    }
    else if(bindex==5){
      getcol=Colors.red;
    }
    employees = data.map((e) => Employee.fromJson(e)).toList();

    List<Employee> dummySearchList = employees;
    // dummySearchList=employees;
    // datas1.clear();
    if (value.isNotEmpty) {
      dummySearchList.forEach((main) {
        setState(() {
          if (selectedValue == "Time wise") {
            // print("fii${main.toString()}");
            int waste_wt = int.parse(main.waste_weight);
            // print(waste_wt);
            if (value == "<2") {
              if (waste_wt <= 2000) {
                setState(() {
                  data1.add({
                    "waste_weight": main.waste_weight,
                    "empty_weight": main.empty_weight,
                    "weight": main.weight,
                    "trip": main.trip,
                    "entry_dt": main.entry_dt,
                    "vehicle_no": main.vehicle_no,
                    "front": main.front,
                    "back": main.back,
                    "right": main.right,
                    "left": main.left,
                    "driver_name": main.driver_name,
                    "username": main.username,
                    "mcc": main.mcc
                  });
                  ttweight=ttweight+int.parse(main.waste_weight);
                  tripcount++;
                  // print("data${data1}");
                });
              }
              noflag = true;
              //
            } else if (value == "2-4") {
              if (waste_wt > 2000 && waste_wt <= 4000) {
                setState(() {
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
                    "driver_name": main.driver_name,
                    "empty_weight": main.empty_weight,
                    "username": main.username,
                    "mcc": main.mcc
                  });
                  ttweight=ttweight+int.parse(main.waste_weight);
                  tripcount++;
                  // print("data${data1}");
                });
              }
              noflag = true;
            } else if (value == "4-5") {
              if (waste_wt > 4000 && waste_wt <= 5000) {
                setState(() {
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
                    "driver_name": main.driver_name,
                    "empty_weight": main.empty_weight,
                    "username": main.username,
                    "mcc": main.mcc
                  });
                  ttweight=ttweight+int.parse(main.waste_weight);
                  tripcount++;
                  // print("data${data1}");
                });
              }
              noflag = true;
            } else if (value == "5>") {
              if (waste_wt > 5000) {
                setState(() {
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
                    "driver_name": main.driver_name,
                    "empty_weight": main.empty_weight,
                    "username": main.username,
                    "mcc": main.mcc
                  });
                  ttweight=ttweight+int.parse(main.waste_weight);
                  tripcount++;
                  // print("data${data1}");
                });
              }
              noflag = true;
            } else if (value == "ALL") {
              setState(() {
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
                  "driver_name": main.driver_name,
                  "empty_weight": main.empty_weight,
                  "username": main.username,
                  "mcc": main.mcc
                });
                ttweight=ttweight+int.parse(main.waste_weight);
                tripcount++;
                // print("data${data1}");
              });
            }
          } else {
            for (int s = 0; s < main.vehicles.length; s++) {
              var weight = main.vehicles[s]['weight'];
              var waste_weight = main.vehicles[s]['waste_weight'];
              var total =
              int.parse(main.vehicles[main.vehicles.length - 1]['total']);
              // var total = int.parse(weight) - int.parse(waste_weight);
              // total+= int.parse(waste_weight);
              // print('filter main ff ${total}---> ${value}');
              if (value == "<2") {
                if (total <= 2000) {
                  // datas1.add(maindata);
                  if (s == 0) {
                    data1.add({
                      "vehicles": main.vehicles,
                      "vehicle_no": main.vehicle_no,
                      "username": main.username,
                      "mcc": main.mcc
                    });
                    ttweight = ttweight + total;
                    tripcount++;
                  }
                }
                noflag = true;
              } else if (value == "2-4") {
                if (total > 2000 && total <= 4000) {
                  if (s == 0) {
                    // print('okkkkkk  ${main}');
                    data1.add({
                      "vehicles": main.vehicles,
                      "vehicle_no": main.vehicle_no,
                      "username": main.username,
                      "mcc": main.mcc
                    });
                    ttweight=ttweight+total;
                    tripcount++;
                    // datas1.add(maindata);
                  }
                  print("find${data1.length}");
                }
                noflag = true;
              } else if (value == "4-5") {
                if (total > 4000 && total <= 5000) {
                  if (s == 0) {
                    data1.add({
                      "vehicles": main.vehicles,
                      "vehicle_no": main.vehicle_no,
                      "username": main.username,
                      "mcc": main.mcc
                    });
                    ttweight=ttweight+total;
                    tripcount++;
                    // datas1.add(maindata);
                  }
                }
                noflag = true;
              } else if (value == "5>") {
                if (total > 5000) {
                  if (s == 0) {
                    data1.add({
                      "vehicles": main.vehicles,
                      "vehicle_no": main.vehicle_no,
                      "username": main.username,
                      "mcc": main.mcc
                    });
                    ttweight=ttweight+total;
                    tripcount++;
                    // datas1.add(maindata);
                  }
                }
                noflag = true;
              } else if (value == "ALL") {
                if (s == 0) {
                  data1.add({
                    "vehicles": main.vehicles,
                    "vehicle_no": main.vehicle_no,
                    "username": main.username,
                    "mcc": main.mcc
                  });
                  ttweight=ttweight+total;
                  tripcount++;
                  // datas1.add(maindata);
                }
                noflag = true;

              }
            }
            // print('data1  ${datas1}');
          }
        });
        // if((maindata['waste_weight'].toLowerCase()).contains(value)){
        //   dummyListData.add(maindata);
        // }
      });
      setState(() {
        employees = data1.map((e) => Employee.fromJson(e)).toList();
        print("emm${employees}");
        // maindata.clear();
        // datas1.clear();
        // maindata.addAll(dummyListData);
        // datas1.addAll(dummyListData);
      });
      return;
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

  // void drawVerticalLine(PdfGraphics graphics, double x, double yTop, double yBottom) {
  //   PdfPen pen = PdfPen(PdfColor(0, 0, 0));
  //   graphics.drawLine(pen, Offset(x, yTop), Offset(x, yBottom));
  // }
  // double totalNetWeight = 0.0;
  // double totalgroWeight = 0.0;
  // Future<Uint8List?> exportDataGridToPdf1() async {
  //   final Uint8List? imageBytes = await _loadImageBytes('http://dev.igps.io/avadi_new/assets/images/${widget.logo}');
  //
  //   if (imageBytes != null) {
  //     print('Image bytes length: ${imageBytes?.length ?? 'null'}');
  //     exportDataGridToPdf(imageBytes);
  //
  //   }
  //
  //
  // }
  int pageNumber = 0;
  Future<void> exportDataGridToPdf(imageBytes) async {
    print("ffd");
    pageNumber=0;
    setState(() {
      pdf=true;
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
          if(widget.main=="avadi") {
            header.graphics.drawString(
              '${widget.main.capitalize()} Automatic Weighing System Monitoring Report\n                            (${DateFormat(
                  "dd-MM-yyyy").format(_selectedDate)})\n',
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(100, 1, 350, 60),
            );
          }else{
            header.graphics.drawString(
              '${widget.user=="tuty"?"Thoothukudi":widget.user.capitalize()} Automatic Weighing System Monitoring Report\n                     ${mcname} -(${DateFormat(
                  "dd-MM-yyyy").format(_selectedDate)})\n',
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
          String horizontalLine = "\n" + "_" * 18 + "\n";
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
                    : "$timeEntry\n${"_" * 18}";
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
                  : "$timeEntry\n${"_" * 18}";
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
                final weight = NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(int.parse(entry.value));
                return index == tripNames.length - 1
                    ? "$weight" // Don't add a horizontal line for the last entry
                    : "$weight\n${"_" * 18}";
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
              final weight = NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(int.parse(entry.value));
              return index == tripNames.length - 1
                  ? "$weight" // Don't add a horizontal line for the last entry
                  : "$weight\n${"_" * 18}";
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
                final diff =NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(int.parse(entry.value));
                return index == weightDiffs.length - 1
                    ? diff // Don't add a horizontal line for the last entry
                    : "$diff\n${"_" * 18}";
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
              final diff = NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(int.parse(entry.value));
              return index == weightDiffs.length - 1
                  ? diff // Don't add a horizontal line for the last entry
                  : "$diff\n${"_" * 18}";
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
        '${widget.user=="tuty"?"Thoothukudi":widget.user.capitalize()} Aws Report(${DateFormat("dd-MM-yyyy hh:mm:ss").format(_selectedDate)}).pdf');

    document.dispose();
    setState(() {
      pdf=false;
    });
  }
  Future<void>refresh()async{
    setState(() {
      getEmployeeData(_selectedDate,widget.mcc);
    });

  }
  Future<Uint8List?> fetchAndReturnImageData() async {
    final String url = 'http://dev.igps.io/avadi_new/assets/images/${widget.logo}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return null;
  }

  Future<void> exportDataGridToPdf1() async {
    setState(() {
      pdf=true;
    });
    final Uint8List? imageData = await fetchAndReturnImageData();
    if (imageData != null) {
      await exportDataGridToPdf(imageData);
    }
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
        title:  (widget.main=="tuty"|| widget.main=="mmc")?Text("AWS  (${mcname})"):Text("AWS"),

        actions: [
          Row(
            children: [
              IconButton(
                onPressed: exportDataGridToPdf1,
                icon: Image.asset("assets/pdf.png"),
              ),
              search
                  ?Container(
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(10.0),
                //   border: Border.all(
                //       color: Colors.red,
                //       style: BorderStyle.solid,
                //       width: 0.80),
                // ),
                padding: const EdgeInsets.fromLTRB(0, 0, 5.0, 0),
                width: MediaQuery.of(context).size.width*0.25,
                height: MediaQuery.of(context).size.height*0.05,
                color: Colors.white,

                child: TextFormField(
                  decoration:InputDecoration(
                      labelText: isSearchVisible==false?'Search':"",
                      labelStyle: TextStyle(color: Colors.black)),

                  controller: order_controler,
                  onTap: (){
                    isSearchVisible = true;
                  },
                  onChanged: (value) {
                    searchText = value;
                    // Update the filtered data based on search query
                    setState(() {
                      if (value.isEmpty) {
                        employees =
                            data.map((e) => Employee.fromJson(e)).toList();
                        bindex=1;
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
                        if(employees.isEmpty){
                          noflag=true;
                        }
                        print("go${employees}");
                        // datas1=filteredData;
                      }
                    });
                  },
                ),
              ):SizedBox.shrink(),
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
                          if(bindex==1){
                            onItemChanged("ALL");
                          }
                          else if(bindex==2){
                            onItemChanged("<2");
                          }
                          else if(bindex==3){
                            onItemChanged("2-4");
                          }
                          else if(bindex==4){
                            onItemChanged("4-5");
                          }
                          else if(bindex==5){
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
                accountName: (widget.main=="tuty" || widget.main.toUpperCase()=="MMC")?Text(
                  '${widget.main=="tuty"?"Thoothukudi":widget.main.capitalize()}(${mcname.contains('ALL')?'ALL':mcname})',
                  style: const TextStyle(fontSize: 20),
                ):Text(
                  '${widget.main.toUpperCase()}',
                  style: const TextStyle(fontSize: 20),
                ),
                accountEmail: null,
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Image.network(
                    "http://dev.igps.io/avadi_new/assets/images/${widget.logo}",width: 65,height: 65,
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
                      builder: (context) =>
                          MyHomePage(user: widget.user, pass: widget.pass,main: widget.main,logo:widget.logo, mcc:widget.mcc, type: widget.type,),
                    ),
                  );
                },
              ),
              Divider(
                height: 1.2,
                color: Colors.black38,
                thickness: 1,
              ),
              widget.main=="tuty"?ExpansionTile(
                title: Text("Mcc"),
                leading: Icon(Icons.person), //add icon
                childrenPadding: EdgeInsets.only(left:60), //children padding
                children: [
                  // ListTile(
                  //   title: Text("ALL"),
                  //   onTap: (){
                  //     getEmployeeData(_selectedDate,widget.mcc);
                  //     Navigator.pop(context);
                  //     setState(() {
                  //       mcname="ALL";
                  //     });
                  //   },
                  // ),
                  for(int i=0;i<(widget.mcc.split(',')).length;i++)...[
                    ListTile(
                      title: Text("${widget.mcc.split(',')[i]}"),
                      onTap: (){
                        if(widget.mcc.split(',')[i]=="ALL"){
                          getEmployeeData(_selectedDate,widget.mcc);
                        }
                        getEmployeeData(_selectedDate,widget.mcc.split(',')[i]);
                        Navigator.pop(context);
                        setState(() {
                          mcname=widget.mcc.split(',')[i];
                        });
                      },
                    )
                  ]
                ],
              ):Container(),
              widget.main=="tuty"?Divider(
                height: 1.2,
                color: Colors.black38,
                thickness: 1,
              ):Container(),
              ListTile(
                title: const Text('Chart'),
                leading: const Icon(Icons.auto_graph),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Dchart(user: widget.user, pass: widget.pass,main: widget.main,logo:widget.logo,mcc:widget.mcc,mcname:mcname,type: widget.type,)
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
                title: const Text('Consolidated Report'),
                leading: const Icon(Icons.padding_outlined),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Creport(user: widget.user, pass: widget.pass,main: widget.main,logo:widget.logo,mcc:widget.mcc,mcname:mcname,type: widget.type,),
                    ),
                  );
                },
              ),
              Divider(
                height: 1.2,
                color: Colors.black38,
                thickness: 1,
              ),
              widget.type=="admin"?ListTile(
                title: const Text('Back'),
                leading: const Icon(Icons.arrow_back_outlined),
                onTap: () async {
                  SharedPreferences preferences = await SharedPreferences.getInstance();
                  var username = preferences.getString('username') ?? "";
                  var password = preferences.getString('password') ?? "";
                  var main = preferences.getString('main_user') ?? "";
                  var logo = preferences.getString('logo') ?? "";
                  var mcc = preferences.getString('mcc') ?? "";
                  var type = preferences.getString('type') ?? "";
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) =>menu(user: username, pass: password,main: main,logo:logo,mcc:mcc,type:type,),),
                        (Route<dynamic> route) => false,
                  );
                },
              ):Container(),
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
                                await prefrences.remove("main_user");
                                await prefrences.remove("mcc");
                                await prefrences.remove("type");
                                await prefrences.remove("logo");
                                // await prefrences.remove("location");
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                // SizedBox(
                //   height: MediaQuery.of(context).size.height * 0.01,
                // ),
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
                                      value: selectedValue,
                                      onChanged: (String? value) {
                                        setState(() {
                                          selectedValue = value as String;
                                          print(selectedValue);
                                          noflag = false;
                                          bindex = 1;
                                          getcol=Colors.green;
                                        });
                                        getEmployeeData(_selectedDate,widget.mcc);
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
                    // Container(
                    //   width: MediaQuery.of(context).size.width * 0.35,
                    //   height: MediaQuery.of(context).size.height * 0.04,
                    //   child: TextField(
                    //     decoration: InputDecoration(
                    //       labelText: 'Search',
                    //       prefixIcon: Icon(Icons.search),
                    //       enabledBorder: OutlineInputBorder(
                    //         borderSide: BorderSide(
                    //             width: 1, color: Colors.black38), //<-- SEE HERE
                    //       ),
                    //       floatingLabelBehavior: searchText.isEmpty
                    //           ? FloatingLabelBehavior.auto
                    //           : FloatingLabelBehavior.never,
                    //     ),
                    //     onChanged: (value) {
                    //       searchText = value;
                    //       // Update the filtered data based on search query
                    //       setState(() {
                    //         if (value.isEmpty) {
                    //           employees =
                    //               data.map((e) => Employee.fromJson(e)).toList();
                    //           // datas1=filteredData;
                    //         } else {
                    //           employees = data
                    //               .where((element) =>
                    //                   element['vehicle_no']
                    //                       .toLowerCase()
                    //                       .contains(value.toLowerCase()) ||
                    //                   element['vehicle_no']
                    //                       .toString()
                    //                       .contains(value))
                    //               .map((e) => Employee.fromJson(e))
                    //               .toList();
                    //
                    //           // print("go${filteredData}");
                    //           // datas1=filteredData;
                    //         }
                    //       });
                    //     },
                    //   ),
                    // ),
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
                                    onTap: (){
                                      setState(() {
                                        _selectedDate = DateTime(
                                            _selectedDate.year,
                                            _selectedDate.month,
                                            _selectedDate.day - 1);
                                        // table(imei,_selectedDate);
                                        if(mcname=="ALL") {
                                          getEmployeeData(_selectedDate, widget.mcc);
                                        }else{
                                          getEmployeeData(_selectedDate, mcname);
                                        }
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
                                    if(mcname=="ALL") {
                                      getEmployeeData(_selectedDate, widget.mcc);
                                    }else{
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
                                child:GestureDetector(
                                    onTap: (){
                                      DateTime now = DateTime.now();
                                      DateTime todayMidnight = DateTime(now.year, now.month, now.day);
                                      DateTime selectedDateMidnight = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
                                      if (selectedDateMidnight.isBefore(todayMidnight)) {
                                        setState(() {
                                          _selectedDate = DateTime(
                                              _selectedDate.year,
                                              _selectedDate.month,
                                              _selectedDate.day + 1);
                                          print("plus ${mcname}");
                                          if (mcname == "ALL") {
                                            getEmployeeData(
                                                _selectedDate,
                                                widget.mcc);
                                          } else {
                                            getEmployeeData(
                                                _selectedDate, mcname);
                                          }
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
                                child: Text("ALL\n(${www4.toString()})")),
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
                              onItemChanged("<2");
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            side: bindex == 2
                                ? BorderSide(width: 3, color: Colors.lightBlueAccent)
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
                                bindex = 3;
                                onItemChanged("2-4");
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                side: bindex == 3
                                    ? BorderSide(
                                    width: 3, color: Colors.lightBlueAccent)
                                    : BorderSide(width: 3, color: Colors.grey),
                                primary: Colors.blue), // Background color
                            child: Text(" 2 - 4Ton\n     (${www1.toString()})")),
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
                                onItemChanged("4-5");
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                side: bindex == 4
                                    ? BorderSide(
                                    width: 3, color: Colors.lightBlueAccent)
                                    : BorderSide(width: 3, color: Colors.grey),
                                primary: Colors.yellow[800]), // Background color
                            child: Text(" 4 - 5Ton\n      (${www2.toString()})")),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.065,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                bindex = 5;
                                onItemChanged("5>");
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                side: bindex == 5
                                    ? BorderSide(
                                    width: 3, color: Colors.lightBlueAccent)
                                    : BorderSide(width: 3, color: Colors.grey),
                                primary: Colors.red), // Background color
                            child: Text(" 5Ton>\n    (${www3.toString()})")),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.01,
                ),
                RefreshIndicator(
                  onRefresh: refresh,
                  child: employees.isNotEmpty?Container(
                    height: MediaQuery.of(context).size.height * 0.65,
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
                        rowHeight: selectedValue == "Trip wise" ? rowHeight : 50,
                        headerRowHeight: 30,
                        gridLinesVisibility: GridLinesVisibility.both,
                        allowSorting: selectedValue == "Trip wise" ? false : true,
                        columns: [
                          GridColumn(
                              columnName: '#',
                              width: selectedValue == "Trip wise" ? 30 : 30,
                              label: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: selectedValue=="Trip wise"?Border(
                                        left: BorderSide(color: Colors.grey, width: 1.0), // Add left border
                                        right: BorderSide(color: Colors.white, width: 1.0), // Add right border/ Add right border
                                      ):Border(
                                        left: BorderSide(color: Colors.white, width: 1.0), // Add left border
                                        // right: BorderSide(color: Colors.white, width: 1.0), // Add right border
                                      )
                                  ),
                                  child: Text(
                                    '#',
                                    style: TextStyle(color: Colors.white),
                                  ))),
                          GridColumn(
                              columnName: 'vehicle_no',
                              label: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: selectedValue=="Trip wise"?Border(
                                        left: BorderSide(color: Colors.grey, width: 1.0), // Add left border
                                        right: BorderSide(color: Colors.white, width: 1.0), // Add right border/ Add right border
                                      ):Border(
                                        left: BorderSide(color: Colors.white, width: 1.0), // Add left border
                                      )
                                  ),
                                  child: Text(
                                    'Vehicle',
                                    style: TextStyle(color: Colors.white),
                                  ))),
                          GridColumn(
                              columnName: 'trip',
                              label: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: selectedValue=="Trip wise"?Border(
                                        left: BorderSide(color: Colors.grey, width: 1.0), // Add left border
                                        right: BorderSide(color: Colors.white, width: 1.0), // Add right border/ Add right border
                                      ):Border(
                                        left: BorderSide(color: Colors.white, width: 1.0), // Add left border
                                      )
                                  ),
                                  child: Text(
                                    'Trip',
                                    style: TextStyle(color: Colors.white),
                                  ))),
                          GridColumn(
                              columnName: 'time',
                              label: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: selectedValue=="Trip wise"?Border(
                                        left: BorderSide(color: Colors.grey, width: 1.0), // Add left border
                                        right: BorderSide(color: Colors.white, width: 1.0), // Add right border/ Add right border
                                      ):Border(
                                        left: BorderSide(color: Colors.white, width: 1.0), // Add left border
                                      )
                                  ),
                                  child: Text(
                                    'Time',
                                    style: TextStyle(color: Colors.white),
                                  ))),
                          GridColumn(
                              columnName: 'gro.wt',
                              label: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: selectedValue=="Trip wise"?Border(
                                        left: BorderSide(color: Colors.grey, width: 1.0), // Add left border
                                        right: BorderSide(color: Colors.white, width: 1.0), // Add right border/ Add right border
                                      ):Border(
                                        left: BorderSide(color: Colors.white, width: 1.0), // Add left border
                                      )
                                  ),
                                  child: Text(
                                    'Gro.wt',
                                    style: TextStyle(color: Colors.white),
                                  ))),
                          GridColumn(
                              columnName: 'net.wt',
                              label: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: selectedValue=="Trip wise"?Border(
                                        left: BorderSide(color: Colors.grey, width: 1.0), // Add left border
                                        right: BorderSide(color: Colors.white, width: 1.0), // Add right border/ Add right border
                                      ):Border(
                                        left: BorderSide(color: Colors.white, width: 1.0), // Add left border
                                      )
                                  ),
                                  child: Text(
                                    'Net.wt',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white),
                                  ))),
                        ],

                      ),
                    ),
                  ):(noflag==true)?Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: Text("No Data",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),),
                      ],
                    ),
                  ):Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          ),
          pdf==true?Center(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(

                child: CircularProgressIndicator(),
              ),
            ),
          ):Container()
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

  EmployeeDataSource({required this.employees, required this.context}) {
  }

  @override
  List<DataGridRow> get rows {
    var sortedEmployees = employees.length; // Create a copy if necessary


    return employees.asMap().entries.map<DataGridRow>((entry) {
      int index = entry.key;
      var e = entry.value;
      return DataGridRow(cells: [
        if (selectedValue == "Trip wise") ...[
          DataGridCell<int>(columnName: '#', value: sortedEmployees -index),
          DataGridCell<String>(columnName: 'vehicle_no', value: e.vehicle_no),
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
          DataGridCell<int>(columnName: '#', value: sortedEmployees -index),
          DataGridCell<String>(columnName: 'vehicle_no', value: e.vehicle_no),
          DataGridCell<dynamic>(
              columnName: 'trip', value: {"trip": e.trip, "index": index}),
          DataGridCell<String>(
              columnName: 'time', value: dataformater(e.entry_dt.toString())),
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
                        if(users=="MMC"){
                          _handleTripClicktime(context, tripList[index],
                              tripList[index]["index"], index);
                        }
                        else {
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
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black),
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
                              dataformater(tripList[index]['entry_dt']) ?? '-',
                              style: TextStyle(fontSize: 15),
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
                            (NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(int.parse(tripList[index]['weight']))) ?? '-',
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
                  int weight = int.parse(tripList[index]['weight']);
                  int emptyWeight = int.parse(tripList[index]['empty_weight']);
                  int weightDifference = emptyWeight==0?0:(weight - emptyWeight);
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
                                      (int.parse(tripList[index]['weight']) <= int.parse(tripList[index]['empty_weight']) || int.parse(tripList[index]['empty_weight']) == 0)
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
                    }
                  );
                },
              ),
            );
          }
          return Center(
            // print(cell.value)
              child: Text(formattedText));
        } else {
          if (cell.columnName == 'trip') {
            List<dynamic> resultList = [cell.value];
            print(resultList);
            return GestureDetector(
                onTap: () async {
                  // if()
                  // print(context);
                  if(users=="MMC"){
                    _handleTripClicktime1(context, resultList[0]['index']);
                  }
                  else{
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
          return Center(child: Text(cell.value.toString() ?? "-"));
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
  if(employees[index].username=='avadi'){
    file_name="/files/"+employees[index].username+"/";
  }
  else{
    file_name="/files/"+employees[index].username+"/"+employees[index].mcc+"/";
  }
  String frontImage = file_name+ employees[index].front;
  String backImage = file_name+ employees[index].back;
  String rightImage = file_name+ employees[index].right;
  String leftImage =file_name+ employees[index].left;
  String vehicle = employees[index].vehicle_no ?? '-';
  String driver = employees[index].driver_name ?? '-';
  String weight = employees[index].weight ?? '-';
  String emptyWeight = employees[index].empty_weight ?? '-';
  String trip = employees[index].trip ?? '-';
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation1, animation2) => ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth:double.infinity,
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
            child:
            Column(
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
                        width: MediaQuery.of(context).size.width*0.001,
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: "${vehicle}(${driver})\n"),
                            WidgetSpan(
                              child: Text(
                                "${trip}",
                                style: TextStyle(fontSize: 20, color: Colors.white),
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

                    _showImageDialog(context, 0, imagePaths,"cat");
                  },
                  child: Column(
                    children: [
                      Text("Front",style: TextStyle(fontWeight: FontWeight.bold),),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${frontImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                    _showImageDialog(context, 1, imagePaths,"cat");
                  },
                  child: Column(
                    children: [
                      Text("Back",style: TextStyle(fontWeight: FontWeight.bold),),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${backImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                    _showImageDialog(context, 3, imagePaths,"cat");
                  },
                  child: Column(
                    children: [
                      Text("Left",style: TextStyle(fontWeight: FontWeight.bold),),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${leftImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                    _showImageDialog(context, 2, imagePaths,"cat");
                  },
                  child: Column(
                    children: [
                      Text("Right",style: TextStyle(fontWeight: FontWeight.bold),),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${rightImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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
    barrierLabel:
    'This dialog cannot be dismissed by tapping on the barrier.',
    transitionDuration: Duration(milliseconds: 200),
  );
}

void _handleTripClicktime1(BuildContext context, int index) {
  print(index);
  var file_name;
  if (employees[index].username == 'avadi') {
    file_name = "/files/" + employees[index].username! + "/";
  } else {
    file_name = "/files/" + employees[index].username! + "/" + employees[index].mcc! + "/";
  }
  String frontImage = file_name + employees[index].front!;
  String backImage = file_name + employees[index].back!;
  String rightImage = file_name + employees[index].right!;
  String leftImage = file_name + employees[index].left!;
  String frontImageOut = file_name + (employees[index].front_out??"-");
  String backImageOut = file_name + (employees[index].back_out??"-");
  String rightImageOut = file_name + (employees[index].right_out??"-");
  String leftImageOut = file_name + (employees[index].left_out??"-");
  String vehicle = employees[index].vehicle_no ?? '-';
  String driver = employees[index].driver_name ?? '-';
  String weight = employees[index].weight ?? '-';
  String emptyWeight = employees[index].empty_weight ?? '-';
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
                      width: MediaQuery.of(context).size.width*0.001,
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "${vehicle}(${driver})\n"),
                          WidgetSpan(
                            child: Text(
                              "${trip}",
                              style: TextStyle(fontSize: 20, color: Colors.white),
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
              // SizedBox(height: 5),
              SizedBox(
                height:MediaQuery.of(context).size.height * 0.04, // Adjust the height as needed
                child: TabBar(
                  indicatorColor: Colors.blue,
                  labelColor: Colors.blue, // Color of the text for selected tab
                  unselectedLabelColor: Colors.grey, // Color of the text for unselected tabs
                  labelStyle: TextStyle(fontSize: 18), // Font size for the text
                  tabs: [
                    Tab(text: 'In'),
                    Tab(text: 'Out'),
                  ],
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

                            _showImageDialog(context, 0, imagePaths,"in");
                          },
                          child: Column(
                            children: [
                              Text("Front IN",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImage}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                            _showImageDialog(context, 1, imagePaths,"in");
                          },
                          child: Column(
                            children: [
                              Text("Back IN",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImage}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                            _showImageDialog(context, 3, imagePaths,"in");
                          },
                          child: Column(
                            children: [
                              Text("Left IN",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImage}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                            _showImageDialog(context, 2, imagePaths,"in");
                          },
                          child: Column(
                            children: [
                              Text("Right IN",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImage}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                            _showImageDialog(context, 0, imagePaths,"out");
                          },
                          child: Column(
                            children: [
                              Text("Front OUT",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}');

                            _showImageDialog(context, 1, imagePaths,"out");
                          },
                          child: Column(
                            children: [
                              Text("Back OUT",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}');

                            _showImageDialog(context, 3, imagePaths,"out");
                          },
                          child: Column(
                            children: [
                              Text("Left OUT",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}');

                            _showImageDialog(context, 2, imagePaths,"out");
                          },
                          child: Column(
                            children: [
                              Text("Right OUT",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

void _handleTripClick(BuildContext context, Map<String, dynamic> tripData, index, index1) {
  print(employees[index].vehicles);
  var file_name;
  if(employees[index].username=='avadi'){
    file_name="/files/"+employees[index].username+"/";
  }
  else{
    file_name="/files/"+employees[index].username+"/"+employees[index].mcc+"/";
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
        maxWidth:double.infinity,
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
                        width: MediaQuery.of(context).size.width*0.001,
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: "${vehicle}(${driver})\n"),
                            WidgetSpan(
                              child: Text(
                                "${trip}",
                                style: TextStyle(fontSize: 20, color: Colors.white),
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

                    _showImageDialog(context, 0, imagePaths,"cat");
                  },
                  child: Column(
                    children: [
                      Text("Front",style: TextStyle(fontWeight: FontWeight.bold),),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${frontImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                    _showImageDialog(context, 1, imagePaths,"cat");
                  },
                  child: Column(
                    children: [
                      Text("Back",style: TextStyle(fontWeight: FontWeight.bold),),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${backImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                    _showImageDialog(context, 3, imagePaths,"cat");
                  },
                  child: Column(
                    children: [
                      Text("Left",style: TextStyle(fontWeight: FontWeight.bold),),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${leftImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                    _showImageDialog(context, 2, imagePaths,"cat");
                  },
                  child: Column(
                    children: [
                      Text("Right",style: TextStyle(fontWeight: FontWeight.bold),),
                      Image.network(
                        'http://dev.igps.io/avadi_new/image.php?path=${rightImage}',
                        height: MediaQuery.of(context).size.height * 0.165,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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
    barrierLabel:
    'This dialog cannot be dismissed by tapping on the barrier.',
    transitionDuration: Duration(milliseconds: 200),
  );
}
void _handleTripClicktime(BuildContext context, Map<String, dynamic> tripData, index, index1) {
  print(employees[index].vehicles);
  var file_name;
  if(employees[index].username=='avadi'){
    file_name="/files/"+employees[index].username+"/";
  }
  else{
    file_name="/files/"+employees[index].username+"/"+employees[index].mcc+"/";
  }
  String frontImage =
      file_name + employees[index].vehicles[index1]["front"] ?? '-';
  String backImage =
      file_name + employees[index].vehicles[index1]["back"] ?? '-';
  String rightImage =
      file_name + employees[index].vehicles[index1]["right"] ?? '-';
  String leftImage =
      file_name + employees[index].vehicles[index1]["left"] ?? '-';
  String frontImageOut = file_name + (employees[index].vehicles[index1]["front_out"] ?? '-');
  String backImageOut =
      file_name + (employees[index].vehicles[index1]["back_out"] ?? '-');
  String rightImageOut =
      file_name + (employees[index].vehicles[index1]["right_out"] ?? '-');
  String leftImageOut =
      file_name + (employees[index].vehicles[index1]["left_out"] ?? '-');
  String vehicle = employees[index].vehicles[index1]["vehicle_no"] ?? '-';
  String driver = employees[index].vehicles[index1]["driver_name"] ?? '-';
  String weight = employees[index].vehicles[index1]["weight"] ?? '-';
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
                      width: MediaQuery.of(context).size.width*0.001,
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "${vehicle}(${driver})\n"),
                          WidgetSpan(
                            child: Text(
                              "${trip}",
                              style: TextStyle(fontSize: 20, color: Colors.white),
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
              // SizedBox(height: 5),
              SizedBox(
                height:MediaQuery.of(context).size.height * 0.04, // Adjust the height as needed
                child: TabBar(
                  indicatorColor: Colors.blue,
                  labelColor: Colors.blue, // Color of the text for selected tab
                  unselectedLabelColor: Colors.grey, // Color of the text for unselected tabs
                  labelStyle: TextStyle(fontSize: 18), // Font size for the text
                  tabs: [
                    Tab(text: 'In'),
                    Tab(text: 'Out'),
                  ],
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

                            _showImageDialog(context, 0, imagePaths,"in");
                          },
                          child: Column(
                            children: [
                              Text("Front IN",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImage}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                            _showImageDialog(context, 1, imagePaths,"in");
                          },
                          child: Column(
                            children: [
                              Text("Back IN",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImage}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                            _showImageDialog(context, 3, imagePaths,"in");
                          },
                          child: Column(
                            children: [
                              Text("Left IN",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImage}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                            _showImageDialog(context, 2, imagePaths,"in");
                          },
                          child: Column(
                            children: [
                              Text("Right IN",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImage}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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

                            _showImageDialog(context, 0, imagePaths,"out");
                          },
                          child: Column(
                            children: [
                              Text("Front OUT",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}');

                            _showImageDialog(context, 1, imagePaths,"out");
                          },
                          child: Column(
                            children: [
                              Text("Back OUT",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}');

                            _showImageDialog(context, 3, imagePaths,"out");
                          },
                          child: Column(
                            children: [
                              Text("Left OUT",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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
                                'http://dev.igps.io/avadi_new/image.php?path=${frontImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${backImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}');
                            imagePaths.add(
                                'http://dev.igps.io/avadi_new/image.php?path=${leftImageOut}');

                            _showImageDialog(context, 2, imagePaths,"out");
                          },
                          child: Column(
                            children: [
                              Text("Right OUT",style: TextStyle(fontWeight: FontWeight.bold),),
                              Image.network(
                                'http://dev.igps.io/avadi_new/image.php?path=${rightImageOut}',
                                height: MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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
void _showImageDialog(BuildContext context, int index, List<dynamic> imagePaths,cat) {
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
    if(cat=="cat") {
      txt = 'Front';
    }
    else if(cat=="in"){
      txt = 'Front IN';
    }
    else{
      txt = 'Front OUT';
    }
  } else if (index == 1) {
    if(cat=="cat") {
      txt = 'Back';
    }
    else if(cat=="in"){
      txt = 'Back IN';
    }
    else{
      txt = 'Back OUT';
    }
  } else if (index == 2) {
    if(cat=="cat") {
      txt = 'Right';
    }
    else if(cat=="in"){
      txt = 'Right IN';
    }
    else{
      txt = 'Right OUT';
    }
  } else {
    if(cat=="cat") {
      txt = 'Left';
    }
    else if(cat=="in"){
      txt = 'Left IN';
    }
    else{
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
                            if(cat=="cat") {
                              txt = 'Front';
                            }
                            else if(cat=="in"){
                              txt = 'Front IN';
                            }
                            else{
                              txt = 'Front OUT';
                            }
                          } else if (currentIndex == 1) {
                            if(cat=="cat") {
                              txt = 'Back';
                            }
                            else if(cat=="in"){
                              txt = 'Back IN';
                            }
                            else{
                              txt = 'Back OUT';
                            }
                          } else if (currentIndex == 2) {
                            if(cat=="cat") {
                              txt = 'Right';
                            }
                            else if(cat=="in"){
                              txt = 'Right IN';
                            }
                            else{
                              txt = 'Right OUT';
                            }
                          } else if (currentIndex == 3) {
                            if(cat=="cat") {
                              txt = 'Left';
                            }
                            else if(cat=="in"){
                              txt = 'Left IN';
                            }
                            else{
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
                            if(cat=="cat") {
                              txt = 'Front';
                            }
                            else if(cat=="in"){
                              txt = 'Front IN';
                            }
                            else{
                              txt = 'Front OUT';
                            }
                          } else if (currentIndex == 1) {
                            if(cat=="cat") {
                              txt = 'Back';
                            }
                            else if(cat=="in"){
                              txt = 'Back IN';
                            }
                            else{
                              txt = 'Back OUT';
                            }
                          } else if (currentIndex == 2) {
                            if(cat=="cat") {
                              txt = 'Right';
                            }
                            else if(cat=="in"){
                              txt = 'Right IN';
                            }
                            else{
                              txt = 'Right OUT';
                            }
                          } else if (currentIndex == 3) {
                            if(cat=="cat") {
                              txt = 'Left';
                            }
                            else if(cat=="in"){
                              txt = 'Left IN';
                            }
                            else{
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
  // print(dt);
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
        vehicles: json["vehicles"] != null
            ? List<Map<String, dynamic>>.from(json['vehicles'])
            : []);
  }
}

