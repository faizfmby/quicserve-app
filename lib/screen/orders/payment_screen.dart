import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/models/order.dart';
import 'package:quicserve_flutter/models/order_item.dart';
import 'package:quicserve_flutter/models/order_receipts.dart';
import 'package:quicserve_flutter/models/payment_method.dart';
import 'package:quicserve_flutter/services/api/order_services.dart';
import 'package:quicserve_flutter/services/api/payment_method_services.dart';
import 'package:quicserve_flutter/services/api/reports_services.dart';
import 'package:quicserve_flutter/services/local/ticket_settings_storage.dart';
import 'package:quicserve_flutter/util/app_state.dart';
import 'package:quicserve_flutter/util/debounce.dart';
import 'package:quicserve_flutter/util/receipt_printer.dart';
import 'package:quicserve_flutter/widgets/alert_message.dart';
import 'package:quicserve_flutter/widgets/dialog/change_dialog.dart';
import 'package:quicserve_flutter/widgets/home_screen%20widget/section/order_section_payment.dart';
import 'package:quicserve_flutter/widgets/side_menu.dart';

class PaymentScreen2 extends StatefulWidget {
  final List<OrderItem> orderItems;
  final String? currentOrderId;
  final double subTotal;
  final double total;

  const PaymentScreen2({
    super.key,
    required this.orderItems,
    required this.currentOrderId,
    required this.subTotal,
    required this.total,
  });

  @override
  State<PaymentScreen2> createState() => _PaymentScreen2State();
}

class _PaymentScreen2State extends State<PaymentScreen2> {
  String selectedMethod = '';
  int enteredCents = 0;
  double totalAmount = 0.0;
  bool isFOHEnabled = false;
  bool isBOHEnabled = false;
  List<Order> orderDetails = [];
  List<String> selectedFOHCategories = [];
  List<String> selectedBOHCategories = [];

  List<PaymentMethod> paymentMethods = [];
  bool isLoadingPaymentMethods = true;

