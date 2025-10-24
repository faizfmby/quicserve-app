import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:quicserve_flutter/models/menu_item.dart';
import 'package:quicserve_flutter/models/order.dart';
import 'package:quicserve_flutter/models/order_item.dart';

class TicketPrintWidget extends StatefulWidget {
  final bool isFOHEnabled;
  final bool isBOHEnabled;
  final List<String> selectedFOHCategories;
  final List<String> selectedBOHCategories;
  final Order order;
  final List<MenuItem> allMenuItems; // You need to pass this in!

  const TicketPrintWidget({
    super.key,
    required this.isFOHEnabled,
    required this.isBOHEnabled,
    required this.selectedFOHCategories,
    required this.selectedBOHCategories,
    required this.order,
    required this.allMenuItems,
  });

  @override
  State<TicketPrintWidget> createState() => _TicketPrintWidgetState();
}

class _TicketPrintWidgetState extends State<TicketPrintWidget> {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  BluetoothDevice? selectedPrinter;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _initPrinter();
  }

  Future<void> _initPrinter() async {
    // Example:
    final bondedDevices = await bluetooth.getBondedDevices();
    if (bondedDevices.isNotEmpty) {
      selectedPrinter = bondedDevices.first;
      await bluetooth.connect(selectedPrinter!);
      final connected = await bluetooth.isConnected;
      setState(() {
        isConnected = connected ?? false;
      });
    }
  }

  Future<void> printTickets() async {
    if (widget.isFOHEnabled) {
      var fohItems = filterOrderItemsByCategoryNames(
        widget.order.orderItem ?? [],
        widget.allMenuItems,
        widget.selectedFOHCategories,
      );
      if (fohItems.isNotEmpty) {
        await _printTicket(ticketType: "FOH", items: fohItems);
      }
    }

    if (widget.isBOHEnabled) {
      var bohItems = filterOrderItemsByCategoryNames(
        widget.order.orderItem ?? [],
        widget.allMenuItems,
        widget.selectedBOHCategories,
      );
      if (bohItems.isNotEmpty) {
        await _printTicket(ticketType: "BOH", items: bohItems);
      }
    }
  }

  List<OrderItem> filterOrderItemsByCategoryNames(
    List<OrderItem> orderItems,
    List<MenuItem> allMenuItems,
    List<String> filterCategories,
  ) {
    // Build a map from itemID to MenuItem for fast lookup
    final itemMap = {
      for (var item in allMenuItems) item.itemID: item,
    };

    return orderItems.where((orderItem) {
      final menuItem = itemMap[orderItem.item?.itemID];
      if (menuItem == null) return false;

      // Assuming MenuItem now has categoryName
      // If it doesn't, you need to add it or map categoryID to categoryName separately
      return filterCategories.contains(menuItem.categoryName);
    }).toList();
  }

  Future<void> _printTicket({
    required String ticketType,
    required List<OrderItem> items,
  }) async {
    if (!isConnected || selectedPrinter == null) return;

    bluetooth.printNewLine();
    if (widget.order.orderTicket != null) {
      bluetooth.printCustom("${widget.order.orderTicket}", 4, 1);
    }
    bluetooth.printCustom("Ticket Type: $ticketType", 2, 1);

    String dateTime = "";
    if (widget.order.date != null && widget.order.time != null) {
      dateTime = "${widget.order.date} ${widget.order.time}";
    }
    bluetooth.printCustom(dateTime, 1, 1);
    bluetooth.printNewLine();

    if (items.isNotEmpty) {
      for (final item in items) {
        bluetooth.printLeftRight("${item.item?.itemName ?? 'Unknown'}", "x${item.itemQuantity}", 1);
      }
    } else {
      bluetooth.printCustom("No items", 1, 1);
    }

    bluetooth.printNewLine();
    bluetooth.printCustom("Thank you!", 2, 1);
    bluetooth.printNewLine();
    bluetooth.paperCut();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isConnected ? printTickets : null,
      child: const Text("Print Tickets"),
    );
  }
}
