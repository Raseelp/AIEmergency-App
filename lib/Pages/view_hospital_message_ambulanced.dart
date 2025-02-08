import 'dart:convert';
import 'dart:math';



import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';





class ViewAmbulanceMessgae extends StatelessWidget {
  const ViewAmbulanceMessgae({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: const ViewAmbulanceMessgaepagePage(title: 'Flutter Demo Home Page'),
      routes: {

      },
    );
  }
}

class ViewAmbulanceMessgaepagePage extends StatefulWidget {
  const ViewAmbulanceMessgaepagePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ViewAmbulanceMessgaepagePage> createState() => _ViewAmbulanceMessgaepagePage();
}

class _ViewAmbulanceMessgaepagePage extends State<ViewAmbulanceMessgaepagePage> {
  int _counter = 0;

  _ViewAmbulanceMessgaepagePage() {
    view_college();
  }



  List<String> cid_ = <String>[];
  List<String> EmergencyMessage_ = <String>[];
  List<String> date_ = <String>[];
  // List<String> caddress_ = <String>[];
  // List<String> cphone_= <String>[];
  // List<String> cemail_ = <String>[];


  Future<void> view_college() async {
    List<String> cid = <String>[];
    List<String> EmergencyMessage = <String>[];
    List<String> date = <String>[];
    // List<String> caddress = <String>[];
    // List<String> cemail = <String>[];
    // List<String> cphone = <String>[];


    try {
      final pref=await SharedPreferences.getInstance();
      String ip= pref.getString("url").toString();
      // String lid= pref.getString("lid").toString();

      String url=ip+"view_messages_from_hospital";
      print(url);
      print("=========================");

      var data = await http.post(Uri.parse(url), body: {
      });
      var jsondata = json.decode(data.body);
      String status = jsondata['status'];

      var arr = jsondata["data"];

      print(arr);

      print(arr.length);

      for (int i = 0; i < arr.length; i++) {
        print("okkkkkkkkkkkkkkkkkkkkkkkk");
        cid.add(arr[i]['id'].toString());
        EmergencyMessage.add(arr[i]['EmergencyMessage'].toString());
        date.add(arr[i]['date'].toString());
        // caddress.add(arr[i]['regno'].toString());
        // cphone.add(arr[i]['phone'].toString());
        // cemail.add(arr[i]['email'].toString());
        print("ppppppppppppppppppp");
      }

      setState(() {
        cid_ = cid;
        EmergencyMessage_ = EmergencyMessage;
        date_ = date;

        // caddress_ = caddress;
        // cemail_ = cemail;
        // cphone_ = cphone;

      });

      print(cid_.length);
      print("+++++++++++++++++++++");
      print(status);
    } catch (e) {
      print("Error ------------------- " + e.toString());
      //there is error during converting file image to base64 encoding.
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.redAccent,
            title: new Text(
              "View Messages Hospital",
              style: new TextStyle(color: Colors.white),
            ),
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
                // Navigator.pushNamed(context, '/home');
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const  MyHomePage(title: '',)),);
                print("Hello");
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ThirdScreen()),
                // );
              },
            )
        ),

        body:




        ListView.builder(
          physics: BouncingScrollPhysics(),
          // padding: EdgeInsets.all(5.0),
          // shrinkWrap: true,
          itemCount: cid_.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onLongPress: () {
                print("long press" + index.toString());
              },
              title: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    children: [


                      Container(
                        width: MediaQuery. of(context). size. width,
                        height: 100,
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Column(
                            children: [







                              SizedBox(height: 16,),
                              Row(

                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),

                                  Flexible(flex: 2, fit: FlexFit.loose, child: Row(children: [Text("Message")])),
                                  Flexible(flex: 3, fit: FlexFit.loose, child: Row(children: [Text(EmergencyMessage_[index])])),

                                  // Text("Place"),
                                  // Text(place_[index])
                                ],
                              ),
                              SizedBox(height: 16,),
                              Row(

                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),

                                  Flexible(flex: 2, fit: FlexFit.loose, child: Row(children: [Text("Date and Time")])),
                                  Flexible(flex: 3, fit: FlexFit.loose, child: Row(children: [Text(date_[index])])),

                                  // Text("Place"),
                                  // Text(place_[index])
                                ],
                              ),

                              //
                              // SizedBox(height: 16,),
                              // Row(
                              //
                              //   children: [
                              //     SizedBox(
                              //       width: 10,
                              //     ),
                              //
                              //     Flexible(flex: 2, fit: FlexFit.loose, child: Row(children: [Text("REG NO")])),
                              //     Flexible(flex: 3, fit: FlexFit.loose, child: Row(children: [Text(caddress_[index])])),
                              //
                              //     // Text("Place"),
                              //     // Text(place_[index])
                              //   ],
                              // ),
                              // SizedBox(height: 9,),
                              // Row(
                              //
                              //   children: [
                              //     SizedBox(
                              //       width: 10,
                              //     ),
                              //
                              //     Flexible(flex: 2, fit: FlexFit.loose, child: Row(children: [Text("Phone")])),
                              //     Flexible(flex: 3, fit: FlexFit.loose, child: Row(children: [Text(cphone_[index])])),
                              //
                              //     // Text("Place"),
                              //     // Text(place_[index])
                              //   ],
                              // ), SizedBox(height: 9,),
                              // Row(
                              //
                              //   children: [
                              //     SizedBox(
                              //       width: 10,
                              //     ),
                              //
                              //     Flexible(flex: 2, fit: FlexFit.loose, child: Row(children: [Text("Email")])),
                              //     Flexible(flex: 3, fit: FlexFit.loose, child: Row(children: [Text(cemail_[index])])),
                              //
                              //     // Text("Place"),
                              //     // Text(place_[index])
                              //   ],
                              // ),
                              // SizedBox(height: 9,),

                              Container(
                                padding: EdgeInsets.all(5.0),
                                child:   Row(

                                  children: [


                                    SizedBox(width: 10.0,),
                                    // ElevatedButton(
                                    //   onPressed: () async {
                                    //
                                    //     SharedPreferences prefs = await SharedPreferences.getInstance();
                                    //     prefs.setString('bid', cid_[index]);
                                    //
                                    //
                                    //
                                    //     Navigator.push(
                                    //       context,
                                    //
                                    //       MaterialPageRoute(builder: (context) => viewROUTEUSER()),
                                    //     );
                                    //
                                    //   },
                                    //   child: Text('view bus route'),
                                    // ),

                                  ],
                                ),
                              )


                              // Column(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children:[
                              //   Text('Title'),
                              //   Text('Subtitle')
                              // ])
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5,
                          margin: EdgeInsets.all(10),
                        ),
                      ),


                    ],
                  )),
            );
          },

        )


      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }






}





