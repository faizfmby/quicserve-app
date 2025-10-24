import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/services/local/printer_settings_storage.dart';
import 'package:quicserve_flutter/widgets/alert_message.dart';
import 'package:image/image.dart' as img;

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  String? deviceName;
  BluetoothDevice? selectedDevice;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bluetooth.isConnected.then((connected) {
      setState(() => isConnected = connected ?? false);
    });

    final bondedDevices = await bluetooth.getBondedDevices();
    final savedName = await PrinterSettingsStorage.getPrinterName();

    setState(() {
      devices = bondedDevices;
      if (savedName != null) {
        selectedDevice = bondedDevices.isNotEmpty
            ? bondedDevices.firstWhere(
                (d) => d.name == savedName,
                orElse: () => bondedDevices.first,
              )
            : null;
      }
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      // Optional: Basic check (name should not be empty or unknown)
      if ((device.name == null || device.name!.isEmpty) && (device.address == null || device.address!.isEmpty)) {
        AlertMessage.showError(context, 'Invalid Bluetooth device selected.');
        return;
      }

      await bluetooth.connect(device);

      // Small delay to verify if connection was successful
      final isConnectedNow = await bluetooth.isConnected;
      if (!isConnectedNow!) {
        AlertMessage.showError(context, 'Connected device is not a printer.');
        return;
      }

      setState(() {
        selectedDevice = device;
        isConnected = true;
        deviceName = deviceName = device.name ?? 'Unknown';
      });

      await PrinterSettingsStorage.savePrinterName(device.name ?? 'Unknown');

      AlertMessage.showSuccess(context, 'Printer connected');
    } catch (e) {
      AlertMessage.showError(context, 'Failed to connect: ${e.toString()}');
    }
  }

  void _disconnectPrinter() async {
    await bluetooth.disconnect();
    await PrinterSettingsStorage.removePrinterName();

    setState(() {
      selectedDevice = null;
      isConnected = false;
      AlertMessage.showSuccess(context, 'Printer disconnected');
    });
  }

  Future<void> _printTest() async {
    if (!isConnected) return;

    bluetooth.printNewLine();
    final ByteData data = await rootBundle.load('assets/images/ic_launcher_foreground.png');
    final Uint8List bytes = data.buffer.asUint8List();

    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      await bluetooth.printImageBytes(Uint8List.fromList(img.encodePng(decoded)));
    }
    bluetooth.printNewLine();
    bluetooth.printCustom("QUICSERVE", 2, 1);
    bluetooth.printCustom("A Smart POS Solution", 1, 1);
    bluetooth.printCustom("Made by:", 1, 1);
    bluetooth.printCustom("Faiz Mullah bin Yusof", 1, 1);
    bluetooth.printNewLine();
    bluetooth.printCustom("RECEIPT TEST", 2, 1);
    bluetooth.printNewLine();
    bluetooth.printCustom("Device:".padRight(24) + "${deviceName ?? "-"}".padLeft(24), 1, 1);
    bluetooth.printNewLine();
    bluetooth.printCustom("Successfully connected!", 2, 1);
    bluetooth.printNewLine();
    bluetooth.paperCut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.yellow2,
                        AppColors.orange2,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Printer',
                      style: CustomFont.daysone14.copyWith(fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Paired Printers:",
                        style: CustomFont.calibribold22,
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<BluetoothDevice>(
                        isExpanded: true,
                        value: selectedDevice,
                        hint: const Text("Select a printer"),
                        items: devices.map((device) {
                          return DropdownMenuItem(
                            value: device,
                            child: Text(device.name ?? "Unknown"),
                          );
                        }).toList(),
                        onChanged: (device) {
                          if (device != null) _connectToDevice(device);
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: isConnected ? _disconnectPrinter : null,
                            icon: const Icon(Icons.bluetooth_disabled),
                            label: const Text("Disconnect"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Spacer(),
                ElevatedButton(
                    onPressed: isConnected ? _printTest : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.orange1,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(),
                    ),
                    child: Ink(
                      height: 55,
                      decoration: BoxDecoration(
                          gradient: isConnected
                              ? AppColors.gradient2
                              : LinearGradient(colors: [
                                  AppColors.lightgrey2,
                                  AppColors.lightgrey2,
                                ])),
                      child: Center(
                        child: Text(
                          'Test Print',
                          style: CustomFont.calibri16.copyWith(color: isConnected ? AppColors.black : AppColors.black.withOpacity(0.3)),
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
