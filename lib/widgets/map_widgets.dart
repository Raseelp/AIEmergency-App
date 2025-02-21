import 'dart:convert';

import 'package:emergency_vehicle/Pages/models/ambulance_mode.dart';
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

Widget UserMap(List<Ambulance> ambulances,
    {required Future<void> getcurrentLocation,
    required double height,
    required double width,
    required MapController mapController,
    required BuildContext context,
    LatLng? currentLocation}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            height: height,
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
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: ambulances
                      .where((ambulance) =>
                          ambulance.latitude != null &&
                          ambulance.longitude != null)
                      .map(
                        (ambulance) => Marker(
                          point:
                              LatLng(ambulance.latitude!, ambulance.longitude!),
                          width: 60,
                          height: 60,
                          child: GestureDetector(
                            onTap: () {
                              _showAmbulanceDetails(context, ambulance);
                            },
                            child: Transform(
                              transform: Matrix4.rotationZ(45 *
                                  (3.141592653589793 /
                                      180)), // Rotate by 45 degrees
                              alignment: Alignment.center,
                              child: Image.asset('asset/amb_icon.png'),
                            ),
                            // child: ambulance.status == 'Available'
                            //     ? const Icon(
                            //         Icons.location_on,
                            //         color: Colors.green,
                            //         size: 40,
                            //       )
                            //     : const Icon(
                            //         Icons.location_on,
                            //         color: Colors.red,
                            //         size: 40,
                            //       ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                MarkerLayer(markers: [
                  Marker(
                    point: currentLocation ?? LatLng(11.2588, 75.7804),
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
        ),
      ),
      ElevatedButton(
          onPressed: () {
            getcurrentLocation;
          },
          child: const Text('ReFetch User Location')),
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
