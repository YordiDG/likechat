import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _selectedLocation; // Campo nullable
  LatLng? _currentLocation; // Campo para la ubicación actual
  GoogleMapController? _mapController;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    // Solicitar permisos de ubicación
    final status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }

    // Verificar si el permiso fue otorgado
    if (await Permission.location.isGranted) {
      // Obtener la ubicación actual
      //Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        /*_currentLocation = LatLng(position.latitude, position.longitude);*/
      });

      // Mover la cámara a la ubicación actual si está disponible
      if (_mapController != null && _currentLocation != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentLocation!),
        );
      }
    } else {
      // Manejar el caso cuando el permiso no es otorgado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permiso de ubicación no concedido')),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _mapReady = true;
    });

    // Mover la cámara a la ubicación actual si está disponible
    if (_currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    }
  }

  void _onTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener la ubicación actual')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Ubicación'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _moveToCurrentLocation,
          ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(_selectedLocation);
            },
          ),
        ],
      ),
      body: _mapReady
          ? GoogleMap(
        onMapCreated: _onMapCreated,
        onTap: _onTap,
        initialCameraPosition: CameraPosition(
          target: _currentLocation ?? LatLng(37.7749, -122.4194), // Posición inicial predeterminada
          zoom: 12.0,
        ),
        markers: _selectedLocation != null
            ? {
          Marker(
            markerId: MarkerId('selected-location'),
            position: _selectedLocation!,
          ),
        }
            : {},
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
