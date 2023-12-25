import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:aws/consolidated.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:http/http.dart' as http;
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:ui' as ui;

class Dchart extends StatefulWidget {
  final String user;
  final String pass;
  final String main;
  final String logo;
  final String mcname;
  final String type;
  final String mcc;
  const Dchart({super.key, required this.user, required this.pass, required this.main,required this.logo,required this.mcname,required this.type,required this.mcc});

  @override
  State<Dchart> createState() => _DchartState();
}
late GlobalKey<SfCartesianChartState> _cartesianChartKey;
class _DchartState extends State<Dchart> {
  late ZoomPanBehavior _zoomPanBehavior;
  List<Employee> employees = <Employee>[];
  DateTime? startDate;
  DateTime? endDate;
  bool cflag=false;
  bool noflag=false;
  int toggle=0;
  var mccname;
  final List<String> itemtime = ['ALL', '6AM-6PM', '6PM-6AM','Custom Time'];
   List<String> cate = ['ALL'];
  List<String> typp = ['ALL'];
  String selectedValuetime = "Select Time";
  String selectedValuecat = "Select Category";
  String selectedValuetype="ALL";
  String dropdownValue="ALL";
  TimeOfDay _fromTime = TimeOfDay.now();
  TimeOfDay _toTime = TimeOfDay.now();
  late ValueNotifier<DateTime> _fromDateNotifier;
  late ValueNotifier<DateTime> _toDateNotifier;
  void initState() {
    _cartesianChartKey = GlobalKey();
    _zoomPanBehavior = ZoomPanBehavior(enablePinching: true, zoomMode: ZoomMode.x,enableDoubleTapZooming: true,);
    super.initState();
    DateTime now = DateTime.now();
    _fromTime = TimeOfDay.now();
    _toTime = TimeOfDay.now();
    _fromDateNotifier = ValueNotifier<DateTime>(now);
    _toDateNotifier = ValueNotifier<DateTime>(now);
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = now;
    startDate=firstDayOfMonth;
    endDate=lastDayOfMonth;
    print('start ${firstDayOfMonth}  ${lastDayOfMonth}');
    if (widget.mcname=='ALL') {
      mccname = widget.mcc;
    } else {
      mccname = widget.mcname;
    }
    selectedValuetime = itemtime[0];
    selectedValuecat = cate[0];
    getvehicle();
    getchartdata();
  }
  var datavehi=[];
  getvehicle() async {
    datavehi=[];
    var map={ "action": "mmcvehicle_type"};
    var  url = "http://dev.igps.io/swms/api/getrf_api.php";
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
    var uniqueVehicleTypes = datavehi.map((item) => item['vehicle_type'].toString()).toSet().toList();
    var uniqueCategories = datavehi.map((item) {
      // Check if category is 'corporation' and replace with 'corp', else use the original value
      return item['cat'] == 'Corporation with GPS' ? 'Corp GPS':item['cat']=="Corporation NO GPS"?'Corp NO GPS' : item['cat'].toString();
    }).toSet().toList();
    typp.addAll(uniqueVehicleTypes);
    cate.addAll(uniqueCategories);
  }
  getchartdata() async {
    employees = [];
    print("mccc---${mccname}");
    List<String> outputList = mccname.split(',');

    String output = outputList.map((item) => "'$item'").join(',');
    String from = DateFormat('yyyy-MM-dd').format(startDate!);
    String to = DateFormat('yyyy-MM-dd').format(endDate!);

    // print(map);
    String url;
    var map;
    if(widget.main.toUpperCase()=="MMC"){
      map = {
        "action": "chartdatanew",
        "district": "ALL",
        "from": '${from} 00:00:00',
        "imei": "ALL",
        "over": "Consolided Report",
        "panch": "ALL",
        "subzone": "ALL",
        "category":selectedValuecat,
        "vehicle_type":selectedValuetype,
        "timeflag":selectedValuetime,
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
            :selectedValuetime == "Custom Time"?" ${formatTimeOfDay(_toTime)}":" 23:59:59",
        "username": widget.main,
        "mcc":mccname,
      };
      url = "http://dev.igps.io/aws_madurai/api/report_api.php";
    }
    else{
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
        "mcc":mccname,
      };
      url = "http://dev.igps.io/avadi_new/api/report_api.php";
      // url = "";
    }
    print(map);
    // try {
    var response = await http.post(Uri.parse(url), body: jsonEncode(map));
    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      final List<Employee> dummyData =
      list.map((model) => Employee.fromJson(model)).toList();
      if (dummyData.isNotEmpty) {
        setState(() {
          noflag=false;
          print("Dummy Data Length: ${dummyData.length}");
          employees = dummyData;
          print("ggg : ${employees}");
          print("setState called with finaldata size ${employees.length}");

        });
      } else {
        noflag=true;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid user!!"),
        ));
      }
      print(employees.length);
    }
  }
  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat("HH:mm:ss"); // Use any format you need
    return format.format(dt);
  }
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
                  getchartdata();
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
  // List<_SalesData> data = [
  //   _SalesData('Jan', 35),
  //   _SalesData('Feb', 28),
  //   _SalesData('Mar', 34),
  //   _SalesData('Apr', 32),
  //   _SalesData('May', 40),
  //   _SalesData('JUN', 62),
  // ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title:  Text(widget.main=="tuty"?'AWS (${widget.mcname})':"AWS"),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding:
              const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
              child: Center(
                child: Column(
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
                                getchartdata();
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
                        SizedBox(
                          width: 70,
                          height: 30,
                          child: ElevatedButton(onPressed: (){
                            if(employees.length>0) {
                              _renderPDF();
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Pdf not Available for No Data "),
                              ));
                            }
                          }, style: ElevatedButton.styleFrom(
                            primary: Colors.green, // Background color
                          ),child: Text('Pdf')),
                        )

                      ],
                    ),
                    SizedBox(height: 8,),
                    SingleChildScrollView(scrollDirection:  Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Schedule",  // Replace with your actual title
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                              Container(
                                  width:MediaQuery.of(context).size.width*0.3,
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
                                            getchartdata();
                                          }
                                        });

                                      },
                                      buttonHeight: 40,
                                      buttonWidth: 120,
                                      itemHeight: 40,
                                      icon: Transform.translate(
                                        offset: Offset(-8, 0), // Adjust the position of the icon
                                        child: Icon(Icons.arrow_drop_down, size: 20), // Adjust the size of the icon
                                      ),
                                    ),
                                  ))
                            ],
                          ),

                          SizedBox(width: MediaQuery.of(context).size.width*0.008,),
                          Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Category",  // Replace with your actual title
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                              Container(
                                  width:MediaQuery.of(context).size.width*0.34,
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
                                          getchartdata();

                                          // isNextRowVisible = false;
                                        });

                                      },
                                      buttonHeight: 40,
                                      buttonWidth: MediaQuery.of(context).size.width * 0.2,
                                      itemHeight: 40,
                                      icon: Transform.translate(
                                        offset: Offset(-8, 0), // Adjust the position of the icon
                                        child: Icon(Icons.arrow_drop_down, size: 20), // Adjust the size of the icon
                                      ),
                                      // icon: Transform.translate(
                                      //   offset: Offset(-20, 0), // Adjust the position of the icon
                                      //   child: Icon(Icons.arrow_drop_down, size: 20), // Adjust the size of the icon
                                      // ),
                                    ),
                                  )),
                            ],
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width*0.008,),
                          Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Type",  // Replace with your actual title
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                height: MediaQuery.of(context).size.height * 0.040,
                                padding: EdgeInsets.fromLTRB(5, 0, 0, 0), // Horzontal padding for inner spacing
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey), // Optional: for visualizing the container boundary
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: toggle == 1
                                    ? TextDropdownFormField(
                                  options: typp,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    suffixIcon: Transform.translate(
                                      offset: Offset(12,
                                        2,), // Adjust offset for left movement
                                      child: Icon(Icons.arrow_drop_down, size: 20),
                                    ),
                                    contentPadding:
                                    EdgeInsets.fromLTRB(0, 0, 0, 0),

                                  ),
                                  dropdownHeight: MediaQuery.of(context).size.height * 0.2,

                                  onChanged: (dynamic value) {
                                    setState(() {
                                      selectedValuetype = value as String;
                                      print(selectedValuetype);
                                      getchartdata();
                                      // getEmployeeData(
                                      //     _selectedDate, widget.mcc);
                                    });
                                  },
                                )

                                    : DropdownButtonFormField<String>(
                                  value: selectedValuetype,
                                  isExpanded: true, // Ensure the dropdown is expanded to fill the container
                                  icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                                  elevation: 10,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    // border: OutlineInputBorder(
                                    //   borderRadius: BorderRadius.all(Radius.circular(10)),
                                    // ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        5, -8,
                                        12,
                                        10), // Padding inside the dropdown
                                    // Padding inside the dropdown
                                  ),
                                  style: TextStyle(color: Colors.black, fontSize: 14), // Font size of the dropdown items
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
                                        getchartdata();

                                      });
                                    }
                                  },
                                  items: typp.map<DropdownMenuItem<String>>((String value) {
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
                  ],
                ),
              ),
            ),
            // FloatingActionButton(
            //   onPressed: () {
            //
            //   },
            //   tooltip: 'choose date Range',
            //   child:
            //       const Icon(Icons.calendar_today_outlined, color: Colors.white),
            // ),
            //Initialize the chart widget
            employees.length>0?SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                height: MediaQuery.of(context).size.height*0.65,
                width: MediaQuery.of(context).size.width*1,
                child: Stack(
                  children: [
                    SfCartesianChart(
                        key: _cartesianChartKey,
                        zoomPanBehavior: _zoomPanBehavior,
                        enableAxisAnimation: true,
                        primaryXAxis: CategoryAxis(
                          title: AxisTitle(text: '- Date -',textStyle: TextStyle(fontSize: 12.0,fontWeight: FontWeight.bold)),
                        ),
                        // primaryYAxis:LogarithmicAxis(
                        //   title: AxisTitle(text: 'Y-Axis title',textStyle: TextStyle(fontSize: 10.0)),
                        //     ),
                        primaryYAxis: NumericAxis(
                          decimalPlaces: 0,
                          rangePadding: ChartRangePadding.none,
                          title: AxisTitle(text: '- Ton (T) -',textStyle: TextStyle(fontSize: 12.0,fontWeight: FontWeight.bold)),
                        ),
                        // Chart title
                        title: ChartTitle(text: 'AWS ${widget.user=="tuty"?"Thoothukudi":widget.user.capitalize()}(${mccname.contains('ALL')?'ALL':mccname}) '),
                        // Enable legend
                        // legend: Legend(isVisible: true),
                        // Enable tooltip
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: cflag?<ChartSeries<Employee, String>>[
                          // Renders column chart
                          ColumnSeries<Employee, String>(
                              dataSource: employees,
                              xValueMapper: (Employee sales, _) => dataformater(sales.dt),
                              yValueMapper: (Employee sales, _) =>
                              int.parse(sales.total_ton) / 1000,
                              name: 'Tons',
                              markerSettings: MarkerSettings(isVisible: true),
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                useSeriesColor: true,
                              )),
                        ]:
                        <ChartSeries<Employee, String>>[
                          LineSeries<Employee, String>(
                              dataSource: employees,
                              xValueMapper: (Employee sales, _) => dataformater(sales.dt),
                              yValueMapper: (Employee sales, _) =>
                              int.parse(sales.total_ton) / 1000,
                              name: 'Tons',
                              markerSettings: MarkerSettings(isVisible: true),
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                useSeriesColor: true,
                              )),

                        ]

                    ),
                    Positioned(
                        top: 10,
                        right: 10,
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: IconButton(onPressed: (){
                                setState(() {
                                  cflag=!cflag;
                                });
                              }, icon: Icon(Icons.swap_horiz)),
                            ),
                            SizedBox(width: 2.0,),
                            CircleAvatar(
                              child: IconButton(onPressed: (){
                                _zoomPanBehavior.reset();
                              }, icon: Icon(Icons.restart_alt)),
                            ),
                          ],
                        )
                    ),
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
            ): Container(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
            // Expanded(
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     //Initialize the spark charts widget
            //     child: SfSparkLineChart.custom(
            //       //Enable the trackball
            //       trackball: SparkChartTrackball(
            //           activationMode: SparkChartActivationMode.tap),
            //       //Enable marker
            //       marker: SparkChartMarker(
            //           displayMode: SparkChartMarkerDisplayMode.all),
            //       //Enable data label
            //       labelDisplayMode: SparkChartLabelDisplayMode.all,
            //       xValueMapper: (int index) => data[index].year,
            //       yValueMapper: (int index) => data[index].sales,
            //       dataCount: 5,
            //     ),
            //   ),
            // )
          ]),
        ));
  }
}

