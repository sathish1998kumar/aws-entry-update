import 'dart:convert';
import 'dart:math' hide log;
import 'dart:typed_data';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
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

import 'settings.dart';

class MyHomePage1 extends StatefulWidget {
  final String user;
  final String pass;
  final String mcc;
  MyHomePage1({
    super.key,
    required this.user,
    required this.pass,
    required this.mcc,
  });
  @override
  _MyHomePage1State createState() => _MyHomePage1State();
}

List<Employee> employees = [];

var mcname = "ALL";
var users = "";

class _MyHomePage1State extends State<MyHomePage1> {
  bool abcd = false;
  late EmployeeDataSource employeeDataSource;
  String selectedValuetype = "ALL";
  String dropdownValue = "ALL";
  late List<dynamic> data = [];
  var _inputFormat = DateFormat('dd-MM-yyyy');
  // int bindex = 1;
  int toggle = 0;
  String? idval;
  var _selectedDate = DateTime.now();
  var mccs;
  bool noflag = false;
  late SlidableController slidableController;
  TextEditingController weight_in = TextEditingController();
  TextEditingController weight_out = TextEditingController();
  void initState() {
    super.initState();
    getEmployeeData(_selectedDate, widget.mcc);
    users = widget.user;
    if (widget.mcc.contains('ALL')) {
      mcname = "ALL";
    } else {
      mcname = widget.mcc;
    }
  }

  getEmployeeData(_selectedDate, mcc) async {
    var map = {
      "action": 'tripmmc',
      "cat": "time",
      "district": "ALL",
      "imei": "ALL",
      "over": "Daily Report",
      "panch": "ALL",
      "subzone": "ALL",
      "username": widget.user,
      "mcc": mcc,
      "category": "ALL",
      "vehicle_type": "ALL",
      "from": DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 00:00:00',
      "to": DateFormat("yyyy-MM-dd").format(_selectedDate) + ' 23:59:59'
    };
    String url = "http://dev.igps.io/swms/api/getrf_api.php";
    var response = await http.post(Uri.parse(url), body: (jsonEncode(map)));
    if (response.statusCode == 200) {
      setState(() {
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
      });

      employees = data.map((e) => Employee.fromJson(e)).toList();
      print(data);
    }
  }

  var devil;
  sendotp() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var password = preferences.getString('password') ?? "";
    var map1 = {"mobile": password, "action": 'mmc_modify'};

