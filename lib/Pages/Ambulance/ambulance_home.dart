import 'dart:convert';
import 'package:emergency_vehicle/Pages/Ambulance/ambulance_Drawer.dart';
import 'package:emergency_vehicle/Pages/Ambulance/view_hospital_message_ambulanced.dart';
import 'package:emergency_vehicle/widgets/map_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AmbulanceHome extends StatefulWidget {
  const AmbulanceHome({super.key});

  @override
  State<AmbulanceHome> createState() => _AmbulanceHomeState();
}

class _AmbulanceHomeState extends State<AmbulanceHome> {
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

  Future<void> deleteRequest(int requestId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? url = prefs.getString('url');

    try {
      final response = await http.post(
        Uri.parse(url! + 'delete_ambulance_request'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'id': requestId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          requests.removeWhere((request) => request['id'] == requestId);
        });
      } else {
        print('Failed to delete request: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
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

      if(permission == LocationPermission.deniedForever){
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
          Uri.parse(url! + 'get_ambulance_requests/'),
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
                  : result),
            ),
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
              title: const Center(
                child: Text(
                  "Ambulance",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF4A90E2),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ViewAmbulanceMessgaepagePage(title: ''),
                        ));
                  },
                ),
              ],
            ),
            drawer: const AmbulanceDrawer(),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4A90E2), Color(0xFF145DA0)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 116, 175, 241),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : requests.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No requests available',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListView.builder(
                                          padding: const EdgeInsets.all(8),
                                          itemCount: requests.length,
                                          itemBuilder: (context, index) {
                                            final request = requests[index];
                                            final isSelected =
                                                selectedIndex == index;
                                            final status = request['Status'];

                                            return GestureDetector(
                                              onTap: () {
                                                setState(() =>
                                                    selectedIndex = index);
                                                LatLng destination = LatLng(
                                                  double.parse(
                                                      request['latitude']),
                                                  double.parse(
                                                      request['longitude']),
                                                );
                                                fetchRoute(currentLocation,
                                                    destination);
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6),
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.blue[50]
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    if (isSelected)
                                                      BoxShadow(
                                                        color: Colors.blue
                                                            .withOpacity(0.3),
                                                        blurRadius: 8,
                                                        spreadRadius: 2,
                                                      )
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Status Icon
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: status ==
                                                                'Requested'
                                                            ? Colors.orange
                                                                .withOpacity(
                                                                    0.2)
                                                            : status.startsWith(
                                                                    'Accepted')
                                                                ? Colors.blue
                                                                    .withOpacity(
                                                                        0.2)
                                                                : Colors.green
                                                                    .withOpacity(
                                                                        0.2),
                                                      ),
                                                      child: Icon(
                                                        status == 'Requested'
                                                            ? Icons.access_time
                                                            : status.startsWith(
                                                                    'Accepted')
                                                                ? Icons
                                                                    .check_circle_outline
                                                                : Icons
                                                                    .check_circle,
                                                        color: status ==
                                                                'Requested'
                                                            ? Colors.orange
                                                            : status.startsWith(
                                                                    'Accepted')
                                                                ? Colors.blue
                                                                : Colors.green,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),

                                                    // Request Details
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Sent By ' +
                                                                request[
                                                                    'username'],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            'Status: ${request['Status']}',
                                                            style: TextStyle(
                                                              color: status ==
                                                                      'Requested'
                                                                  ? Colors
                                                                      .orange
                                                                  : status.startsWith(
                                                                          'Accepted')
                                                                      ? Colors
                                                                          .blue
                                                                      : Colors
                                                                          .green,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // Action Buttons
                                                    if (status == 'Requested')
                                                      OutlinedButton(
                                                        onPressed: () =>
                                                            acceptRequest(
                                                                request['id']),
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Colors.blue,
                                                          side:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .blue),
                                                        ),
                                                        child: const Text(
                                                            'Accept'),
                                                      )
                                                    else if (status
                                                        .startsWith('Accepted'))
                                                      Column(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color:
                                                                  Colors.blue),
                                                          const SizedBox(
                                                              height: 6),
                                                          OutlinedButton(
                                                            onPressed: () =>
                                                                completeRequest(
                                                                    request[
                                                                        'id']),
                                                            style:
                                                                OutlinedButton
                                                                    .styleFrom(
                                                              foregroundColor:
                                                                  Colors.green,
                                                              side: const BorderSide(
                                                                  color: Colors
                                                                      .green),
                                                            ),
                                                            child: const Text(
                                                                'Complete'),
                                                          ),
                                                        ],
                                                      )
                                                    else
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color:
                                                                  Colors.green),
                                                          const SizedBox(
                                                              width: 8),
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red),
                                                            onPressed: () =>
                                                                deleteRequest(
                                                                    request[
                                                                        'id']),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Text(
                                      "Change Status: ",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: selectedItem == "Available"
                                                ? Colors.green
                                                : selectedItem == "Unavailable"
                                                    ? Colors.red
                                                    : Colors.blue,
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  (selectedItem == "Available"
                                                          ? Colors.green
                                                          : selectedItem ==
                                                                  "Unavailable"
                                                              ? Colors.red
                                                              : Colors.blue)
                                                      .withOpacity(0.2),
                                              blurRadius: 6,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: selectedItem,
                                            hint: const Text(
                                              'Select Availability',
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 16),
                                            ),
                                            items: items.map((String item) {
                                              return DropdownMenuItem<String>(
                                                value: item,
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                selectedItem = newValue;
                                                updateStatus(
                                                    selectedItem.toString());
                                              });
                                            },
                                            icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Colors.blue,
                                                size: 28),
                                            dropdownColor: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ambulanceMap(fetchAmbulanceRequests(),
                                      routeCoordinates: routeCoordinates,
                                      fetchRoute: fetchRoute,
                                      onMarkerTap: _onMarkerTap,
                                      selectedIndex: selectedIndex,
                                      currentLocation: currentLocation,
                                      ambulanceRequests: requests,
                                      getcurrentLocation:
                                          _getCurrentLocationRequests(),
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
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