Future<void> _renderPDF() async {
  final List<int> imageBytes = await _readImageData();
  final PdfBitmap bitmap = PdfBitmap(imageBytes);
  final PdfDocument document = PdfDocument();
  document.pageSettings.size =
      Size(bitmap.width.toDouble(), bitmap.height.toDouble());
  final PdfPage page = document.pages.add();
  final Size pageSize = page.getClientSize();
  page.graphics.drawImage(
      bitmap, Rect.fromLTWH(0, 0, pageSize.width, pageSize.height));
  final List<int> bytes = document.saveSync();
  document.dispose();
  //Get external storage directory
  final Directory directory = await getApplicationSupportDirectory();
  //Get directory path
  final String path = directory.path;
  //Create an empty file to write PDF data
  File file = File('$path/Output.pdf');
  //Write PDF bytes data
  await file.writeAsBytes(bytes, flush: true);
  //Open the PDF document in mobile
  OpenFile.open('$path/Output.pdf');
}

Future<List<int>> _readImageData() async {
  final ui.Image data =
  await _cartesianChartKey.currentState!.toImage(pixelRatio: 3.0);
  final ByteData? bytes =
  await data.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
}
// }
// class _SalesData {
//   _SalesData(this.year, this.sales);
//
//   final String year;
//   final double sales;
//   _SalesData(
//       {
//         required this.year,
//         required this.sales,
//       });
//
//
//   _SalesData.fromJson(Map<String, dynamic> json) {
//
//     if (json['vehicles'] is List && json['vehicles'][0]["weight"] != "no") {
//       vehicle_no = json['vehicle_no'] ?? '';
//       driver_name = json['driver_name'] ?? '';
//       imei = json['imei'] ?? '';
//       date = json['date'] ?? '';
//       vehicles = List<Map<String, dynamic>>.from(json['vehicles']);
//     } else {
//       // Initialize to default values or keep them null, based on your class properties
//       vehicle_no = '';
//       driver_name = '';
//       imei = '';
//       date = '';
//       vehicles = [];
//     }
//
//   }
// }

class Employee {
  final dynamic dt;
  final dynamic total_ton;
  Employee({
    required this.dt,
    required this.total_ton,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      dt: json['dt'],
      total_ton: json['total_ton'],
    );
  }
}

dataformater(String dt) {
  // if (dt == "null") {
  //   return "NA";
  // } else {
  DateTime fromdate =
  DateTime.parse(DateFormat('yyyy-MM-dd').parse(dt).toString());
  String parsedfromdate = DateFormat("dd").format(fromdate);
  return parsedfromdate;
  // }
}