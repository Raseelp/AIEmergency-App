import 'dart:convert';
import 'package:emergency_vehicle/Pages/ambulance_Drawer.dart';
import 'package:emergency_vehicle/widgets/map_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Drawer.dart'; // Ensure you import your Drawer class

class AmbulanceHome extends StatefulWidget {
  const AmbulanceHome({Key? key}) : super(key: key);

  @override
  State<AmbulanceHome> createState() => _AmbulanceHomeState();
}

class _AmbulanceHomeState extends State<AmbulanceHome> {
  String userAddress = "151-171 Montclair Ave, Newark, NJ 07104, USA";
  // String userProfileImage = "assets/profile.jpg"; // Replace with actual image
  String? selectedAlert;
  String _currentLocation = "Press the button to get the location";
  double? _latitude;
  double? _longitude;
  String? selectedItem; // Store selected value
  final List<String> items = ['Available', 'Unavailable']; // List of
  List<Map<String, dynamic>> requests = [];
  bool isLoading = false;
  int? selectedIndex;
  LatLng? currentLocation = LatLng(11.2588, 75.7804);
  String _currentLocationStatus = "Press the button to get the location";
  final MapController _mapController = MapController();
  bool _isFullScreen = false;

  List<LatLng> routeCoordinates = [];

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  bool _isHelp = false;

  void _toggleHelp() {
    setState(() {
      _isHelp = !_isHelp;
    });
  }

