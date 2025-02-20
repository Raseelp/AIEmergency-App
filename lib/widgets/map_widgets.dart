import 'dart:convert';

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
LatLng? currentLocation = LatLng(11.2588, 75.7804);
String _currentLocationStatus = '';
final MapController _mapController = MapController();
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
    {required Future<void> getcurrentLocation,
    required double height,
    required double width,
    required MapController mapController,
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
                initialCenter: currentLocation ?? LatLng(11.2588, 75.7804),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
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
          child: Text('ReFetch User Location')),
    ],
  );
}
