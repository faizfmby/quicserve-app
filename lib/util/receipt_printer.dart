import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:quicserve_flutter/models/order.dart';

import 'package:quicserve_flutter/models/order_item.dart';
import 'package:quicserve_flutter/models/order_receipts.dart';
import 'package:quicserve_flutter/models/sales.dart';

class ReceiptPrinter {
  static Future<void> printOrderReceipt({
    required BlueThermalPrinter printer,
    required List<OrderItem> items,
    required String orderID,
    required double totalAmount,
    required String paymentMethod,
    required double paidAmount,
    required double changeAmount,
    required OrderReceipts receipt,
  }) async {
    final Map<String, OrderItem> combinedItems = {};
    for (final item in items) {
      final itemID = item.item?.itemID;
      if (itemID == null) continue;

      if (combinedItems.containsKey(itemID)) {
        final existing = combinedItems[itemID]!;
        final newQty = (existing.itemQuantity ?? 0) + (item.itemQuantity ?? 0);
        combinedItems[itemID] = OrderItem(
          item: item.item,
          itemQuantity: newQty,
        );
      } else {
        combinedItems[itemID] = OrderItem(
          item: item.item,
          itemQuantity: item.itemQuantity ?? 0,
        );
      }
    }

    String formattedTime = '-';
    if (receipt.order?.time != null) {
      try {
        final parsedTime = DateFormat("HH:mm:ss").parse(receipt.order!.time!);
        formattedTime = DateFormat("hh:mm a").format(parsedTime);
      } catch (e) {
        print('Time formatting error: $e');
      }
    }

    printer.printNewLine();
    printer.printCustom("Rumah Popia", 2, 1);
    printer.printCustom("Jalan Rumah Murah", 1, 1);
    printer.printCustom("Binjai, 24000", 1, 1);
    printer.printCustom("Kemaman, Terengganu", 1, 1);
    printer.printCustom("No Phone: +60 13-941 1895", 1, 1);
    printer.printNewLine();

    printer.printNewLine();
    printer.printCustom("ORDER TICKET", 2, 1);
    printer.printCustom(receipt.order?.orderTicket ?? '', 4, 1);
    printer.printNewLine();

    printer.printCustom("Receipt ID:".padRight(24) + "${receipt.receiptID ?? "-"}".padLeft(24), 1, 1);
    printer.printCustom("Order ID:".padRight(24) + "${receipt.orderID ?? "-"}".padLeft(24), 1, 1);
    printer.printCustom("Date:".padRight(24) + "${receipt.order?.date ?? "-"}".padLeft(24), 1, 1);
    printer.printCustom("Time:".padRight(24) + formattedTime.padLeft(24), 1, 1);
    printer.printCustom("Cashier:".padRight(24) + "${receipt.order?.staff?.name ?? "-"}".padLeft(24), 1, 1);
    printer.printCustom('------------------------------------------------', 1, 1);
    printer.printCustom('Item'.padRight(24) + 'Qty   Price   Amount'.padLeft(24), 1, 1);
    printer.printCustom('------------------------------------------------', 1, 1);

    for (final item in combinedItems.values) {
      final name = '${item.item!.itemID} ${item.item?.itemName ?? 'Unknown'}';
      final qty = item.itemQuantity ?? 0;
      final price = item.item?.price ?? 0.0;
      final total = price * qty;

      // Trim name if longer than 20 chars
      final trimmedName = name.length > 20 ? name.substring(0, 20) : name;

      final line = trimmedName.padRight(20) + qty.toString().padLeft(10) + price.toStringAsFixed(2).padLeft(9) + total.toStringAsFixed(2).padLeft(9);

      printer.printCustom(line, 1, 0);
    }

    printer.printCustom("------------------------------------------------", 1, 1);
    printer.printCustom('Total'.padRight(24) + 'RM${totalAmount.toStringAsFixed(2)}'.padLeft(24), 1, 1);
    printer.printCustom('Paid'.padRight(24) + 'RM${paidAmount.toStringAsFixed(2)}'.padLeft(24), 1, 1);
    printer.printCustom("------------------------------------------------", 1, 1);
    printer.printCustom('Change'.padRight(24) + 'RM${changeAmount.toStringAsFixed(2)}'.padLeft(24), 1, 1);
    printer.printCustom('Payment'.padRight(24) + paymentMethod.padLeft(24), 1, 1);
    printer.printCustom("Trans No:".padRight(24) + "${receipt.order?.sales?.salesID ?? 0}".padLeft(24), 1, 1);
    printer.printCustom("Trans Date:".padRight(24) + "${receipt.order?.sales?.salesDate ?? 0}".padLeft(24), 1, 1);
    printer.printNewLine();

    printer.printCustom("FOR ONGOING PROMOS", 2, 1);
    printer.printCustom("please follow us on TikTok", 1, 1);
    printer.printCustom("https://www.tiktok.com/@rumah_popia", 1, 1);
    printer.printCustom("SCAN THIS QR", 2, 1);
    printer.printQRcode('https://www.tiktok.com/@rumah_popia?_t=ZS-8xtGwxCzfQV&_r=1', 200, 200, 1);
    printer.printCustom("Instagram page:", 1, 1);
    printer.printCustom("https://www.instagram.com/rumah_popia", 1, 1);
    printer.printNewLine();
    printer.printCustom("THANK YOU,", 2, 1);
    printer.printCustom("PLEASE COME AGAIN!", 2, 1);
    printer.printNewLine();
    printer.printCustom("------------------------------------------------", 1, 1);
    printer.printNewLine();
    printer.printCustom("POS System Provider:", 1, 1);
    printer.printNewLine();

    final ByteData data = await rootBundle.load('assets/images/ic_launcher_foreground.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final decoded = img.decodeImage(bytes);

    if (decoded != null) {
      await printer.printImageBytes(Uint8List.fromList(img.encodePng(decoded)));
    }

    printer.printNewLine();
    printer.printCustom("QUICSERVE", 2, 1);
    printer.printCustom("A Smart POS Solution", 1, 1);
    printer.printCustom("Made by:", 1, 1);
    printer.printCustom("Faiz Mullah bin Yusof", 1, 1);
    printer.printNewLine();

    printer.paperCut();
  }

  static Future<void> printTicket({
    required BlueThermalPrinter printer,
    required List<Order> orderDetails,
    required String orderID,
    required List<OrderItem> items,
  }) async {
    final order = orderDetails.firstWhere(
      (o) => o.orderID == orderID,
      orElse: () => Order(),
    );

    final Map<String, OrderItem> combinedItems = {};
    for (final item in items) {
      final itemID = item.item?.itemID;
      if (itemID == null) continue;

      if (combinedItems.containsKey(itemID)) {
        final existing = combinedItems[itemID]!;
        final newQty = (existing.itemQuantity ?? 0) + (item.itemQuantity ?? 0);
        combinedItems[itemID] = OrderItem(
          item: item.item,
          itemQuantity: newQty,
        );
      } else {
        combinedItems[itemID] = OrderItem(
          item: item.item,
          itemQuantity: item.itemQuantity ?? 0,
        );
      }
    }

    String formattedTime = '-';
    if (order.time != null) {
      try {
        final parsedTime = DateFormat("HH:mm:ss").parse(order.time!);
        formattedTime = DateFormat("hh:mm a").format(parsedTime);
      } catch (e) {
        print('Time formatting error: $e');
      }
    }

    for (final entry in combinedItems.entries) {
      final item = entry.value;
      final name = item.item?.itemName ?? 'Unknown';
      final qty = 'x${item.itemQuantity}';

      printer.printNewLine();
      printer.printCustom("ORDER TICKET", 2, 1);
      if (order.orderTicket != null) {
        printer.printCustom(order.orderTicket!, 4, 1);
      }

      printer.printNewLine();
      printer.printCustom("Date:".padRight(24) + "${order.date ?? "-"}".padLeft(24), 1, 1);
      printer.printCustom("Time:".padRight(24) + formattedTime.padLeft(24), 1, 1);
      printer.printCustom('------------------------------------------------', 1, 1);

      printer.printCustom(
        '${qty} ' + '${item.item!.itemID} ${name}',
        4,
        0,
      );

      printer.printNewLine();
      printer.printNewLine();
      printer.printNewLine();
      printer.paperCut();
    }
  }

  static Future<void> printSalesSummary({
    required BlueThermalPrinter printer,
    required SalesSummary salesSummary,
    required DateTime selectedDate,
  }) async {
    final dateStr = DateFormat('dd MMM yyyy').format(selectedDate);

    printer.printNewLine();
    printer.printCustom("Rumah Popia", 2, 1);
    printer.printCustom("Jalan Rumah Murah", 1, 1);
    printer.printCustom("Binjai, 24000", 1, 1);
    printer.printCustom("Kemaman, Terengganu", 1, 1);
    printer.printCustom("No Phone: +60 13-941 1895", 1, 1);
    printer.printNewLine();

    printer.printCustom("SALES SUMMARY", 2, 1);
    printer.printCustom("Date:".padRight(24) + dateStr.padLeft(24), 1, 1);
    printer.printCustom("------------------------------------------------", 1, 1);

    // Net Sales
    printer.printCustom("Net Sales".padRight(24) + 'RM${(salesSummary.netSales ?? 0.0).toStringAsFixed(2)}'.padLeft(24), 1, 1);
    printer.printCustom("Total".padRight(24) + 'RM${(salesSummary.netSales ?? 0.0).toStringAsFixed(2)}'.padLeft(24), 1, 1);
    printer.printCustom("------------------------------------------------", 1, 1);

    // Payment Methods
    final paymentTypeNames = {
      4: 'Cash Payment',
      6: 'Online Banking',
      5: 'Credit Card',
      2: 'E-Wallet',
      7: 'DuitNow QR',
    };

    final paymentAmounts = List<double>.filled(paymentTypeNames.length, 0.0);
    if (salesSummary.paymentMethodTotals != null) {
      for (var payment in salesSummary.paymentMethodTotals!) {
        final index = paymentTypeNames.keys.toList().indexOf(payment.paymentID ?? -1);
        if (index != -1) {
          paymentAmounts[index] = payment.totalAmount ?? 0.0;
        }
      }
    }

    for (int i = 0; i < paymentTypeNames.length; i++) {
      final name = paymentTypeNames.values.toList()[i];
      final amount = paymentAmounts[i];
      printer.printCustom(name.padRight(24) + 'RM${amount.toStringAsFixed(2)}'.padLeft(24), 1, 1);
    }

    printer.printCustom("------------------------------------------------", 1, 1);

    // Total Collected
    printer.printCustom("Total Collected".padRight(24) + 'RM${(salesSummary.netSales ?? 0.0).toStringAsFixed(2)}'.padLeft(24), 1, 1);

    // Unpaid
    final unpaid = salesSummary.unpaidOrders?.toStringAsFixed(2) ?? '0.00';
    printer.printCustom("Unpaid Order".padRight(24) + 'RM$unpaid'.padLeft(24), 1, 1);
    printer.printCustom("------------------------------------------------", 1, 1);

    // Confirmation Section
    printer.printNewLine();
    printer.printCustom("CONFIRMATION", 2, 1);
    printer.printNewLine();
    printer.printCustom("Manager Signature / Chop", 1, 0);
    printer.printCustom("".padRight(48, '_'), 1, 0);
    printer.printNewLine();
    printer.printCustom("Name:".padRight(12) + "".padRight(36, '_'), 1, 0);
    printer.printNewLine();
    printer.printCustom("Date:".padRight(12) + "".padRight(36, '_'), 1, 0);
    printer.printNewLine();

    printer.printCustom("------------------------------------------------", 1, 1);
    printer.printNewLine();
    printer.paperCut();
  }
}
