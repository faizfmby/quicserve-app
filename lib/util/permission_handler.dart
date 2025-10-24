import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestBluetoothPermissions() async {
  if (await Permission.bluetoothScan.request().isGranted && await Permission.bluetoothConnect.request().isGranted) {
    debugPrint("All Bluetooth permissions granted");
  } else {
    debugPrint("Bluetooth permissions denied");
  }
  // ACCESS_FINE_LOCATION is often implicitly requested with BLUETOOTH_SCAN,
  // but explicitly requesting it might be safer.
  await Permission.locationWhenInUse.request();
}
