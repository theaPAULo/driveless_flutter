// lib/widgets/route_map_widget.dart
//
// Interactive Google Maps widget for displaying optimized routes
// Shows numbered markers for stops (polylines will be added in next version)

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../models/route_models.dart';

class RouteMapWidget extends StatefulWidget {
  final OptimizedRouteResult routeResult;
  final bool showTraffic;
  
  const RouteMapWidget({
    Key? key,
    required this.routeResult,
    this.showTraffic = false,
  }) : super(key: key);

  @override
  State<RouteMapWidget> createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends State<RouteMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Google Maps
            GoogleMap(
              initialCameraPosition: _getInitialCameraPosition(),
              onMapCreated: _onMapCreated,
              markers: _markers,
              trafficEnabled: widget.showTraffic,
              mapType: MapType.normal,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              buildingsEnabled: true,
              style: _getMapStyle(), // Dark theme map style
            ),
            
            // Traffic toggle button overlay (top right)
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  // TODO: Toggle traffic (will implement state management)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.showTraffic ? 'Traffic disabled' : 'Traffic enabled',
                      ),
                      backgroundColor: const Color(0xFF34C759),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.showTraffic ? const Color(0xFF34C759) : Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Traffic',
                    style: TextStyle(
                      color: widget.showTraffic ? const Color(0xFF34C759) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            
            // Loading overlay
            if (!_isMapReady)
              Container(
                color: const Color(0xFF1C1C1E),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF34C759),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading Map...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // MARK: - Map Initialization
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
    
    // Fit the map to show all markers
    _fitMapToMarkers();
  }

  // MARK: - Initial Camera Position
  CameraPosition _getInitialCameraPosition() {
    if (widget.routeResult.optimizedStops.isNotEmpty) {
      final firstStop = widget.routeResult.optimizedStops.first;
      return CameraPosition(
        target: LatLng(firstStop.latitude, firstStop.longitude),
        zoom: 12.0,
      );
    }
    
    // Default to Houston area if no stops
    return const CameraPosition(
      target: LatLng(29.7604, -95.3698), // Houston coordinates
      zoom: 10.0,
    );
  }

  // MARK: - Create Custom Numbered Markers
  Future<void> _createMarkers() async {
    Set<Marker> markers = {};
    
    for (int i = 0; i < widget.routeResult.optimizedStops.length; i++) {
      final stop = widget.routeResult.optimizedStops[i];
      final isFirst = i == 0;
      final isLast = i == widget.routeResult.optimizedStops.length - 1;
      
      // Determine marker color based on position
      Color markerColor;
      if (isFirst) {
        markerColor = const Color(0xFF34C759); // Green for start
      } else if (isLast) {
        markerColor = const Color(0xFFFF3B30); // Red for end
      } else {
        markerColor = const Color(0xFF007AFF); // Blue for stops
      }
      
      // Create custom marker icon with number
      final BitmapDescriptor markerIcon = await _createCustomMarker(
        number: i + 1,
        color: markerColor,
      );
      
      markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: LatLng(stop.latitude, stop.longitude),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: stop.displayName,
            snippet: stop.address,
          ),
        ),
      );
    }
    
    setState(() {
      _markers = markers;
    });
  }

  // MARK: - Create Custom Marker with Number
  Future<BitmapDescriptor> _createCustomMarker({
    required int number,
    required Color color,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Size size = const Size(60, 60);
    
    // Draw circle background
    final Paint circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      circlePaint,
    );
    
    // Draw white border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 1.5,
      borderPaint,
    );
    
    // Draw number text
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
    
    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // MARK: - Fit Map to Show All Markers
  void _fitMapToMarkers() async {
    if (_mapController == null || widget.routeResult.optimizedStops.isEmpty) {
      return;
    }
    
    // Calculate bounds to include all stops
    double minLat = widget.routeResult.optimizedStops.first.latitude;
    double maxLat = widget.routeResult.optimizedStops.first.latitude;
    double minLng = widget.routeResult.optimizedStops.first.longitude;
    double maxLng = widget.routeResult.optimizedStops.first.longitude;
    
    for (final stop in widget.routeResult.optimizedStops) {
      minLat = minLat < stop.latitude ? minLat : stop.latitude;
      maxLat = maxLat > stop.latitude ? maxLat : stop.latitude;
      minLng = minLng < stop.longitude ? minLng : stop.longitude;
      maxLng = maxLng > stop.longitude ? maxLng : stop.longitude;
    }
    
    // Add some padding
    const double padding = 0.01;
    
    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat - padding, minLng - padding),
      northeast: LatLng(maxLat + padding, maxLng + padding),
    );
    
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  // MARK: - Dark Theme Map Style
  String? _getMapStyle() {
    return '''
    [
      {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "administrative.country",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "administrative.locality",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#bdbdbd"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#181818"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#1b1b1b"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#2c2c2c"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#8a8a8a"
          }
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#373737"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#3c3c3c"
          }
        ]
      },
      {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#4e4e4e"
          }
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "transit",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#000000"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#3d3d3d"
          }
        ]
      }
    ]
    ''';
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}