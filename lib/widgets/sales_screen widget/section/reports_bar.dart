import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/screen/sales/sales_summary_screen.dart';
import 'package:quicserve_flutter/widgets/sales_screen%20widget/section/report_section.dart';

class ReportsBar extends StatefulWidget {
  const ReportsBar({
    super.key,
  });

  @override
  State<ReportsBar> createState() => _ReportsBarState();
}

class _ReportsBarState extends State<ReportsBar> {
  bool isLoading = false;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 15,
            child: Builder(
              builder: (context) {
                switch (selectedIndex) {
                  case 0:
                    return const SalesSummaryScreen();
                  case 1:
                    return Container(
                      margin: const EdgeInsets.all(60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/undermaintenance.png'),
                          SizedBox(height: 20),
                          Text(
                            "This page is currently in construction",
                            style: CustomFont.calibribold48.copyWith(
                              color: AppColors.black,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "We hope to be back soon",
                            style: CustomFont.calibri22.copyWith(
                              color: AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  case 2:
                    return Container(
                      margin: const EdgeInsets.all(60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/undermaintenance.png'),
                          SizedBox(height: 20),
                          Text(
                            "This page is currently in construction",
                            style: CustomFont.calibribold48.copyWith(
                              color: AppColors.black,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "We hope to be back soon",
                            style: CustomFont.calibri22.copyWith(
                              color: AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  case 3:
                    return Container(
                      margin: const EdgeInsets.all(60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/undermaintenance.png'),
                          SizedBox(height: 20),
                          Text(
                            "This page is currently in construction",
                            style: CustomFont.calibribold48.copyWith(
                              color: AppColors.black,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "We hope to be back soon",
                            style: CustomFont.calibri22.copyWith(
                              color: AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  default:
                    return Center(child: Text('No report selected'));
                }
              },
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.teal,
                    AppColors.blue.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                    child: _topTitle(
                      context,
                      title: 'Reports',
                    ),
                  ),
                  ReportSection(
                    labels: const [
                      'Sales Summary',
                      'Payment Method',
                      'Category Sold',
                      'Item Sold',
                    ],
                    initialIndex: 0,
                    onSelected: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                      print('Selected: $index');
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topTitle(
    BuildContext context, {
    required String title,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: CustomFont.daysone32.copyWith(
                    fontSize: 30,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
