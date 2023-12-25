import 'dart:convert';
import 'dart:ffi';

import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'helper/save_file_mobile_desktop.dart'
if (dart.library.html) 'helper/save_file_web.dart' as helper;
class Ccost extends StatefulWidget {
  final String user;
  final String pass;
  final String main;
  final String logo;
  const Ccost({super.key, required this.user, required this.pass, required this.main, required this.logo});

  @override
  State<Ccost> createState() => _CcostState();
}
List<Employee> employees = [];
late GlobalKey<SfDataGridState> _key;
class _CcostState extends State<Ccost> {
  DateTime? startDate;
  DateTime? endDate;
  bool load=true;
  late List<dynamic> data = [];
  double totalNetWeight = 0.0;
  void initState() {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = now;
    startDate=firstDayOfMonth;
    endDate=lastDayOfMonth;
    _key = GlobalKey();
    print('start ${firstDayOfMonth}  ${lastDayOfMonth}');
    getreport();
  }
  getreport() async {
    setState(() {
      load=true;
    });
    String from = DateFormat('yyyy-MM-dd').format(startDate!);
    String to = DateFormat('yyyy-MM-dd').format(endDate!);
    var map = {
      "action": "chartdata",
      "district": "ALL",
      "from": '${from} 00:00:00',
      "imei": "ALL",
      "over": "Consolided Report",
      "panch": "ALL",
      "subzone": "ALL",
      "to": '${to} 23:59:59',
      "username": widget.main
    };
    print(map);
    String url = "http://dev.igps.io/avadi_new/api/report_api.php";
    try {
      var response = await http.post(Uri.parse(url), body: jsonEncode(map));
      if (response.statusCode == 200) {
        // var result = response.body;

        print(response.body);
        if(response.body==null ||response.body==""||response.body=="null") {
          data = [];
          // setState(() {
          //   load=false;
          // });
        }else{
          data = jsonDecode(response.body);

        }
        final List<Employee> dummyData =
        data.map((model) => Employee.fromJson(model)).toList();
        for (int s1 = 0; s1 < data.length; s1++) {
          var obj = data[s1];
          totalNetWeight = totalNetWeight + int.parse(obj["waste_weight"]);
        }

        // if (dummyData.isNotEmpty) {
        setState(() {
          print("Dummy Data Length: ${dummyData.length}");
          employees = dummyData;
          print("ggg : ${employees}");
          print("setState called with finaldata size ${employees.length}");

        });
        // } else {
        //
        // }
        setState(() {
          load=false;
        });
      }
      print(employees.length);
    } catch (e) {
      print(e);
    }
    print(load);
  }
  Future<void> exportDataGridToPdf() async {

    // totalNetWeight=0.0;
    PdfDocument document = _key.currentState!.exportToPdfDocument(

      headerFooterExport:
          (DataGridPdfHeaderFooterExportDetails headerFooterExport) {


        print(headerFooterExport);


        final double width = headerFooterExport.pdfPage.getClientSize().width;
        final PdfPageTemplateElement header =
        PdfPageTemplateElement(Rect.fromLTWH(0, 0, width, 65));

        header.graphics.drawString(
          'Automatic Weigh System Monitoring Report\n                            \n',
          PdfStandardFont(PdfFontFamily.helvetica, 13,
              style: PdfFontStyle.bold),
          bounds: const Rect.fromLTWH(130, 3, 300, 60),
        );
        header.graphics.drawString(
          // 'Total Net Weight: $ttweight\nTotal Gross Weight: $totalgroWeight',
          'Total Net Weight: ${(totalNetWeight / 1000).toInt()}(Tons)',
          PdfStandardFont(PdfFontFamily.helvetica, 13,
              style: PdfFontStyle.bold),
          bounds: const Rect.fromLTWH(
              10, 40, 300, 60), // Position adjusted to top-left corner
        );
        headerFooterExport.pdfDocumentTemplate.top = header;

        // totalNetWeight = 0.0;
        // totalgroWeight = 0.0;



      },
      fitAllColumnsInOnePage: true,
      canRepeatHeaders: false,
      cellExport: (details) {
        if (details.columnName == "trip" && details.cellValue != null) {
          // Determine the type of details.cellValue
          final cellValue = details.cellValue!;

          details.pdfCell.value = cellValue;

          details.pdfCell.style.textBrush = PdfBrushes.black;
          details.pdfCell.style.stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle,
          );
        }
        else if (details.columnName == "date" && details.cellValue != null) {
          // Determine the type of details.cellValue
          final cellValue = details.cellValue!;
          // print(cellValue);

          details.pdfCell.value = (cellValue);
          details.pdfCell.style.textBrush = PdfBrushes.black;
          details.pdfCell.style.stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle,
          );

        } else if (details.columnName == "gro.wt" &&
            details.cellValue != null) {
          // Determine the type of details.cellValue
          final cellValue = details.cellValue!;
          details.pdfCell.value = cellValue;
          details.pdfCell.style.textBrush = PdfBrushes.black;
          details.pdfCell.style.stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle,
          );

        }
        else if (details.columnName == "net.wt" &&
            details.cellValue != null) {
          final cellValue = details.cellValue!;
          // Determine the type of details.cellValue
          details.pdfCell.value = cellValue;
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
        'Aws Report.pdf');
    document.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Center(child: const Text('AWS Consolidated Report')),
          actions: [
            IconButton(
              onPressed: exportDataGridToPdf,
              icon: Image.asset("assets/pdf.png"),
            ),
          ],
        ),
        body:Column(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Choose a date Range',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.black),
              ),
              Divider(thickness: 0.5,),
              // const SizedBox(height: 5.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    child: IconButton(onPressed: (){
                      showCustomDateRangePicker(
                        context,
                        dismissible: true,
                        minimumDate: DateTime.now().subtract(const Duration(days: 360)),
                        maximumDate: DateTime.now().add(const Duration(days: 0)),
                        endDate: endDate,
                        startDate: startDate,
                        backgroundColor: Colors.white,
                        primaryColor: Colors.blue,
                        onApplyClick: (start, end) {
                          setState(() {
                            endDate = end;
                            startDate = start;
                            print('start ${startDate}');
                            print('end ${endDate}');
                          });
                          getreport();
                        },
                        onCancelClick: () {
                          setState(() {
                            endDate = null;
                            startDate = null;
                          });
                        },
                      );
                    }, icon: Icon(Icons.date_range)),
                    // radius: 0.5,
                  ),
                  const SizedBox(width: 3.0),
                  Text(
                    '${startDate != null ? DateFormat("dd, MMM").format(startDate!) : '-'} - ${endDate != null ? DateFormat("dd, MMM").format(endDate!) : '-'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(width: 4.0),

                ],
              ),
              SizedBox(height: 20.0,),
              load?Center(child: CircularProgressIndicator()):employees.length>0 ?Container(
                height: MediaQuery.of(context).size.height * 0.72,
                child: SfDataGridTheme(
                  data: SfDataGridThemeData(
                      gridLineColor: Colors.black26,
                      gridLineStrokeWidth: 1.0,
                      headerColor: const Color(0xff009889),
                      sortIconColor: Colors.white),
                  // Add other theming properties here
                  child: SfDataGrid(
                    source: EmployeeDataSource(
                        employees: employees, context: context),
                    key: _key,
                    columnWidthMode: ColumnWidthMode.fill,
                    rowHeight:50,
                    headerRowHeight: 30,
                    gridLinesVisibility: GridLinesVisibility.both,
                    allowSorting:true,
                    // allowMultiColumnSorting:selectedValue=="Trip wise"?false:true,
                    // Show both horizontal and vertical grid lines

                    columns: [
                      GridColumn(
                          columnName: '#',
                          width: 30,
                          label: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: Colors.white, width: 1.0), // Add left border
                                    // right: BorderSide(color: Colors.white, width: 1.0), // Add right border
                                  )
                              ),
                              child: Text(
                                '#',
                                style: TextStyle(color: Colors.white),
                              ))),
                      GridColumn(
                          columnName: 'date',
                          label: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: Colors.white, width: 1.0), // Add left border
                                    // right: BorderSide(color: Colors.white, width: 1.0), // Add right border
                                  )
                              ),
                              child: Text(
                                'Date',
                                style: TextStyle(color: Colors.white),
                              ))),
                      GridColumn(
                          columnName: 'trip',
                          label: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: Colors.white, width: 1.0), // Add left border
                                    // right: BorderSide(color: Colors.white, width: 1.0), // Add right border
                                  )
                              ),
                              child: Text(
                                'Trips',
                                style: TextStyle(color: Colors.white),
                              ))),
                      GridColumn(
                          columnName: 'gro.wt',
                          label: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border:Border(
                                    left: BorderSide(color: Colors.white, width: 1.0), // Add left border
                                    // right: BorderSide(color: Colors.white, width: 1.0), // Add right border
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
                                  border: Border(
                                    left: BorderSide(color: Colors.white, width: 1.0), // Add left border
                                    // right: BorderSide(color: Colors.white, width: 1.0), // Add right border
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
              ):Container(
                  height: MediaQuery.of(context).size.height * 0.60,
                  child: Center(child: Text("No Data",style: TextStyle(fontSize: 20.0),)))
            ],
          ),
        ]));
  }
}

