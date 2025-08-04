// lib/utils/polyline_decoder.dart
//
// Utility for decoding Google's encoded polyline format
// Converts encoded polyline strings to list of LatLng coordinates

import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineDecoder {
  /// Decode Google's encoded polyline string to list of LatLng points
  /// 
  /// [encoded] - The encoded polyline string from Google Directions API
  /// Returns list of LatLng coordinates for drawing on map
  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> coordinates = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      
      // Decode latitude
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      
      int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;
      
      // Decode longitude
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      
      int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      // Convert to decimal degrees and add to coordinates
      coordinates.add(LatLng(
        lat / 1E5,
        lng / 1E5,
      ));
    }

    return coordinates;
  }
}