import 'dart:convert';

import 'package:emergency_vehicle/Pages/models/ambulance_mode.dart';
import 'package:emergency_vehicle/widgets/top_model_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// class ShowMapInsideApp extends StatefulWidget {
//   const ShowMapInsideApp({super.key});

//   @override
//   State<ShowMapInsideApp> createState() => _ShowMapInsideAppState();
// }

// class _ShowMapInsideAppState extends State<ShowMapInsideApp> {
// LatLng? currentLocation = LatLng(11.2588, 75.7804);
// String _currentLocationStatus = '';
// final MapController _mapController = MapController();
//   @override
//   Widget build(BuildContext context) {
//     final screenheight = MediaQuery.of(context).size.height;
//     final screenwidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ElevatedButton(
//               onPressed: () {
//                 _getCurrentLocation();
//               },
//               child: Text('FetchUserLocation')),
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.all(15),
//               child: SizedBox(
//                 height: screenheight * 0.5,
//                 child: FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(
//                     initialCenter: currentLocation ?? LatLng(11.2588, 75.7804),
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                       subdomains: ['a', 'b', 'c'],
//                     ),
//                     MarkerLayer(markers: [
//                       Marker(
//                         point: currentLocation ?? LatLng(11.2588, 75.7804),
//                         child: const Icon(
//                           Icons.person_pin_circle,
//                           color: Colors.blue,
//                           size: 40,
//                         ),
//                       )
//                     ])
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();