class EmployeeDataSource extends DataGridSource {
  late final List<Employee> employees;
  final BuildContext context;
  Map<int, double> rowHeights = {};
  int currentRow = 0;

  EmployeeDataSource({required this.employees, required this.context}) {
    // void updateEmployees(List<Employee> newEmployees) {
    //   employees = newEmployees;
    //   notifyListeners();
    // }
  }

  @override
  List<DataGridRow> get rows {

    return employees.asMap().entries.map<DataGridRow>((entry) {
      int index = entry.key;
      var e = entry.value;

      return DataGridRow(cells: [
        DataGridCell<int>(columnName: '#', value: index + 1),
        DataGridCell<String>(columnName: 'date', value:dateformater(e.dt.toString())),
        DataGridCell<String>(columnName: 'trip', value:e.trip.toString()),
        DataGridCell<String>(
            columnName: 'gro.wt', value: dataformater1(e.weight.toString())),
        DataGridCell<String>(
            columnName: 'net.wt',
            value: dataformater1(e.waste_weight.toString())),
      ]);
    }).toList();
  }

  // @override
  // int get rowCount => employees.length;


  @override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex,
      String summaryValue) {
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Text(summaryValue),
    );
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    // print("emm${row}");
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        // print(cell.value.toString().length);
        // print(cell.value.toString());
        // print("length${cell}");
        // if(employees.isNotEmpty){
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

        return Center(
          // print(cell.value)
            child: Text(cell.value.toString()));


      }).toList(),
    );
  }


}

dateformater(String dt) {
  // print(dt);
  if (dt == null || dt.isEmpty || dt == "null") {
    return "NA";
  } else {
    DateTime fromdate =
    DateTime.parse(DateFormat('yyyy-MM-dd').parse(dt).toString());
    String parsedfromdate = DateFormat("dd-MM-yyyy").format(fromdate);
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

class Employee {
  final dynamic dt;
  final dynamic empty_weight;
  final dynamic weight;
  final dynamic waste_weight;
  final dynamic total_ton;
  final dynamic trip;


  Employee({
    required this.dt,
    required this.empty_weight,
    required this.weight,
    required this.waste_weight,
    required this.total_ton,
    required this.trip,

  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      dt: json['dt'],
      empty_weight: json['empty_weight'],
      weight: json['weight'],
      waste_weight: json['waste_weight'],
      total_ton: json['total_ton'],
      trip: json['trip'],
    );
  }
}