  Future<void> fetchRoute(LatLng? start, LatLng end) async {
    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start?.longitude},${start?.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List coordinates = data['routes'][0]['geometry']['coordinates'];

      setState(() {
        routeCoordinates = coordinates
            .map((coord) => LatLng(coord[1], coord[0])) // Convert to LatLng
            .toList();
      });
    } else {
      print("Failed to load route");
    }
  }

  Future<void> _getCurrentLocationRequests() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocationStatus = 'Location permissions are denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocationStatus =
              'Location permissions are permanently denied';
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        // _mapController.move(currentLocation!, 14.0);
      });

      _latitude = position.latitude;
      _longitude = position.longitude;

      setState(() {
        _currentLocationStatus = currentLocation.toString();
      });
    } catch (e) {
      setState(() {
        _currentLocationStatus = 'Unable to fetch location: $e';
      });
    }
  }

  Future<void> fetchAmbulanceRequests() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lid = prefs.getString('lid');
    String? url = prefs.getString('url');

    if (lid != null) {
      try {
        final response = await http.post(
          Uri.parse(url! +
              'get_ambulance_requests/'), // Replace with your backend URL
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'lid': lid}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            requests = List<Map<String, dynamic>>.from(data['requests']);
            isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to fetch requests: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LID not found')),
      );
    }
  }

  Future<void> acceptRequest(int requestId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lid = prefs.getString('lid');
    String? url = prefs.getString('url');
    print(url);

    if (lid != null && url != null && url.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(url + 'accept_request/$requestId/'), // Updated URL
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'lid': lid}), // Send ambulance's lid
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body)['status'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(result == 'Accepted'
                    ? 'Request accepted successfully'
                    : result)),
          );
          fetchAmbulanceRequests(); // Refresh requests after acceptance
        } else {
          final error = jsonDecode(response.body)['status'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LID or URL not found')),
      );
    }
  }

  Future<void> completeRequest(int requestId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lid = prefs.getString('lid');
    String? url = prefs.getString('url');

    if (lid != null && url != null && url.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(url + 'complete_request/$requestId/'), // Backend URL
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'lid': lid}),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body)['status'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(result == 'Completed'
                    ? 'Request completed successfully'
                    : result)),
          );
          fetchAmbulanceRequests(); // Refresh requests after completion
        } else {
          final error = jsonDecode(response.body)['status'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LID or URL not found')),
      );
    }
  }

  Future<void> updateStatus(String status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lid = prefs.getString('lid'); // Get the saved lid
    String? url = prefs.getString('url');

    if (lid != null) {
      try {
        final response = await http.post(
          Uri.parse(url! + 'update_status/'), // Replace with your backend URL
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'lid': lid,
            'status': status,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update status: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LID not found')),
      );
    }
  }

  Future<void> sendSOSRequest() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url'); // Keep null safety handling
    String? lid = sh.getString('lid');

    if (url == null || lid == null || url.isEmpty || lid.isEmpty) {
      Fluttertoast.showToast(msg: 'Invalid URL or ID');
      return;
    }

    // Ensure the URL has a trailing slash
    if (!url.endsWith('/')) {
      url += '/';
    }

    final requestUrl = Uri.parse(url + 'user_send_ambulance_request');

    try {
      final response = await http.post(requestUrl, body: {'lid': lid});
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        Fluttertoast.showToast(
            msg: status == 'ok' ? 'Request Sent' : 'Already Sent!');
      } else {
        Fluttertoast.showToast(
            msg: 'Network Error (Status: ${response.statusCode})');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Request Failed: $e');
    }
  }

  void _onMarkerTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    fetchAmbulanceRequests();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
    return _isFullScreen
        ? Scaffold(
            body: ambulanceMap(fetchAmbulanceRequests(),
                routeCoordinates: routeCoordinates,
                fetchRoute: fetchRoute,
                onMarkerTap: _onMarkerTap,
                selectedIndex: selectedIndex,
                currentLocation: currentLocation,
                ambulanceRequests: requests,
                getcurrentLocation: _getCurrentLocationRequests(),
                height: screenheight * 0.3,
                width: screenwidth,
                mapController: _mapController,
                context: context,
                isFullScreen: _isFullScreen,
                toggleFullScreen: _toggleFullScreen,
                ishelp: _isHelp,
                toggleHelp: _toggleHelp),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                "Ambulance Home",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon:
                      const Icon(Icons.notifications, color: Colors.redAccent),
                  onPressed: () {},
                ),
              ],
            ),
            drawer: const AmbulanceDraweClass(),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: DropdownButton<String>(
                          value: selectedItem,
                          hint: const Text('Select Availability'),
                          items: items.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedItem = newValue;
                              updateStatus(selectedItem.toString());
                            });
                          },
                          icon: const Icon(Icons.arrow_drop_down_circle,
                              color: Colors.blue),
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : requests.isEmpty
                                ? const Center(
                                    child: Text('No requests available'))
                                : ListView.builder(
                                    padding: const EdgeInsets.all(8),
                                    itemCount: requests.length,
                                    itemBuilder: (context, index) {
                                      final request = requests[index];
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedIndex =
                                                index; // Store the index of clicked tile
                                          });

                                          LatLng destination = LatLng(
                                            double.parse(request['latitude']),
                                            double.parse(request['longitude']),
                                          );

                                          // Fetch route to the selected location
                                          fetchRoute(
                                              currentLocation, destination);
                                        },
                                        child: Card(
                                          color: selectedIndex == index
                                              ? Colors.blue[
                                                  100] // Highlighted color
                                              : Colors.white, // Default color
                                          elevation: 2,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: ListTile(
                                            title: Text(
                                                'Request: ${request['request']}'),
                                            subtitle: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Status: ${request['Status']}'),
                                                      Text(
                                                          'Date: ${request['date']}'),
                                                      Text(
                                                          'Location: ${request['latitude']}, ${request['longitude']}'),
                                                    ],
                                                  ),
                                                ),
                                                request['Status'] == 'Requested'
                                                    ? ElevatedButton(
                                                        onPressed: () =>
                                                            acceptRequest(
                                                                request['id']),
                                                        child: const Text(
                                                            'Accept'),
                                                      )
                                                    : request['Status']
                                                            .toString()
                                                            .startsWith(
                                                                'Accepted')
                                                        ? Column(
                                                            children: [
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child: Icon(
                                                                    Icons
                                                                        .check_circle,
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () =>
                                                                    completeRequest(
                                                                        request[
                                                                            'id']),
                                                                child: const Text(
                                                                    'Completed'),
                                                              ),
                                                            ],
                                                          )
                                                        : const Icon(
                                                            Icons.check_circle,
                                                            color: Colors.green)
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                      Expanded(
                          child: ambulanceMap(fetchAmbulanceRequests(),
                              routeCoordinates: routeCoordinates,
                              fetchRoute: fetchRoute,
                              onMarkerTap: _onMarkerTap,
                              selectedIndex: selectedIndex,
                              currentLocation: currentLocation,
                              ambulanceRequests: requests,
                              getcurrentLocation: _getCurrentLocationRequests(),
                              height: screenheight * 0.3,
                              width: screenwidth,
                              mapController: _mapController,
                              context: context,
                              isFullScreen: _isFullScreen,
                              toggleFullScreen: _toggleFullScreen,
                              ishelp: _isHelp,
                              toggleHelp: _toggleHelp)),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