//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           setState(() {
//             _currentLocationStatus = 'Location permissions are denied';
//           });
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         setState(() {
//           _currentLocationStatus =
//               'Location permissions are permanently denied';
//         });
//         return;
//       }
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);

//       setState(() {
//         currentLocation = LatLng(position.latitude, position.longitude);
//         _mapController.move(currentLocation!, 14.0);
//         print(currentLocation ?? '1' + 'issomethinff njfnj');
//       });

//       // _latitude = position.latitude;
//       // _longitude = position.longitude;

//       setState(() {
//         _currentLocationStatus = currentLocation.toString();
//       });
//     } catch (e) {
//       setState(() {
//         _currentLocationStatus = 'Unable to fetch location: $e';
//         print(_currentLocationStatus);
//       });
//     }
//   }
// }

Widget UserMap(
  List<Ambulance> ambulances,
  Future<void> refetchAmbulance, {
  required Future<void> getcurrentLocation,
  required double height,
  required double width,
  required MapController mapController,
  required BuildContext context,
  LatLng? currentLocation,
  required bool isFullScreen,
  required VoidCallback toggleFullScreen,
  required bool ishelp,
  required VoidCallback toggleHelp,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Center(
        child: SizedBox(
          height: isFullScreen ? MediaQuery.of(context).size.height : height,
          child: isFullScreen
              ? Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter:
                            currentLocation ?? const LatLng(11.2588, 75.7804),
                        maxZoom: 19,
                        minZoom: 3,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          // urlTemplate:
                          //     'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=010b64df977f45d5a757a2463c91ad9b',
                          //This is the original url for the map,but commenting it out becouse dont want to run out limit while testing
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        MarkerLayer(
                          markers: ambulances
                              .where((ambulance) =>
                                  ambulance.latitude != null &&
                                  ambulance.longitude != null)
                              .map(
                                (ambulance) => Marker(
                                  point: LatLng(ambulance.latitude!,
                                      ambulance.longitude!),
                                  width: 60,
                                  height: 60,
                                  child: GestureDetector(
                                    onTap: () {
                                      // _showAmbulanceDetails(context, ambulance);
                                      _showAmbulanceDetailsTopModelSheet(
                                          context, ambulance);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: ambulance.status ==
                                                    'Available'
                                                ? Colors.green.withOpacity(0.6)
                                                : Colors.red.withOpacity(0.6),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Transform(
                                        transform: Matrix4.rotationZ(
                                            45 * (3.141592653589793 / 180)),
                                        alignment: Alignment.center,
                                        child:
                                            Image.asset('asset/amb_icon.png'),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        MarkerLayer(markers: [
                          Marker(
                            point: currentLocation ??
                                const LatLng(11.2588, 75.7804),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.6),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_pin_circle,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),
                          )
                        ])
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 40,
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: IconButton(
                        onPressed: () {
                          getcurrentLocation;
                          refetchAmbulance;
                          mapController.move(currentLocation!, 14);
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 25,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    right: 40,
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: IconButton(
                        onPressed: () {
                          toggleFullScreen();
                        },
                        icon: Icon(
                          isFullScreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color: Colors.white,
                          size: 25,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      top: 40,
                      right: 40,
                      child: ishelp
                          ? Container(
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.6),
                                      blurRadius: 40,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(12)),
                              height: height,
                              width: width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Hints',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.blue.withOpacity(0.6),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.person_pin_circle,
                                          color: Colors.blue,
                                          size: 40,
                                        ),
                                      ),
                                      const Text(
                                        'User Location',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.green.withOpacity(0.6),
                                              blurRadius: 10,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Transform(
                                          transform: Matrix4.rotationZ(
                                              45 * (3.141592653589793 / 180)),
                                          alignment: Alignment.center,
                                          child:
                                              Image.asset('asset/amb_icon.png'),
                                        ),
                                      ),
                                      const Text(
                                        'Available Ambulance',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.red.withOpacity(0.6),
                                              blurRadius: 10,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Transform(
                                          transform: Matrix4.rotationZ(
                                              45 * (3.141592653589793 / 180)),
                                          alignment: Alignment.center,
                                          child:
                                              Image.asset('asset/amb_icon.png'),
                                        ),
                                      ),
                                      const Text(
                                        'Unavailable Ambulance',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.green),
                                    onPressed: () {
                                      toggleHelp();
                                    },
                                    child: const Text(
                                      'Close',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : SizedBox(
                              height: 60,
                              width: 60,
                              child: IconButton(
                                onPressed: () {
                                  toggleHelp();
                                },
                                icon: const Icon(
                                  Icons.question_mark_outlined,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: const CircleBorder(),
                                ),
                              ),
                            )),
                ])
              : Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter:
                            currentLocation ?? const LatLng(11.2588, 75.7804),
                        maxZoom: 19,
                        minZoom: 3,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          // urlTemplate:
                          //     'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=010b64df977f45d5a757a2463c91ad9b',
                          //This is the original url for the map,but commenting it out becouse dont want to run out limit while testing
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        MarkerLayer(
                          markers: ambulances
                              .where((ambulance) =>
                                  ambulance.latitude != null &&
                                  ambulance.longitude != null)
                              .map(
                                (ambulance) => Marker(
                                  point: LatLng(ambulance.latitude!,
                                      ambulance.longitude!),
                                  width: 60,
                                  height: 60,
                                  child: GestureDetector(
                                    onTap: () {
                                      // _showAmbulanceDetails(context, ambulance);
                                      toggleFullScreen();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: ambulance.status ==
                                                    'Available'
                                                ? Colors.green.withOpacity(0.6)
                                                : Colors.red.withOpacity(0.6),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Transform(
                                        transform: Matrix4.rotationZ(
                                            45 * (3.141592653589793 / 180)),
                                        alignment: Alignment.center,
                                        child:
                                            Image.asset('asset/amb_icon.png'),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        MarkerLayer(markers: [
                          Marker(
                            point: currentLocation ??
                                const LatLng(11.2588, 75.7804),
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: Colors.blue,
                              size: 40,
                            ),
                          )
                        ])
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: IconButton(
                      onPressed: () {
                        getcurrentLocation;
                        refetchAmbulance;
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: () {
                        toggleFullScreen();
                        print(isFullScreen);
                      },
                      icon: Icon(
                          isFullScreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                ]),
        ),
      ),
    ],
  );
}

void _showAmbulanceDetails(BuildContext context, Ambulance ambulance) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Ambulance Details"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Vehicle Number: ${ambulance.vehicleNumber}"),
          Text("Hospital: ${ambulance.hospital}"),
          Text("Type: ${ambulance.type}"),
          Text("Status: ${ambulance.status}"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}

void _showAmbulanceDetailsTopModelSheet(
    BuildContext context, Ambulance ambulance) {
  OverlayEntry? overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => TopSheetWidget(
      ambulance: ambulance,
      onClose: () {
        overlayEntry?.remove();
      },
    ),
  );

  Overlay.of(context).insert(overlayEntry);
}

Widget ambulanceMap(
  Future<void> refetchAmbulanceRequests, {
  required List<Map<String, dynamic>> ambulanceRequests,
  required Future<void> getcurrentLocation,
  required double height,
  required double width,
  required MapController mapController,
  required BuildContext context,
  required LatLng? currentLocation,
  required bool isFullScreen,
  required VoidCallback toggleFullScreen,
  required bool ishelp,
  required VoidCallback toggleHelp,
  required int? selectedIndex,
  required Function(int) onMarkerTap,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Center(
        child: SizedBox(
          height: isFullScreen ? MediaQuery.of(context).size.height : height,
          child: isFullScreen
              ? Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter:
                            currentLocation ?? const LatLng(11.2588, 75.7804),
                        maxZoom: 19,
                        minZoom: 3,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          // urlTemplate:
                          //     'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=010b64df977f45d5a757a2463c91ad9b',
                          //This is the original url for the map,but commenting it out becouse dont want to run out limit while testing
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        MarkerLayer(
                          markers: ambulanceRequests
                              .where((request) =>
                                  request['latitude'] != null &&
                                  request['longitude'] != null)
                              .map(
                                (request) => Marker(
                                  point: LatLng(
                                    double.parse(request['latitude']),
                                    double.parse(request['longitude']),
                                  ),
                                  width: 80,
                                  height: 80,
                                  child: GestureDetector(
                                    onTap: () {
                                      // _showRequestDetailsTopModelSheet(
                                      //     context, request);
                                    },
                                    child: Icon(
                                      Icons.emoji_people_rounded,
                                      color: request['Status'] == 'Requested'
                                          ? Colors.red
                                          : request['Status'] == 'Completed'
                                              ? Colors.blue
                                              : Colors.green,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        MarkerLayer(markers: [
                          Marker(
                            height: 50,
                            width: 50,
                            point: currentLocation ??
                                const LatLng(11.2588, 75.7804),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.6),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'asset/amb_icon.png',
                              ),
                            ),
                          )
                        ])
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 40,
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: IconButton(
                        onPressed: () async {
                          await getcurrentLocation; // Call the function and wait for it to finish
                          await refetchAmbulanceRequests; // Refetch the requests

                          if (currentLocation != null) {
                            mapController.move(currentLocation, 14);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Current location is not available')),
                            );
                          }
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    right: 40,
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: IconButton(
                        onPressed: () {
                          toggleFullScreen();
                        },
                        icon: Icon(
                          isFullScreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color: Colors.white,
                          size: 25,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      top: 40,
                      right: 40,
                      child: ishelp
                          ? Container(
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.6),
                                      blurRadius: 40,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(12)),
                              height: height,
                              width: width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Hints',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.blue.withOpacity(0.6),
                                              blurRadius: 10,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Transform(
                                          transform: Matrix4.rotationZ(
                                              45 * (3.141592653589793 / 180)),
                                          alignment: Alignment.center,
                                          child:
                                              Image.asset('asset/amb_icon.png'),
                                        ),
                                      ),
                                      const Text(
                                        'Your Location',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(Icons.emoji_people_rounded,
                                          color: Colors.red, size: 40),
                                      Text(
                                        'Help Requested',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(Icons.emoji_people_rounded,
                                          color: Colors.green, size: 40),
                                      Text(
                                        'Help On The Way',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(Icons.emoji_people_rounded,
                                          color: Colors.blue, size: 40),
                                      Text(
                                        'Help Completed',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.green),
                                    onPressed: () {
                                      toggleHelp();
                                    },
                                    child: const Text(
                                      'Close',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : SizedBox(
                              height: 60,
                              width: 60,
                              child: IconButton(
                                onPressed: () {
                                  toggleHelp();
                                },
                                icon: const Icon(
                                  Icons.question_mark_outlined,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: const CircleBorder(),
                                ),
                              ),
                            )),
                ])
              : Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter:
                            currentLocation ?? const LatLng(11.2588, 75.7804),
                        maxZoom: 19,
                        minZoom: 3,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          // urlTemplate:
                          //     'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=010b64df977f45d5a757a2463c91ad9b',
                          //This is the original url for the map,but commenting it out becouse dont want to run out limit while testing
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        MarkerLayer(
                          markers: ambulanceRequests
                              .where((request) =>
                                  request['latitude'] != null &&
                                  request['longitude'] != null)
                              .map(
                            (request) {
                              int index = ambulanceRequests.indexOf(request);
                              bool isSelected = index == selectedIndex;
                              return Marker(
                                point: LatLng(
                                  double.parse(request['latitude']),
                                  double.parse(request['longitude']),
                                ),
                                width: isSelected ? 80 : 60,
                                height: isSelected ? 80 : 60,
                                child: GestureDetector(
                                  onTap: () {
                                    onMarkerTap(index);
                                  },
                                  child: Icon(
                                    Icons.emoji_people_rounded,
                                    color: request['Status'] == 'Requested'
                                        ? Colors.red
                                        : request['Status'] == 'Completed'
                                            ? Colors.blue
                                            : Colors.green,
                                    size: isSelected ? 50 : 40,
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                        MarkerLayer(markers: [
                          Marker(
                            width: 50,
                            height: 50,
                            point: currentLocation ??
                                const LatLng(11.2588, 75.7804),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.8),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset('asset/amb_icon.png'),
                            ),
                          )
                        ])
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: IconButton(
                      onPressed: () async {
                        await getcurrentLocation; // Call the function and wait for it to finish
                        await refetchAmbulanceRequests; // Refetch the requests

                        if (currentLocation != null) {
                          mapController.move(currentLocation!, 14);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Current location is not available')),
                          );
                        }
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: () {
                        toggleFullScreen();
                        print(isFullScreen);
                      },
                      icon: Icon(
                          isFullScreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                ]),
        ),
      ),
    ],
  );
}
