import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TransportMapWidget extends StatefulWidget {
  final LatLng? driverPosition;
  final double? driverHeading;
  final LatLng? pickupPosition;
  final LatLng? dropPosition;
  final List<LatLng> routePoints;
  final Function(GoogleMapController) onMapCreated;

  const TransportMapWidget({
    super.key,
    required this.driverPosition,
    required this.driverHeading,
    required this.pickupPosition,
    required this.dropPosition,
    required this.routePoints,
    required this.onMapCreated,
  });

  @override
  State<TransportMapWidget> createState() => _TransportMapWidgetState();
}

class _TransportMapWidgetState extends State<TransportMapWidget> with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  BitmapDescriptor? _carIcon;
  
  late AnimationController _pulseController;
  late AnimationController _interpolationController;
  
  LatLng? _oldLatLng;
  LatLng? _targetLatLng;
  double _oldHeading = 0.0;
  double _targetHeading = 0.0;

  @override
  void initState() {
    super.initState();
    _createCarIcon();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);

    _interpolationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _interpolationController.addListener(() {
      setState(() {});
      _updateCameraFollow();
    });

    if (widget.driverPosition != null) {
      _targetLatLng = widget.driverPosition;
      _targetHeading = widget.driverHeading ?? 0.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _interpolationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TransportMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.driverPosition != oldWidget.driverPosition || widget.driverHeading != oldWidget.driverHeading) {
      if (widget.driverPosition != null) {
        _oldLatLng = _interpolatedPosition;
        _targetLatLng = widget.driverPosition;
        _oldHeading = _interpolatedHeading;
        _targetHeading = widget.driverHeading ?? 0.0;

        _interpolationController.forward(from: 0.0);
      }
    }
  }

  Future<void> _createCarIcon() async {
    final icon = await _getVehicleMarkerIcon(80);
    if (mounted) {
      setState(() {
        _carIcon = icon;
      });
    }
  }

  Future<BitmapDescriptor> _getVehicleMarkerIcon(double size) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final path = Path();
    path.moveTo(size / 2, 0); // Tip
    path.lineTo(size * 0.8, size); // Bottom right
    path.lineTo(size / 2, size * 0.75); // Bottom center indentation
    path.lineTo(size * 0.2, size); // Bottom left
    path.close();

    final paint = Paint()
      ..color = const ui.Color(0xFF2196F3) // Premium blue
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.08;
    canvas.drawPath(path, borderPaint);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  LatLng get _interpolatedPosition {
    if (_oldLatLng == null || _targetLatLng == null) {
      return widget.driverPosition ?? const LatLng(25.1972, 55.2744);
    }
    final t = _interpolationController.value;
    final lat = _oldLatLng!.latitude + (_targetLatLng!.latitude - _oldLatLng!.latitude) * t;
    final lng = _oldLatLng!.longitude + (_targetLatLng!.longitude - _oldLatLng!.longitude) * t;
    return LatLng(lat, lng);
  }

  double get _interpolatedHeading {
    final t = _interpolationController.value;
    double diff = _targetHeading - _oldHeading;
    while (diff < -180.0) diff += 360.0;
    while (diff > 180.0) diff -= 360.0;
    return (_oldHeading + diff * t + 360.0) % 360.0;
  }

  void _updateCameraFollow() {
    if (_mapController != null && widget.driverPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _interpolatedPosition,
            zoom: 16.5,
            bearing: _interpolatedHeading,
            tilt: 45.0, // 3D premium perspective
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Set<Marker> mapMarkers = {};
    final Set<Polyline> mapPolylines = {};
    final Set<Circle> mapCircles = {};

    // 1. Driver Marker
    if (widget.driverPosition != null) {
      mapMarkers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: _interpolatedPosition,
          icon: _carIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          rotation: _interpolatedHeading,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          zIndex: 10,
        ),
      );
    }

    // 2. Pickup Marker
    if (widget.pickupPosition != null) {
      mapMarkers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: widget.pickupPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          zIndex: 5,
        ),
      );

      // Pulse circle around pickup
      mapCircles.add(
        Circle(
          circleId: const CircleId('pulsing_pickup'),
          center: widget.pickupPosition!,
          radius: 15.0 + 80.0 * _pulseController.value,
          fillColor: colorScheme.primary.withOpacity(0.25 * (1.0 - _pulseController.value)),
          strokeColor: colorScheme.primary.withOpacity(0.5 * (1.0 - _pulseController.value)),
          strokeWidth: 2,
          zIndex: 2,
        ),
      );
    }

    // 3. Drop Marker
    if (widget.dropPosition != null) {
      mapMarkers.add(
        Marker(
          markerId: const MarkerId('drop'),
          position: widget.dropPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          zIndex: 5,
        ),
      );
    }

    // 4. Dual polylines for glow effect
    if (widget.routePoints.isNotEmpty) {
      mapPolylines.add(
        Polyline(
          polylineId: const PolylineId('route_glow'),
          points: widget.routePoints,
          color: colorScheme.primary.withOpacity(0.25),
          width: 10,
          jointType: JointType.round,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
          zIndex: 3,
        ),
      );
      mapPolylines.add(
        Polyline(
          polylineId: const PolylineId('route_core'),
          points: widget.routePoints,
          color: colorScheme.primary,
          width: 5,
          jointType: JointType.round,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
          zIndex: 4,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // rebuild circles
        if (widget.pickupPosition != null) {
          mapCircles.removeWhere((c) => c.circleId.value == 'pulsing_pickup');
          mapCircles.add(
            Circle(
              circleId: const CircleId('pulsing_pickup'),
              center: widget.pickupPosition!,
              radius: 15.0 + 80.0 * _pulseController.value,
              fillColor: colorScheme.primary.withOpacity(0.25 * (1.0 - _pulseController.value)),
              strokeColor: colorScheme.primary.withOpacity(0.5 * (1.0 - _pulseController.value)),
              strokeWidth: 2,
              zIndex: 2,
            ),
          );
        }

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.driverPosition ?? const LatLng(25.1972, 55.2744),
            zoom: 14,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            widget.onMapCreated(controller);
            _mapController?.setMapStyle(_darkMapStyle);
          },
          markers: mapMarkers,
          polylines: mapPolylines,
          circles: mapCircles,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        );
      },
    );
  }

  static const String _darkMapStyle = '''
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
