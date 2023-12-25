import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui';

import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_plus/dropdown_plus.dart';
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

class Creport extends StatefulWidget {
  final String user;
  final String pass;
  final String main;
  final String logo;
  final String mcname;
  final String type;
  final String mcc;
  const Creport(
      {super.key,
      required this.user,
      required this.pass,
      required this.main,
      required this.logo,
      required this.mcname,
      required this.type,
      required this.mcc});

  @override
  State<Creport> createState() => _CreportState();
}

String? selectedValue;
bool track = false;
List<Employee> employees = [];
late GlobalKey<SfDataGridState> _key;

class _CreportState extends State<Creport> {
  DateTime? startDate;
  DateTime? endDate;
  bool load = true;
  bool pdf = false;
  bool isNextRowVisible = false;
  bool times = false;
  late List<dynamic> data = [];
  double totalNetWeight = 0.0;
  int totalNetcost = 0;
  int toggle = 0;
  late List<GridColumn> columns;
  final List<String> items = [
    'Weight',
    'Weight With Cost',
  ];
  TimeOfDay _fromTime = TimeOfDay.now();
  TimeOfDay _toTime = TimeOfDay.now();
  late ValueNotifier<DateTime> _fromDateNotifier;
  late ValueNotifier<DateTime> _toDateNotifier;
  var mccname;
  final List<String> itemtime = ['ALL', '6AM-6PM', '6PM-6AM', 'Custom Time'];
  final List<String> cate = ['ALL'];
  List<String> typp = ['ALL'];
  String selectedValuetime = "Select Time";
  String selectedValuecat = "Select Category";
  String selectedValuetype = "ALL";
  String dropdownValue = "ALL";

  void initState() {
    DateTime now = DateTime.now();
    _fromTime = TimeOfDay.now();
    _toTime = TimeOfDay.now();
    _fromDateNotifier = ValueNotifier<DateTime>(now);
    _toDateNotifier = ValueNotifier<DateTime>(now);

    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = now;

    startDate = firstDayOfMonth;
    endDate = lastDayOfMonth;
    selectedValue = items[0];
    _initializeColumns();

    selectedValuetime = itemtime[0];
    selectedValuecat = cate[0];
    _key = GlobalKey();
    // _updateColumns();
    fetchAndReturnImageData();
    print('start ${firstDayOfMonth}  ${lastDayOfMonth}');
    if (widget.mcname == 'ALL') {
      mccname = widget.mcc;
    } else {
      mccname = widget.mcname;
    }
    getvehicle();
    getreport();
  }

