import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:permission_handler/permission_handler.dart';

BluetoothManager bluetoothManager = BluetoothManager.instance;

void startBluetoothScan() async {
  var status = await Permission.bluetoothScan.request();
  var connectStatus = await Permission.bluetoothConnect.request();
  //var advertiseStatus = await Permission.bluetoothAdvertise.request();

  if (status.isGranted && connectStatus.isGranted) {
    print("All Bluetooth permissions granted");
    try {
      await bluetoothManager.startScan(timeout: Duration(seconds: 4));
      bluetoothManager.scanResults.listen((devices) {
        devices.forEach((device) {
          print("Found device: ${device.name ?? 'Unknown'} (${device.address})");
        });
      });
    } catch (e) {
      print("Error starting scan: $e");
    }
  } else {
    print("Bluetooth permissions not granted.");
  }
}
