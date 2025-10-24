import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quicserve_flutter/constants/custom_icon.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/models/sales.dart';
import 'package:quicserve_flutter/services/api/reports_services.dart';
import 'package:quicserve_flutter/util/receipt_printer.dart';
import 'package:quicserve_flutter/widgets/alert_message.dart';

class SalesSummaryScreen extends StatefulWidget {
  const SalesSummaryScreen({super.key});

  @override
  State<SalesSummaryScreen> createState() => _SalesSummaryScreenState();
}

class _SalesSummaryScreenState extends State<SalesSummaryScreen> {
  bool isLoading = false;
  DateTime _selectedDate = DateTime.now();
  Future<SalesSummary>? futureSalesSummary;
  SalesSummary? salesSummary;

  @override
  void initState() {
    super.initState();
    _loadSalesSummary();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.orange2,
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.orange2,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _loadSalesSummary();
      });
    }
  }

  void _loadSalesSummary() async {
    setState(() {
      isLoading = true;
      salesSummary = null;
    });
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
      print('Fetching sales summary for date: $dateString');
      futureSalesSummary = ReportsServices().fetchSalesSummary(date: dateString);
      final result = await futureSalesSummary!;
      print('Received sales summary: ${result.toJson()}');
      setState(() {
        salesSummary = result;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading sales summary: $e');
      setState(() {
        salesSummary = null;
        isLoading = false;
      });
      AlertMessage.showError(context, 'Failed to load sales summary: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building UI, isLoading: $isLoading, salesSummary: ${salesSummary != null}');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 14,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                      'Sales Summary',
                      style: CustomFont.daysone14.copyWith(fontSize: 16),
                    ),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: _loadSalesSummary,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11.5),
                                      backgroundColor: AppColors.lightgrey2,
                                      foregroundColor: AppColors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: const Icon(
                                      AppIcons.refresh,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _selectDate(context),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.black,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                      ),
                                      child: Ink(
                                        height: 50,
                                        decoration: BoxDecoration(gradient: AppColors.gradient2, borderRadius: BorderRadius.circular(5)),
                                        child: Center(child: Text(DateFormat('dd MMM, yyyy').format(_selectedDate))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: isLoading ? const Center(child: CircularProgressIndicator()) : _buildSalesDetail(salesSummary: salesSummary!),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      final printer = BlueThermalPrinter.instance;
                      final isConnected = await printer.isConnected ?? false;

                      if (!isConnected) {
                        AlertMessage.showError(context, 'Printer not connected');
                        return;
                      }

                      if (salesSummary != null) {
                        await ReceiptPrinter.printSalesSummary(
                          printer: printer,
                          salesSummary: salesSummary!,
                          selectedDate: _selectedDate,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.orange1,
                      foregroundColor: Colors.black,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(),
                    ),
                    child: Ink(
                      height: 55,
                      decoration: BoxDecoration(gradient: AppColors.gradient2),
                      child: const Center(
                        child: Text(
                          'Print',
                          style: CustomFont.calibri16,
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

  Widget _buildSalesDetail({required SalesSummary salesSummary}) {
    // List of payment method names
    final paymentTypeNames = {
      4: 'Cash Payment',
      6: 'Online Banking',
      5: 'Credit Card',
      2: 'E-Wallet',
      7: 'DuitNow QR',
    };

    final paymenetAmounts = List<double>.filled(paymentTypeNames.length, 0.0);
    if (salesSummary.paymentMethodTotals != null) {
      for (var payment in salesSummary.paymentMethodTotals!) {
        final index = paymentTypeNames.keys.toList().indexOf(payment.paymentID ?? -1);
        if (index != -1) {
          paymenetAmounts[index] = payment.totalAmount ?? 0.0;
        }
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'sales summary'.toUpperCase(),
          style: CustomFont.calibri16.copyWith(color: AppColors.lightgrey3),
        ),
        Divider(
          color: AppColors.lightgrey3.withOpacity(0.5),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Net Sales',
              style: CustomFont.calibribold22,
            ),
            Text(
              (salesSummary.netSales ?? 0.0).toStringAsFixed(2),
              style: CustomFont.calibribold22,
            ),
          ],
        ),
        Divider(
          color: AppColors.lightgrey3.withOpacity(0.5),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: CustomFont.calibribold22,
            ),
            Text(
              (salesSummary.netSales ?? 0.0).toStringAsFixed(2),
              style: CustomFont.calibribold22,
            ),
          ],
        ),
        Divider(
          color: AppColors.lightgrey3.withOpacity(0.5),
        ),
        // Dynamically generate the payment type rows
        for (int i = 0; i < paymentTypeNames.length; i++)
          Column(
            children: [
              _buildPaymentTypeRow(paymentTypeNames.values.toList()[i], paymenetAmounts[i]),
              Divider(
                color: AppColors.lightgrey3.withOpacity(0.5),
              ),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Collected',
              style: CustomFont.calibribold22,
            ),
            Text(
              (salesSummary.netSales ?? 0.0).toStringAsFixed(2),
              style: CustomFont.calibribold22,
            ),
          ],
        ),
        Divider(
          color: AppColors.lightgrey3.withOpacity(0.5),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Unpaid Order',
              style: CustomFont.calibribold22.copyWith(color: Colors.red),
            ),
            Text(
              '${salesSummary.unpaidOrders!.toStringAsFixed(2)}',
              style: CustomFont.calibribold22.copyWith(color: Colors.red),
            ),
          ],
        ),
        Divider(
          color: AppColors.lightgrey3.withOpacity(0.5),
        ),
      ],
    );
  }

  Widget _buildPaymentTypeRow(String name, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Optional: for better spacing
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 25),
          Text(
            name,
            style: CustomFont.calibri22,
          ),
          const Spacer(),
          Text(
            value.toStringAsFixed(2),
            style: CustomFont.calibri22,
          ),
        ],
      ),
    );
  }
}