  @override
  void initState() {
    super.initState();
    totalAmount = widget.total;
    _loadTicketSettings();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final methods = await PaymentMethodServices().getPaymentMethod();
      setState(() {
        paymentMethods = methods;
        isLoadingPaymentMethods = false;
      });
    } catch (e) {
      print('Error fetching payment methods: $e');
      setState(() {
        paymentMethods = [];
        isLoadingPaymentMethods = false;
      });
    }
  }

  static const Map<String, int> _paymentMethodCodes = {
    'Cash Payment': 1,
    'Online Payment': 2,
    'Credit Card': 3,
    'E-Wallet': 4,
    'DuitNow QR': 5,
  };

  int _getPaymentMethodCode(String method) {
    return _paymentMethodCodes[method] ?? 0; // Default to 0 if method is invalid
  }

  void _loadTicketSettings() async {
    final fohEnabled = await TicketSettingsStorage.getFOHEnabled();
    final bohEnabled = await TicketSettingsStorage.getBOHEnabled();
    final fohCats = await TicketSettingsStorage.getFOHCategories();
    final bohCats = await TicketSettingsStorage.getBOHCategories();

    setState(() {
      isFOHEnabled = fohEnabled;
      isBOHEnabled = bohEnabled;
      selectedFOHCategories = fohCats;
      selectedBOHCategories = bohCats;
    });
  }

  String get enteredAmountFormatted {
    final amount = enteredCents / 100.0;
    return amount.toStringAsFixed(2);
  }

  List<double> _getReadyCashAmounts(double totalAmount) {
    final exact = totalAmount;
    final rounded = totalAmount.ceilToDouble();
    final multiples = [
      5.00,
      10.00,
      20.00,
      50.00,
      100.00
    ].where((amount) => amount > totalAmount).toList();

    final result = <double>[
      exact
    ];
    if (rounded != exact) {
      result.add(rounded);
    }
    result.addAll(multiples);

    return result;
  }

  Future<void> _confirmAndPrint() async {
    final double paid = double.tryParse(enteredAmountFormatted) ?? 0.0;
    final double change = selectedMethod == 'Cash Payment' ? paid - totalAmount : 0.0;

    if (selectedMethod.isEmpty) {
      AlertMessage.showError(context, 'Please select a payment method');
      return;
    }

    if (selectedMethod == 'Cash Payment' && (enteredCents / 100.0) < totalAmount) {
      AlertMessage.showError(context, 'Please enter sufficient cash');
      return;
    }

    try {
      if (widget.currentOrderId != null) {
        final paymentID = _getPaymentMethodCode(selectedMethod);
        if (paymentID == 0) {
          AlertMessage.showError(context, 'Invalid payment method selected');
          return;
        }

        print('Marking order ${widget.currentOrderId} as paid with paymentID: $paymentID');
        final response = await OrderServices().paidOrder(
          orderID: widget.currentOrderId!,
          paymentID: paymentID,
        );
        final message = response['message']?.toString().toLowerCase() ?? '';

        if (message != 'order marked as paid') {
          AlertMessage.showError(context, 'Failed to confirm order: ${response['message'] ?? 'Unknown error'}');
          return;
        }

        final receiptResponse = await ReportsServices().generateOrderReceipt(widget.currentOrderId!);
        final generated = receiptResponse['success'] ?? false;
        if (!generated) {
          AlertMessage.showError(context, 'Failed to generate receipt.');
          return;
        }

        final OrderReceipts latestReceipt = await ReportsServices().fetchLatestReceipt();

        final printer = BlueThermalPrinter.instance;
        final isConnected = await printer.isConnected ?? false;
        if (isConnected) {
          await ReceiptPrinter.printOrderReceipt(
            printer: printer,
            items: widget.orderItems,
            orderID: widget.currentOrderId!,
            totalAmount: totalAmount,
            paymentMethod: selectedMethod,
            paidAmount: paid,
            changeAmount: change,
            receipt: latestReceipt,
          );
        } else {
          AlertMessage.showError(context, 'Printer not connected.');
        }

        showChangeDialog(context, change);
        AppState().setStatusIndex(1);
        AppState().setSelectedOrder(widget.currentOrderId);
      }
    } catch (e) {
      print('Error confirming order: $e');
      AlertMessage.showError(context, 'Error confirming order: $e');
    }
  }

  Future<void> _saveOrder() async {
    try {
      final response = await OrderServices().saveOrder(orderID: widget.currentOrderId!);

      final message = response['message']?.toString().toLowerCase() ?? '';
      if (message == 'order status is updated') {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const SideMenu2()), (Route<dynamic> route) => false);
        AlertMessage.showSuccess(context, 'Order saved');
      } else {
        throw Exception('Failed to save order: $message');
      }
    } catch (e) {
      AlertMessage.showError(context, 'Error saving order: $e');
    }
  }

  void showChangeDialog(BuildContext context, double change) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => ChangeDialog(
        change: change,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double paid = double.tryParse(enteredAmountFormatted) ?? 0.0;
    final double change = selectedMethod == 'Cash Payment' ? paid - totalAmount : 0.0;

    return Scaffold(
      backgroundColor: AppColors.lightgrey1,
      body: Row(children: [
        Expanded(
          flex: 2,
          child: OrderSection(
            orderItems: widget.orderItems,
            currentOrderId: widget.currentOrderId,
            subTotal: widget.subTotal,
            total: widget.total,
          ),
        ),
        Expanded(
          flex: 6,
          child: _buildPaymentPanel(change),
        ),
      ]),
    );
  }

  Column _buildPaymentPanel(double change) {
    return Column(
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
              'Payment',
              style: CustomFont.daysone14.copyWith(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Total',
                            style: CustomFont.calibri16.copyWith(fontSize: 24, color: AppColors.black),
                          ),
                          SizedBox(width: 20),
                          Text(
                            'RM${totalAmount.toStringAsFixed(2)}',
                            style: CustomFont.daysone72.copyWith(fontSize: 44),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(30)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Cash Payment', style: TextStyle(fontSize: 18, color: AppColors.black)),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.lightgrey1,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'RM',
                                    style: CustomFont.calibri16.copyWith(fontSize: 30),
                                  ),
                                  Text(
                                    '$enteredAmountFormatted',
                                    style: CustomFont.calibri16.copyWith(fontSize: 30),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 28),
                              child: SizedBox(
                                height: 50,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _getReadyCashAmounts(totalAmount).length,
                                  itemBuilder: (context, index) {
                                    final amounts = _getReadyCashAmounts(totalAmount);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 4.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            final amountInCents = (amounts[index] * 100).round();
                                            enteredCents = amountInCents;
                                            selectedMethod = 'Cash Payment';
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.white,
                                          foregroundColor: AppColors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          'RM${amounts[index].toStringAsFixed(2)}',
                                          style: CustomFont.calibri16,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildKeypad(),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => setState(() => selectedMethod = 'Cash Payment'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 200, vertical: 12),
                                backgroundBuilder: (context, states, child) => Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: selectedMethod == 'Cash Payment' ? null : AppColors.gradient2,
                                  ),
                                  child: child,
                                ),
                              ),
                              child: Text(
                                selectedMethod == 'Cash Payment' ? 'Selected' : 'Select',
                                style: TextStyle(color: AppColors.black, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                    child: Column(
                      children: [
                        _buildPaymentMethodSection(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          decoration: BoxDecoration(
                            color: AppColors.darkgrey1,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              _infoRow('Payment Method', selectedMethod),
                              _infoRow('Total', 'RM${totalAmount.toStringAsFixed(2)}'),
                              const Divider(color: AppColors.white),
                              _infoRow('Change', 'RM${change.toStringAsFixed(2)}'),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: widget.currentOrderId == null || widget.orderItems.isEmpty ? null : _saveOrder,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Save Order',
                                    style: CustomFont.calibri16,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => debounceAsync(action: _confirmAndPrint),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.transparent,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(gradient: AppColors.gradient2, borderRadius: BorderRadius.circular(10)),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.print,
                                          size: 18,
                                          color: AppColors.black,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Confirm & Print',
                                          style: CustomFont.calibri16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    final keys = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'Reset',
      '0',
      '<',
    ];

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];
        return ElevatedButton(
          onPressed: () => _onDigitPress(key),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(key, style: const TextStyle(fontSize: 16)),
        );
      },
    );
  }

  void _onDigitPress(String value) {
    setState(() {
      if (value == 'Reset') {
        enteredCents = 0;
      } else if (value == '<') {
        enteredCents = (enteredCents / 10.0).toInt();
      } else {
        if (value == '0' && enteredCents == 0) return; // Avoid leading zeros
        final newValue = int.tryParse(value);
        if (newValue != null) {
          enteredCents = (enteredCents * 10) + newValue;
        }
      }
      selectedMethod = 'Cash Payment';
    });
  }

  Widget _buildPaymentMethodSection() {
    if (isLoadingPaymentMethods) {
      return const Center(child: CircularProgressIndicator());
    }

    if (paymentMethods.isEmpty) {
      return const Center(child: Text('No available payment methods.'));
    }

    return Column(
      children: paymentMethods.map(_buildMethodButton).toList(),
    );
  }

  Widget _buildMethodButton(PaymentMethod method) {
    final label = method.paymentType;
    final isSelected = selectedMethod == label;
    final isAvailable = method.status == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toString(),
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
          ElevatedButton(
            onPressed: isAvailable
                ? () {
                    setState(() {
                      selectedMethod = label.toString();
                      enteredCents = 0;
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 6),
              backgroundBuilder: (context, states, child) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: isSelected || !isAvailable ? null : AppColors.gradient2,
                ),
                child: child,
              ),
            ),
            child: Text(
              isSelected
                  ? 'Selected'
                  : isAvailable
                      ? 'Select'
                      : 'Unavailable',
              style: TextStyle(
                color: AppColors.black.withOpacity(isAvailable ? 1.0 : 0.5),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: CustomFont.calibribold18.copyWith(color: Colors.white, fontSize: 15)),
          Text(value, style: CustomFont.calibribold18.copyWith(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }
}
