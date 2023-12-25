import 'package:aws/completed.dart';
import 'package:aws/today.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;

import 'datatable.dart';
import 'menulist.dart';
import 'mmcdash.dart';

// import 'new.dart';
class HomeScreen extends StatefulWidget {

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController username=TextEditingController();
  TextEditingController password=TextEditingController();
  TextEditingController password1 = TextEditingController();
  TextEditingController phoneno = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  var mobilenumber;
  var dataa = [];
  @override

  // List<Sathish_Class> sathish1 = [];
  // insertrecord() async {
  //   // var name1=name.text;
  //   print(password.text);
  //   var map = {"name": username.text, "pass": password.text,"action":"select"};
  //   try {
  //     Response response= await post(
  //         Uri.parse("http://dev.igps.io/tuty/api/flutterapi.php"),
  //         body:jsonEncode(map));
  //
  //     if(response.body=="Succussfully"){
  //       final prefs = await SharedPreferences.getInstance();
  //       prefs.setString('username', '${username.text}');
  //       prefs.setString('password', '${password.text}');
  //       prefs.setString('user', 'main');
  //       // return 'saved';
  //       var platformName = '';
  //       var token = '';
  //       token = (await FirebaseMessaging.instance.getToken())!;
  //       setState(() {
  //         token = token;
  //         if (Platform.isAndroid) {
  //           platformName = "android";
  //         } else if (Platform.isIOS) {
  //           platformName = "ios";
  //         }
  //       });
  //
  //       if(username.text!=""&&username.text!=null){
  //         Map body_data={
  //           "action":"fcm_token",
  //           "op":"add",
  //           "username":username.text,
  //           "platform":platformName,
  //           "token":token,
  //         };
  //         String url="http://dev.igps.io/http.php";
  //         http.Response response=await http.post(Uri.parse(url),body: body_data);
  //         log("token res : ${response.body}");
  //
  //       }
  //       print("token : $token");
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => dashboard(user: '${username.text}',pass: '${password.text}')),
  //       );
  //       // prefs.setString('school2', 'asdasdas');
  //     }
  //     else{
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text("Invalid details..."),
  //       ));
  //     }
  //
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  var chee = 0;
  var devil;
  String? idval;
  insertrecord1() async {
    chee = 0;
    var mobileno = phoneno.text;
    setState(() {
      mobilenumber = mobileno;
    });
    // print(mobilenumber);
    // chee=0;
    late Response response1;
    // try {
    var map1 = {"mobile": mobilenumber,"platform":'app'};
    response1 = await post(
        Uri.parse("http://dev.igps.io/swms/api/otp_alert.php"),
        body: (map1));
    if (response1.statusCode == 200) {
      devil = response1.body;
      print("Bharath**** ${response1.body}");
      // print(d==response1.body && d==" success");
      setState(() async {
        if (devil.trim() == 'success') {
          print("sathish");
          var response1 = await post(
              Uri.parse("http://dev.igps.io/tuty/entry1/api/flutter_api.php"),
              body: (map1));
          setState(() {
            chee = 1;
          });
          print(chee);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Invalid Phone Number..."),
          ));
        }
      });
    }
    // dataa = jsonDecode(response1.body);
  }

  // catch(e){
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text("No internet connection!"),
  //
  //   ));
  // }
  // }
  var dat = [];
  insertrecord11() async {
    // print("hi14${devil}");
    // print("hi14${devil}");
    if (devil.trim() == "success" || (phoneno.text != "")) {
      // print("hi${phoneno.text}");
      // print("hi${idval}");
      var map111 = {"mobile": phoneno.text, "otp": idval ,"platform":'app'};
      var response111 = await post(
          Uri.parse("http://dev.igps.io/swms/api/otp_verify.php"),
          body: (map111));
      //
      print("kkkkk ${response111.body}");
      if (response111.body.contains("Invalid")) {
        print("bharath");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid OTP..."),
        ));
      } else {
        dat = jsonDecode(response111.body);
        print("data: ${dat}");
        for (var dou in dat) {
          print(dou["mobile"]);
          // setState((){
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('username', '${dou["main_user"]}');
          prefs.setString('password', '${dou["mobile"]}');
          prefs.setString('main_user', '${dou["main_user"]}');
          prefs.setString('logo', '${dou["logo"]}');
          prefs.setString('mcc', '${dou["mcc"]}');
          prefs.setString('type', '${dou["type"]}');
              print("ff${dou["main_user"]}");
          // return 'saved';
          if(dou["type"]=="admin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      menu(
                          user: '${dou["main_user"]}',
                          pass: '${dou["mobile"]}',
                          main: '${dou["main_user"]}',
                          logo: '${dou["logo"]}',
                          mcc: dou["mcc"],
                          type:dou["type"],
                      )
              ),
            );
          }else if(dou["type"]=="user"){
            if(dou["main_user"].toString().toUpperCase()=="MMC"){
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MyHomePage1(
                            user: '${dou["main_user"]}',
                            pass: '${dou["mobile"]}',
                            main: '${dou["main_user"]}',
                            logo: '${dou["logo"]}',
                            mcc: '${dou["mcc"]}',
                            type: '${dou["type"]}'

                        ),
                  ));
            }
            else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MyHomePage(
                            user: '${dou["main_user"]}',
                            pass: '${dou["mobile"]}',
                            main: '${dou["main_user"]}',
                            logo: '${dou["logo"]}',
                            mcc: '${dou["mcc"]}',
                            type: '${dou["type"]}'

                        ),
                  ));
            }
          }
          // prefs.setString('school2', 'asdasdas');
        }
      }
    }
  }
  initState() {
    _passwordVisible = false;

    // insertrecord();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:_colorFromHex("f2f2f2") ,
      // appBar: AppBar(centerTitle: true,title:Text("Login Page",textAlign: TextAlign.center,)),
      body: Center(
        child: Form(
          key: _formKey,
          
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Automatic Weighing System",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,   color:Colors.orange,),),
              SizedBox(height: 20,),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: chee == 1 ? 350 : 300,
                      width: 300,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2.0,
                              spreadRadius: 0.4,
                              offset: Offset(0.1, 0.5),
                            )
                          ],
                          color: Colors.white),
                      child: Column(
                        children: [

                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.05,
                          ),
                          Text(
                            'Login',
                            style: TextStyle(
                                color:Colors.orange, fontSize: 30,fontWeight: FontWeight.bold,),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.05,
                          ),
                          SizedBox(
                            width: 230,
                            child: TextFormField(
                              controller: phoneno,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: InputDecoration(
                                // focusColor: Colors.white,
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                ),
                                hintText: "Enter The Phoneno",
                                counter: SizedBox.shrink(),
                                labelText: 'Phone No',

                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter The Phone Number';
                                } else if (!RegExp(
                                    r'(^(?:[+0]9)?[0-9]{10,12}$)')
                                    .hasMatch(value)) {
                                  return 'Please Enter Valid  Phone Number';
                                }
                                return null;
                              },
                            ),
                          ),
                          chee == 1
                              ? SizedBox(
                            height: MediaQuery.of(context).size.height*0.05,
                          )
                              : SizedBox.shrink(),
                          chee == 1
                              ? SizedBox(
                              height: MediaQuery.of(context).size.height*0.05,
                              child: OtpTextField(
                                  numberOfFields: 5,
                                  borderColor: Color(0xFF512DA8),
                                  showFieldAsBox: true,
                                  // borderRadius: ,
                                  onSubmit:
                                      (String verificationCode) {
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
                                  }))
                              : SizedBox.shrink(),
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.03,
                          ),
                          Container(
                              margin: EdgeInsets.all(10),
                              child: chee == 0
                                  ? ElevatedButton(
                                child: Text("Send Otp"),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.orange
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!
                                      .validate()) {
                                    insertrecord1();

                                    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => Dashboard()));
                                  }
                                },
                              )
                                  : ElevatedButton(
                                  child: Text("Login"),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.orange
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!
                                        .validate()) {
                                      insertrecord11();

                                      // Navigator.of(context).push(MaterialPageRoute(builder: (context) => Dashboard()));
                                    }
                                  })),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // body: Form(
      //   key: _formKey,
      //   child: Center(
      //     child: DefaultTabController(length: 2, initialIndex: 0,
      //         child:Container(
      //           height: 50,
      //           width: 300,
      //
      //           decoration: BoxDecoration(
      //               borderRadius: BorderRadius.circular(20),
      //               boxShadow: [
      //                 BoxShadow(
      //                   blurRadius: 2.0,
      //                   spreadRadius: 0.4,
      //                   offset: Offset(0.1,0.5),
      //                 )
      //               ],
      //               color: Colors.white
      //           ),
      //
      //           child: Column(
      //
      //             children: [
      //               TabBar(
      //                 labelColor: Colors.green,
      //                 unselectedLabelColor:Colors.black,
      //                 tabs: [
      //                   Tab(text: 'tab 1',),
      //                   Tab(text: 'tab 2',),
      //                 ],
      //               ),
      //               TabBarView(
      //
      //                 children: [
      //                   Container(
      //                     child: Column(
      //                       children: [
      //                         SizedBox(height: 20,),
      //                         Text('Login',style: TextStyle(color: Colors.blue,fontSize: 30),),
      //                         SizedBox(height: 20,),
      //                         SizedBox(
      //                           height: 50,
      //                           width:230,
      //                           child:TextFormField(
      //                             controller: username,
      //                             decoration: InputDecoration(
      //                               // focusColor: Colors.white,
      //                               prefixIcon: Icon(Icons.person_outline_rounded,color: Colors.grey,),
      //                               border: OutlineInputBorder(
      //                                 borderRadius: BorderRadius.circular(10.0),
      //                               ),
      //                               hintText:" Enter The Username",
      //                               labelText: 'Username',
      //                             ),
      //                             validator: (value) {
      //                               if (value == null || value.isEmpty) {
      //                                 return 'Please Enter The Name';
      //                               }
      //                               return null;
      //                             },
      //
      //
      //                           ),
      //                         ),
      //                         SizedBox(height: 25,),
      //                         SizedBox(
      //
      //                           height: 50,
      //                           width: 230,
      //                           child:TextFormField(
      //                             keyboardType: TextInputType.text,
      //                             controller: password,
      //                             obscureText:!_passwordVisible,
      //                             onFieldSubmitted: (ss){
      //                               setState((){
      //                                 if(password.text!=""&&password.text!=null&&username.text!=""&&username.text!=null){
      //
      //                                   if (_formKey.currentState!.validate()) {
      //                                     insertrecord();
      //
      //                                     // Navigator.of(context).push(MaterialPageRoute(builder: (context) => Dashboard()));
      //                                   }
      //                                 }
      //                               });
      //                             },
      //                             decoration: InputDecoration(
      //                               prefixIcon: Icon(Icons.password,color: Colors.grey,),
      //                               border: OutlineInputBorder(
      //                                 borderRadius: BorderRadius.circular(10.0),
      //                               ),
      //
      //                               labelText: 'Password',
      //                               hintText: 'Enter The Password',
      //                               suffixIcon: IconButton(
      //                                 icon: Icon(
      //                                   // Based on passwordVisible state choose the icon
      //                                   _passwordVisible
      //                                       ? Icons.visibility
      //                                       : Icons.visibility_off,
      //                                   color: Theme.of(context).primaryColorDark,
      //                                 ),
      //                                 onPressed: () {
      //                                   //   // Update the state i.e. toogle the state of passwordVisible variable
      //                                   setState((){
      //                                     _passwordVisible = !_passwordVisible;
      //
      //                                   });
      //
      //                                 },
      //                               ),
      //                             ),
      //                             validator: (value) {
      //                               if (value == null || value.isEmpty) {
      //                                 return 'Please Enter The Password';
      //                               }
      //                               return null;
      //                             },
      //
      //                           ) ,
      //                         ),
      //                         SizedBox(height: 18,),
      //                         Container(
      //                             margin: EdgeInsets.all(10),
      //                             child: ElevatedButton(
      //                               child: Text("Login"),
      //                               onPressed: () {
      //                                 if (_formKey.currentState!.validate()) {
      //                                   insertrecord();
      //
      //                                   // Navigator.of(context).push(MaterialPageRoute(builder: (context) => Dashboard()));
      //                                 }
      //                               },
      //                             )
      //                         )
      //
      //                       ],
      //
      //                     ),
      //                   ),
      //                   Container(
      //                     child: Column(
      //                       children: [
      //                         SizedBox(height: 20,),
      //                         Text('Login',style: TextStyle(color: Colors.blue,fontSize: 30),),
      //                         SizedBox(height: 20,),
      //                         SizedBox(
      //                           height: 50,
      //                           width:230,
      //                           child:TextFormField(
      //                             controller: username,
      //                             // keyboardType: K,
      //                             // style: TextStyle(
      //                             //   fontSize: 16,
      //                             //   color: Colors.blue,
      //                             //   fontWeight:FontWeight.w600,
      //                             // ),
      //                             decoration: InputDecoration(
      //                               // focusColor: Colors.white,
      //                               prefixIcon: Icon(Icons.person_outline_rounded,color: Colors.grey,),
      //                               border: OutlineInputBorder(
      //                                 borderRadius: BorderRadius.circular(10.0),
      //                               ),
      //                               hintText:" Enter The Username",
      //                               // hintStyle: TextStyle(
      //                               //   color: Colors.grey,
      //                               //   fontSize: 16,
      //                               //   fontFamily: "verdana_regular",
      //                               //   fontWeight: FontWeight.w400,
      //                               // ),
      //                               labelText: 'Username',
      //                               //lable style
      //                               // labelStyle: TextStyle(
      //                               //   color: Colors.grey,
      //                               //   fontSize: 16,
      //                               //   fontFamily: "verdana_regular",
      //                               //   fontWeight: FontWeight.w400,
      //                               // ),
      //                             ),
      //                             validator: (value) {
      //                               if (value == null || value.isEmpty) {
      //                                 return 'Please Enter The Name';
      //                               }
      //                               return null;
      //                             },
      //
      //
      //                           ),
      //                         ),
      //                         SizedBox(height: 25,),
      //                         SizedBox(
      //
      //                           height: 50,
      //                           width: 230,
      //                           child:TextFormField(
      //                             keyboardType: TextInputType.text,
      //                             controller: password,
      //                             obscureText:!_passwordVisible,
      //                             onFieldSubmitted: (ss){
      //                               setState((){
      //                                 if(password.text!=""&&password.text!=null&&username.text!=""&&username.text!=null){
      //
      //                                   if (_formKey.currentState!.validate()) {
      //                                     insertrecord();
      //
      //                                     // Navigator.of(context).push(MaterialPageRoute(builder: (context) => Dashboard()));
      //                                   }
      //                                 }
      //                               });
      //                             },
      //                             decoration: InputDecoration(
      //                               prefixIcon: Icon(Icons.password,color: Colors.grey,),
      //                               border: OutlineInputBorder(
      //                                 borderRadius: BorderRadius.circular(10.0),
      //                               ),
      //
      //                               labelText: 'Password',
      //                               hintText: 'Enter The Password',
      //                               suffixIcon: IconButton(
      //                                 icon: Icon(
      //                                   // Based on passwordVisible state choose the icon
      //                                   _passwordVisible
      //                                       ? Icons.visibility
      //                                       : Icons.visibility_off,
      //                                   color: Theme.of(context).primaryColorDark,
      //                                 ),
      //                                 onPressed: () {
      //                                   //   // Update the state i.e. toogle the state of passwordVisible variable
      //                                   setState((){
      //                                     _passwordVisible = !_passwordVisible;
      //
      //                                   });
      //
      //                                 },
      //                               ),
      //                             ),
      //                             validator: (value) {
      //                               if (value == null || value.isEmpty) {
      //                                 return 'Please Enter The Password';
      //                               }
      //                               return null;
      //                             },
      //
      //                           ) ,
      //                         ),
      //                         SizedBox(height: 18,),
      //                         Container(
      //                             margin: EdgeInsets.all(10),
      //                             child: ElevatedButton(
      //                               child: Text("Login"),
      //                               onPressed: () {
      //                                 if (_formKey.currentState!.validate()) {
      //                                   insertrecord();
      //
      //                                   // Navigator.of(context).push(MaterialPageRoute(builder: (context) => Dashboard()));
      //                                 }
      //                               },
      //                             )
      //                         )
      //
      //                       ],
      //
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ],
      //           ),
      //
      //         )
      //     ),
      //     // child:Text("Welcome to Home Page",
      //     // style: TextStyle( color: Colors.black, fontSize: 30)
      //     // )
      //   ),
      // ),
    );
  }
}
Color _colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}