  _initializeColumns() {
    print(track);
    columns = [
      // Your other GridColumns
      GridColumn(
          columnName: '#',
          width: 30,
          label: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border(
                left: BorderSide(
                    color: Colors.white, width: 1.0), // Add left border
                // right: BorderSide(color: Colors.white, width: 1.0), // Add right border
              )),
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
                left: BorderSide(
                    color: Colors.white, width: 1.0), // Add left border
                // right: BorderSide(color: Colors.white, width: 1.0), // Add right border
              )),
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
                left: BorderSide(
                    color: Colors.white, width: 1.0), // Add left border
                // right: BorderSide(color: Colors.white, width: 1.0), // Add right border
              )),
              child: Text(
                'Trips',
                style: TextStyle(color: Colors.white),
              ))),
      GridColumn(
          columnName: 'gro.wt',
          label: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border(
                left: BorderSide(
                    color: Colors.white, width: 1.0), // Add left border
                // right: BorderSide(color: Colors.white, width: 1.0), // Add right border
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
                  border: Border(
                left: BorderSide(
                    color: Colors.white, width: 1.0), // Add left border
                // right: BorderSide(color: Colors.white, width: 1.0), // Add right border
              )),
              child: Text(
                'Net.wt',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white),
              )))
    ];
    if (track) {
      columns.add(
        GridColumn(
          columnName: 'cost',
          label: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.white, width: 1.0),
              ),
            ),
            child: Text(
              'Cost',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }
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

  getreport() async {
    setState(() {
      load = true;
    });
    totalNetWeight = 0.0;
    totalNetcost = 0;
    List<String> outputList = mccname.split(',');

    String output = outputList.map((item) => "'$item'").join(',');
    String from = DateFormat('yyyy-MM-dd').format(startDate!);
    String to = DateFormat('yyyy-MM-dd').format(endDate!);
    String url;
    var map;
    if (widget.main.toUpperCase() == "MMC") {
      map = {
        "action": "chartdatanew",
        "district": "ALL",
        "from": '${from} 00:00:00',
        "imei": "ALL",
        "over": "Consolided Report",
        "panch": "ALL",
        "subzone": "ALL",
        "category": selectedValuecat,
        "vehicle_type": selectedValuetype,
        "timeflag": selectedValuetime,
        "to": '${to} 23:59:59',
        "fromtime": selectedValuetime == "ALL"
            ? " 00:00:00"
            : selectedValuetime == "6AM-6PM"
                ? " 06:00:00"
                : selectedValuetime == "6PM-6AM"
                    ? " 18:00:00"
                    : selectedValuetime == "Custom Time"
                        ? " ${formatTimeOfDay(_fromTime)}"
                        : " 00:00:00",
        "totime": selectedValuetime == "ALL"
            ? " 23:59:59"
            : selectedValuetime == "6AM-6PM"
                ? " 18:00:00"
                : selectedValuetime == "6PM-6AM"
                    ? " 06:00:00"
                    : selectedValuetime == "Custom Time"
                        ? " ${formatTimeOfDay(_toTime)}"
                        : " 23:59:59",
        "username": widget.main,
        "mcc": mccname,
      };
      url = "http://dev.igps.io/aws_madurai/api/report_api.php";
    } else {
      map = {
        "action": "chartdata",
        "district": "ALL",
        "from": '${from} 00:00:00',
        "imei": "ALL",
        "over": "Consolided Report",
        "panch": "ALL",
        "subzone": "ALL",
        "to": '${to} 23:59:59',
        "username": widget.main,
        "mcc": mccname,
      };
      url = "http://dev.igps.io/aws_madurai/api/report_api.php";
      // url = "http://dev.igps.io/avadi_new/api/report_api.php";
    }
    // print(map);
    try {
      var response = await http.post(Uri.parse(url), body: jsonEncode(map));
      print("dsdsadad${map}");
      if (response.statusCode == 200) {
        // var result = response.body;
        setState(() {
          load = false;
        });
        // print(response.body);
        if (response.body == null ||
            response.body == "" ||
            response.body == "null") {
          data = [];
          // setState(() {
          //   load=false;
          // });
        } else {
          data = jsonDecode(response.body);
        }
        final List<Employee> dummyData =
            data.map((model) => Employee.fromJson(model)).toList();
        for (int s1 = 0; s1 < data.length; s1++) {
          var obj = data[s1];
          totalNetWeight = totalNetWeight + int.parse(obj["waste_weight"]);
          if (selectedValue == "Weight With Cost") {
            totalNetcost = totalNetcost + int.parse(obj["totalcost"]);
          }
        }

        // if (dummyData.isNotEmpty) {
        setState(() {
          print("Dummy Data Length: ${dummyData.length}");
          employees = dummyData;
          print("ggg : ${employees}");
          print("setState called with finaldata size ${employees.length}");

          // columns.removeWhere((column) => column.columnName == 'cost');
        });
        // _initializeColumns();
        // } else {
        //
        // }
      }
      print(employees.length);
    } catch (e) {
      print(e);
    }
    print(load);
  }

  @override
  void dispose() {
    // Dispose the notifiers when not in use
    _fromDateNotifier.dispose();
    _toDateNotifier.dispose();
    super.dispose();
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat("HH:mm:ss"); // Use any format you need
    return format.format(dt);
  }

  Future<void> exportDataGridToPdf(imageBytes) async {
    print("ddsfdsfdfds");
    setState(() {
      pdf = true;
    });
    // totalNetWeight=0.0;
    PdfDocument document = _key.currentState!.exportToPdfDocument(
      headerFooterExport:
          (DataGridPdfHeaderFooterExportDetails headerFooterExport) {
        print(headerFooterExport);

        final double width = headerFooterExport.pdfPage.getClientSize().width;
        final PdfPageTemplateElement header =
            PdfPageTemplateElement(Rect.fromLTWH(0, 0, width, 65));
        final PdfBitmap image = PdfBitmap(imageBytes);
        header.graphics.drawString(
          '${widget.user == "tuty" ? "Thoothukudi" : widget.user.capitalize()} Automatic Weighing System Monitoring Report\n                        ${mccname.contains('ALL') ? 'ALL' : mccname} - (${DateFormat('dd/MM/yy').format(startDate!)}-${DateFormat('dd/MM/yy').format(endDate!)})\n',
          PdfStandardFont(PdfFontFamily.helvetica, 13,
              style: PdfFontStyle.bold),
          bounds: const Rect.fromLTWH(100, 1, 400, 60),
        );
        if (selectedValue == "Weight With Cost") {
          header.graphics.drawString(
            // 'Total Net Weight: $ttweight\nTotal Gross Weight: $totalgroWeight',
            'Total Net Weight: ${(totalNetWeight / 1000).toInt()}(Tons)',
            PdfStandardFont(PdfFontFamily.helvetica, 13,
                style: PdfFontStyle.bold),
            bounds: const Rect.fromLTWH(
                10, 33, 300, 60), // Position adjusted to top-left corner
          );

          header.graphics.drawString(
            // 'Total Net Weight: $ttweight\nTotal Gross Weight: $totalgroWeight',
            'Total Net Cost: Rs.${(dataformater1(totalNetcost.toString()))}',
            PdfStandardFont(PdfFontFamily.helvetica, 13,
                style: PdfFontStyle.bold),
            bounds: const Rect.fromLTWH(
                10, 50, 300, 60), // Position adjusted to top-left corner
          );
          if (image != null) {
            // Debug: Draw a rectangle

            header.graphics.drawImage(image, Rect.fromLTWH(460, 5, 50, 60));
          } else {
            print("Image is null");
          }
        } else {
          header.graphics.drawString(
            // 'Total Net Weight: $ttweight\nTotal Gross Weight: $totalgroWeight',
            'Total Net Weight: ${(totalNetWeight / 1000).toInt()}(Tons)',
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
        }
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
        } else if (details.columnName == "date" && details.cellValue != null) {
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
        } else if (details.columnName == "net.wt" &&
            details.cellValue != null) {
          final cellValue = details.cellValue!;
          // Determine the type of details.cellValue
          details.pdfCell.value = cellValue;
          details.pdfCell.style.textBrush = PdfBrushes.black;
          details.pdfCell.style.stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle,
          );
        } else {
          if (selectedValue == "Weight With Cost") {
            if (details.columnName == "cost" && details.cellValue != null) {
              final cellValue = details.cellValue!;
              // Determine the type of details.cellValue
              details.pdfCell.value = cellValue;
              details.pdfCell.style.textBrush = PdfBrushes.black;
              details.pdfCell.style.stringFormat = PdfStringFormat(
                alignment: PdfTextAlignment.center,
                lineAlignment: PdfVerticalAlignment.middle,
              );
            }
          }
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
        '${widget.main == "tuty" ? "Thoothukudi" : widget.main.capitalize()} AWS Consolidated Report(${DateFormat("dd-MM-yyyy hh:mm:ss").format(startDate!)}).pdf');
    setState(() {
      pdf = false;
    });
    document.dispose();
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

  Widget _buildTimePickerTile(BuildContext context, bool isFrom, String label) {
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
                _buildTimePickerTile(context, true, 'From'),
                _buildTimePickerTile(context, false, 'To'),
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
                  getreport();
                  // print("frommm${_toDate}");
                  // _selectedDate = _fromDate;  // Ensure this is the intended logic
                  // getEmployeeData(_selectedDate, widget.mcc);
                });
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
        appBar: AppBar(
          centerTitle: true,
          title: Center(
              child: Text(widget.main == "tuty"
                  ? 'Consolidated Report-(${mccname.contains('ALL') ? 'ALL' : mccname})'
                  : 'Consolidated Report')),
          actions: [
            IconButton(
              onPressed: exportDataGridToPdf1,
              icon: Image.asset("assets/pdf.png"),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(children: [
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
                    Divider(
                      thickness: 0.5,
                    ),
                    // const SizedBox(height: 5.0),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      height: 30,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
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
                                              color:
                                                  Theme.of(context).hintColor,
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
                                              if (selectedValue ==
                                                  "Weight With Cost") {
                                                track = true;
                                                _initializeColumns();
                                              } else {
                                                track = false;
                                                _initializeColumns();
                                              }
                                            });
                                            // getreport();
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
                        SizedBox(
                          width: 50,
                        ),
                        CircleAvatar(
                          child: IconButton(
                              onPressed: () {
                                showCustomDateRangePicker(
                                  context,
                                  dismissible: true,
                                  minimumDate: DateTime.now()
                                      .subtract(const Duration(days: 360)),
                                  maximumDate: DateTime.now()
                                      .add(const Duration(days: 0)),
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
                              },
                              icon: Icon(Icons.date_range)),
                          // radius: 0.5,
                        ),
                        const SizedBox(width: 10.0),
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
                    SizedBox(
                      height: 8,
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
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
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
                                      value: selectedValuetime,
                                      onChanged: (String? value) {
                                        setState(() {
                                          selectedValuetime = value as String;
                                          if (selectedValuetime ==
                                              "Custom Time") {
                                            _showCustomTimeDialog(context);
                                          } else {
                                            getreport();
                                          }
                                        });
                                      },
                                      buttonHeight: 40,
                                      buttonWidth: 120,
                                      itemHeight: 40,
                                      icon: Transform.translate(
                                        offset: Offset(-8,
                                            0), // Adjust the position of the icon
                                        child: Icon(Icons.arrow_drop_down,
                                            size:
                                                20), // Adjust the size of the icon
                                      ),
                                    ),
                                  ))
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
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.34,
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
                                          .map((item) =>
                                              DropdownMenuItem<String>(
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
                                          getreport();

                                          // isNextRowVisible = false;
                                        });
                                      },
                                      buttonHeight: 40,
                                      buttonWidth:
                                          MediaQuery.of(context).size.width *
                                              0.2,
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
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                height:
                                    MediaQuery.of(context).size.height * 0.041,

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
                                            getreport();
                                            // getEmployeeData(
                                            //     _selectedDate, widget.mcc);
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
                                              10,
                                              -10,
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
                                              getreport();
                                            });
                                          }
                                        },
                                        items: typp
                                            .map<DropdownMenuItem<String>>(
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
                      height: 8,
                    ),
                    load
                        ? SizedBox.shrink()
                        : selectedValue == "Weight With Cost"
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.05,
                                  ),
                                  Text(
                                    "Weight Per Kg:₹4",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.07,
                                  ),
                                  Text(
                                    "Total Cost:₹${dataformater1(totalNetcost.toString())}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  )
                                ],
                              )
                            : SizedBox.shrink(),
                    SizedBox(
                      height: 15.0,
                    ),
                    load
                        ? Container(
                            height: MediaQuery.of(context).size.height * 0.65,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(child: CircularProgressIndicator()),
                              ],
                            ),
                          )
                        : employees.length > 0
                            ? SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Container(
                                  height:
                                  MediaQuery.of(context).size.height * 0.67,
                                  child: SfDataGridTheme(
                                    data: SfDataGridThemeData(
                                        gridLineColor: Colors.black26,
                                        gridLineStrokeWidth: 1.0,
                                        headerColor: const Color(0xff009889),
                                        sortIconColor: Colors.white),
                                    // Add other theming properties here
                                    child: SfDataGrid(
                                        source: EmployeeDataSource(
                                            employees: employees,
                                            context: context,
                                            track: track),
                                        key: _key,
                                        columnWidthMode: ColumnWidthMode.fill,
                                        rowHeight: 50,
                                        headerRowHeight: 30,
                                        gridLinesVisibility:
                                            GridLinesVisibility.both,
                                        allowSorting: true,
                                        // allowMultiColumnSorting:selectedValue=="Trip wise"?false:true,
                                        // Show both horizontal and vertical grid lines

                                        columns: columns),
                                  ),
                                ),
                              )
                            : Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.60,
                                child: Center(
                                    child: Text(
                                  "No Data",
                                  style: TextStyle(fontSize: 20.0),
                                )))
                  ],
                ),
              ]),
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
        ));
  }
}