    var response111 = await post(
        Uri.parse("http://dev.igps.io/aws_madurai/api/otp_alert.php"),
        body: (map1));
    print(response111.body);
    if (response111.statusCode == 200) {
      setState(() {
        devil = response111.body;
      });
    }
  }

  void _showImageDialog(BuildContext context, item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // bool showOTPField = false;

        return AlertDialog(
          title:
              Text('Are You Want Delete ${item["vehicle_no"]} ${item['trip']}'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (toggle == 0)
                    OtpTextField(
                        numberOfFields: 5,
                        borderColor: Color(0xFF512DA8),
                        showFieldAsBox: true,
                        // borderRadius: ,
                        onSubmit: (String verificationCode) {
                          setState(() {
                            idval = verificationCode;
                          });
                          //   otpvalidate(verificationCode);
                          // showDialog(
                          //     context: context,
                          //     builder: (context){
                          //       return AlertDialog(
                          //         title: Text("Verification Code"),
                          //         content: Text('Code entered is $verificationCode'),
                          //       );
                          //     }
                        }),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
                child: Text('Submit'),
                onPressed: () async {
                  setState(() {
                    toggle = 1;
                  });
                  if (toggle == 0) {
                    if (devil.trim() == "success" || (widget.pass != "")) {
                      // print("hi${phoneno.text}");
                      // print("hi${idval}");
                      var map111 = {
                        "mobile": widget.pass,
                        "otp": idval,
                        "action": 'mmc_modify'
                      };
                      var response111 = await post(
                          Uri.parse(
                              "http://dev.igps.io/aws_madurai/api/otp_verify.php"),
                          body: (map111));
                      //
                      print("kkkkk ${response111.body}");
                      if (response111.body.contains("Invalid")) {
                        print("bharath");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Invalid OTP..."),
                        ));
                      } else {
                        var map111 = {
                          "sno": item["sno"],
                          "imei": item["imei"],
                          "rfid": item["rf_id"],
                          "json": jsonEncode(item),
                          "mobile": widget.pass,
                          "action": "delete"
                        };
                        String url =
                            "http://dev.igps.io/aws_madurai/api/getrf_api.php";
                        // print(map111);
                        var response = await http.post(Uri.parse(url),
                            body: (jsonEncode(map111)));
                        if (response.statusCode == 200) {
                          setState(() {
                            if (response.body.contains("deleted")) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Deleted"),
                              ));
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Not Deleted"),
                              ));
                            }
                          });
                        }
                      }
                    }
                  } else {
                    // print(item["sno"].runtimeType);
                    var map111 = {
                      "sno": item["sno"],
                      "imei": item["imei"],
                      "rfid": item["rf_id"],
                      "json": jsonEncode(item),
                      "mobile": widget.pass,
                      "action": "delete"
                    };
                    String url =
                        "http://dev.igps.io/aws_madurai/api/getrf_api.php";
                    // print(map111);
                    var response = await http.post(Uri.parse(url),
                        body: (jsonEncode(map111)));
                    if (response.statusCode == 200) {
                      setState(() {
                        if (response.body.contains("deleted")) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Deleted"),
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Not Deleted"),
                          ));
                        }
                      });
                    }
                  }

                  // Handle submit action
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  void _showImageDialog1(BuildContext context, item) {
    weight_in.text = item["weight"]==null?'0':item["weight"];
    weight_out.text = item["weight_out"]==null?"0":item["weight_out"];
    DateTime initialDate = item['entry_dt'] != null ? DateFormat('dd-MM-yyyy').parse(item['entry_dt']) : DateTime.now();
    TextEditingController dateController = TextEditingController(text: item['entry_dt'] ?? DateFormat('dd-MM-yyyy').format(DateTime.now()));
    void _selectDate() async {
      FocusScope.of(context).requestFocus(new FocusNode());
      if (!mounted) return;
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
      );

      if (pickedDate != null && mounted) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (pickedTime != null && mounted) {
          final DateTime combinedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          String formattedDateTime = DateFormat('dd-MM-yyyy hh:mm a').format(combinedDateTime);
          print("Formatted DateTime: $formattedDateTime"); // Debugging line

          // Update the state if necessary
          setState(() {
            dateController.text = formattedDateTime;
          });
        }
      }
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update the data  ${item["vehicle_no"]} ${item["trip"]}'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: TextFormField(
                        controller: weight_in,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp('[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Weight IN',
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: TextFormField(
                        controller: weight_out,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp('[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Weight out',
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: TextFormField(
                        controller: dateController,

                        decoration: InputDecoration(
                          labelText: 'Date In',
                        ),
                        onTap: _selectDate,
                      ),
                    ),
                  ],
                ),
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
                print(dateController.text);
                // Use _controller.text to get the value of the input
                // print("Input value: ${weight_in.text}");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> refresh() async {
    setState(() {
      getEmployeeData(_selectedDate, widget.mcc);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: (widget.user == "tuty" || widget.user.toUpperCase() == "MMC")
            ? Text("AWS  (${mcname})")
            : Text("AWS"),
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
                  child: Image.network(
                    "http://dev.igps.io/avadi_new/assets/images/mmc.png",
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
                        mcc: widget.mcc,
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

                                await prefrences.remove("mcc");

                                // await prefrences.remove("location");
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
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
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: refresh,
            child: data.isNotEmpty
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return Padding(
                          padding:  EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 5.0),
                          child: Slidable(
                            key: Key(item.toString()),
                            endActionPane: ActionPane(
                              motion: ScrollMotion(),
                              children: [
                                SlidableAction(
                                  // An action can be bigger than the others.
                                  // flex: 2,
                                  onPressed: (BuildContext context) {
                                    if (toggle == 0) {
                                      sendotp();
                                    }
                                    _showImageDialog(context, item);
                                  },
                                  backgroundColor: Color(0xFF7BC043),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                                SlidableAction(
                                  onPressed: (BuildContext context) {
                                    if (toggle == 0) {
                                      sendotp();
                                    }
                                    _showImageDialog1(context, item);
                                  },
                                  backgroundColor: Color(0xFF0392CF),
                                  foregroundColor: Colors.white,
                                  icon: Icons.update,
                                  label: 'Update',
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 70,
                                color: Colors.white,
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    // Container for the index
                                    Container(
                                      color: Colors.red,
                                      width: 70,
                                      height: 70,
                                      alignment: Alignment.center,
                                      child: Text(
                                        (data.length - (index)).toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Main content
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('${item["vehicle_no"]}',
                                              style: const TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18)),
                                          Row(
                                            // mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${item["trip"]}',
                                                style: const TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0),
                                                child: Container(
                                                  padding:  EdgeInsets.all(6.0),
                                                  decoration: BoxDecoration(
                                                    color: item["weight"] != null && item['weight_out'] != null ? Colors.green[100] : Colors.red[100],
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    item["weight"] != null && item['weight_out'] != null ? Icons.check : Icons.close,
                                                    color: item["weight"] != null && item['weight_out'] != null ? Colors.green : Colors.red,
                                                    size: 24.0, // Increased size
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )

                                    // Expanded(
                                    //   child: Row(
                                    //     mainAxisAlignment: MainAxisAlignment.end,
                                    //     children: [
                                    //       // Show delete icon if showDelete is true
                                    //
                                    //       // Arrow icon
                                    //       IconButton(
                                    //         icon: Icon(
                                    //           item['showDelete']
                                    //                       .toString()
                                    //                       .toLowerCase() ==
                                    //                   'true'
                                    //               ? Icons.arrow_back_ios
                                    //               : Icons.arrow_forward_ios,
                                    //           color: Colors.blue,
                                    //         ),
                                    //         onPressed: () {
                                    //           setState(() {
                                    //             item['showDelete'] =
                                    //                 item['showDelete']
                                    //                             .toString()
                                    //                             .toLowerCase() ==
                                    //                         'true'
                                    //                     ? 'false'
                                    //                     : 'true';
                                    //           });
                                    //         },
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
                                    fontWeight: FontWeight.bold, fontSize: 20),
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
          )
        ],
      ),
    );
  }
}

class OTPDialog extends StatefulWidget {
  @override
  _OTPDialogState createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> {
  bool showOTPField = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Switch(
            value: showOTPField,
            onChanged: (value) {
              setState(() {
                showOTPField = value;
              });
            },
          ),
          if (showOTPField)
            TextField(
              decoration: InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Submit'),
          onPressed: () {
            // Handle submit action
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class ListItem {
  String title;
  bool showDelete;

  ListItem(this.title, {this.showDelete = false});
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
