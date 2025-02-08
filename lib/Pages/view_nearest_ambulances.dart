import 'dart:convert';
import 'dart:math';


import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';  // Add this for handling runtime permissions








class ViewNearestAmbulances extends StatelessWidget {
  const ViewNearestAmbulances({super.key});

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
      home: const ViewNearestAmbulancesPage(title: 'Flutter Demo Home Page'),
      routes: {

      },
    );
  }
}

class ViewNearestAmbulancesPage extends StatefulWidget {
  const ViewNearestAmbulancesPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ViewNearestAmbulancesPage> createState() => _ViewNearestAmbulancesPageState();
}

class _ViewNearestAmbulancesPageState extends State<ViewNearestAmbulancesPage> {
  int _counter = 0;

  _ViewNearestAmbulancesPageState() {
    load();
  }



  List<String> ccid_ = <String>[];
  List<String> AmbulanceNumber_ = <String>[];
  List<String> Hospital_ = <String>[];
  List<String> Type_ = <String>[];
  List<String> Status_ = <String>[];
  List<String> Latitude_ = <String>[];
  List<String> Longitude_ = <String>[];
  // List<String> department_= <String>[];
  // List<String> age_ = <String>[];
  // List<String> gender_ = <String>[];


  Future<void> load() async {
    List<String> ccid = <String>[];
    List<String> AmbulanceNumber = <String>[];
    List<String> Hospital = <String>[];
    List<String> Type = <String>[];
    List<String> Status = <String>[];
    List<String> Latitude = <String>[];
    List<String> Longitude = <String>[];
    // List<String> department = <String>[];
    // List<String> age = <String>[];
    // List<String> gender = <String>[];



    try {
      final pref=await SharedPreferences.getInstance();
      // String vid= pref.getString("rid").toString();
      String ip= pref.getString("url").toString();
      // String lid= pref.getString("lid").toString();

      String url=ip+"view_nearest_ambulances";
      print(url);
      var data = await http.post(Uri.parse(url), body: {
        // 'rid':vid
      });

      var jsondata = json.decode(data.body);
      String status = jsondata['status'];

      var arr = jsondata["data"];

      print(arr);

      print(arr.length);

      // List<String> schid_ = <String>[];
      // List<String> Name_ = <String>[];
      // List<String> type_ = <String>[];

      for (int i = 0; i < arr.length; i++) {

        ccid.add(arr[i]['id'].toString());
        AmbulanceNumber.add(arr[i]['Ambulance'].toString());
        Hospital.add(arr[i]['Hospital'].toString());

        Type.add(arr[i]['Type'].toString());
        Status.add(arr[i]['Status'].toString());
        Latitude.add(arr[i]['Latitude'].toString());
        Longitude.add(arr[i]['Longitude'].toString());
        // age.add(arr[i]['age'].toString());
        // gender.add(arr[i]['gender'].toString());
      }
      setState(() {
        ccid_ = ccid;
        AmbulanceNumber_ = AmbulanceNumber;
        Hospital_ = Hospital;
        Type_ = Type;
        Status_ = Status;
        Latitude_ = Latitude;
        Longitude_ = Longitude;
        // department_ = department;
        // age_ = age;
        // gender_ = gender;
      });
      print(status);
    } catch (e) {
      print("Error ------------------- " + e.toString());
      //there is error during converting file image to base64 encoding.
    }
  }


  Future<void> openMap(double lat, double lon) async {
    // Check permission before opening the map
    PermissionStatus permissionStatus = await Permission.location.request();
    if (permissionStatus.isGranted) {
      final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lon");

      if (await canLaunch(googleMapsUrl.toString())) {
        await launch(googleMapsUrl.toString());
      } else {
        throw "Could not launch $googleMapsUrl";
      }
    } else {
      print("Location permission denied");
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
              "Nearest Ambulances",
              style: new TextStyle(color: Colors.white),
            ),

        ),

        body:




        ListView.builder(
          physics: BouncingScrollPhysics(),
          // padding: EdgeInsets.all(5.0),
          // shrinkWrap: true,
          itemCount: ccid_.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
                onTap: () {




                },
                title: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [


                      Container(
                        width: MediaQuery. of(context). size. width,
                        height: 280,
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

                                  Flexible(flex: 2, fit: FlexFit.loose, child: Row(children: [Text("Ambulance Number")])),
                                  Flexible(flex: 3, fit: FlexFit.loose, child: Row(children: [Text(AmbulanceNumber_[index])])),

                                  // Text("Type"),
                                  // Text(Type_[index])
                                ],
                              ),


                              SizedBox(height: 16,),Row(

                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),

                                  Flexible(flex: 2, fit: FlexFit.loose, child: Row(children: [Text("Hospital name")])),
                                  Flexible(flex: 3, fit: FlexFit.loose, child: Row(children: [Text(Hospital_[index])])),

                                  // Text("Status"),
                                  // Text(Status_[index])
                                ],
                              ),
                              SizedBox(height: 16,),Row(

                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),

                                  Flexible(flex: 2, fit: FlexFit.loose, child: Row(children: [Text("Type")])),
                                  Flexible(flex: 3, fit: FlexFit.loose, child: Row(children: [Text(Type_[index])])),

                                  // Text("Status"),
                                  // Text(Status_[index])
                                ],
                              ),

                              SizedBox(height: 16,),Row(

                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),

                                  Flexible(flex: 2, fit: FlexFit.loose, child: Row(children: [Text("Latitude")])),
                                  Flexible(flex: 3, fit: FlexFit.loose, child: Row(children: [Text(Latitude_[index])])),

                                  // Text("Status"),
                                  // Text(Status_[index])
                                ],
                              ),     SizedBox(height: 16,),Row(

                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),

                                  Flexible(flex: 2, fit: FlexFit.loose, child: Row(children: [Text("Longitude")])),
                                  Flexible(flex: 3, fit: FlexFit.loose, child: Row(children: [Text(Longitude_[index])])),

                                  // Text("Status"),
                                  // Text(Status_[index])
                                ],
                              ),
                              SizedBox(height: 16,),Row(

                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),

                                  Flexible(flex: 2, fit: FlexFit.loose, child: Row(children: [Text("Status")])),
                                  Flexible(flex: 3, fit: FlexFit.loose, child: Row(children: [Text(Status_[index])])),

                                  // Text("Status"),
                                  // Text(Status_[index])
                                ],
                              ),

                              ElevatedButton(
                                onPressed: () {
                                  openMap(
                                    double.parse(Latitude_[index]),
                                    double.parse(Longitude_[index]),
                                  );
                                },
                                child: const Text('Track',style: TextStyle(color: Colors.white),),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),


                              // SizedBox(width: 10.0,),
                              // ElevatedButton(
                              //   onPressed: () async {
                              //
                              //     SharedPreferences prefs = await SharedPreferences.getInstance();
                              //     prefs.setString('rid', ccid_[index]);
                              //
                              //
                              //
                              //     Navigator.push(
                              //       context,
                              //
                              //       MaterialPageRoute(builder: (context) => viewshedule()),
                              //     );
                              //
                              //   },
                              //   child: Text('VIEW SHEDULE'),
                              // ),

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
                  ),
                )


            );
          },

        )


      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }




}