class EmployeeDataSource extends DataGridSource {
  late final List<Employee> employees;
  bool track;
  final BuildContext context;
  Map<int, double> rowHeights = {};
  int currentRow = 0;

  EmployeeDataSource(
      {required this.employees, required this.context, required this.track}) {
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
// Create the base set of cells that are always present
      List<DataGridCell> cells = [
        DataGridCell<int>(columnName: '#', value: index + 1),
        DataGridCell<String>(
            columnName: 'date', value: dateformater(e.dt.toString())),
        DataGridCell<String>(columnName: 'trip', value: e.trip.toString()),
        DataGridCell<String>(
            columnName: 'gro.wt', value: dataformater1(e.weight.toString())),
        DataGridCell<String>(
            columnName: 'net.wt',
            value: dataformater1(e.waste_weight.toString())),
      ];

      // Only add the 'net.wt' cell if selectedValue == "Weight With Cost"

      if (track) {
        cells.add(DataGridCell<String>(
            columnName: 'cost', value: e.totalcost.toString()));
      }

      // Return the row with the conditionally included cells
      return DataGridRow(cells: cells);
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

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

dateformater(String dt) {
  // print(dt);
  if (dt == null || dt.isEmpty || dt == "null") {
    return "NA";
  } else {
    DateTime fromdate =
        DateTime.parse(DateFormat('yyyy-MM-dd').parse(dt).toString());
    String parsedfromdate = DateFormat("dd-MM-yy").format(fromdate);
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
  final dynamic totalcost;
  final dynamic weight_perkg;

  Employee({
    required this.dt,
    required this.empty_weight,
    required this.weight,
    required this.waste_weight,
    required this.total_ton,
    required this.trip,
    required this.totalcost,
    required this.weight_perkg,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      dt: json['dt'],
      empty_weight: json['empty_weight'],
      weight: json['weight'],
      waste_weight: json['waste_weight'],
      total_ton: json['total_ton'],
      trip: json['trip'],
      totalcost: json['totalcost'],
      weight_perkg: json['weight_perkg'],
    );
  }
}
