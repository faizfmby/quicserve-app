import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/widgets/side_menu.dart';

class ChangeDialog extends StatefulWidget {
  final double change;

  const ChangeDialog({
    super.key,
    required this.change,
  });

  @override
  State<ChangeDialog> createState() => _ChangeDialogState();
}

class _ChangeDialogState extends State<ChangeDialog> {
  late double change;
  int _countdownSeconds = 5;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    change = widget.change;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdownSeconds > 0) {
            _countdownSeconds--;
          } else {
            timer.cancel();
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const SideMenu2()), (Route<dynamic> route) => false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 520,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.teal,
                          AppColors.blue
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Center(
                      child: Text('Payment Successful !', style: CustomFont.daysone14.copyWith(color: AppColors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.print_rounded,
                        color: AppColors.black,
                        size: 25,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Printing receipt..',
                        style: CustomFont.calibri20,
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.black, thickness: 0.5, indent: 30, endIndent: 30),
                  const Text(
                    'Change',
                    style: CustomFont.calibri22,
                  ),
                  Text(
                    'RM${widget.change.toStringAsFixed(2)}',
                    style: CustomFont.calibribold36.copyWith(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Redirecting in ${_countdownSeconds}s...',
                    style: CustomFont.calibri16.copyWith(color: AppColors.black),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                    child: ElevatedButton(
                      onPressed: () {
                        _timer.cancel();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const SideMenu2()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: AppColors.gradient1,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          alignment: Alignment.center,
                          child: Text(
                            'Back to Homepage',
                            style: CustomFont.calibri16.copyWith(color: AppColors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
