import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';

class SegmentedToggle extends StatefulWidget {
  final List<String> labels;
  final ValueChanged<int> onSelected;
  final int initialIndex;

  const SegmentedToggle({
    super.key,
    required this.labels,
    required this.onSelected,
    this.initialIndex = 0,
  });

  @override
  State<SegmentedToggle> createState() => _SegmentedToggleState();
}

class _SegmentedToggleState extends State<SegmentedToggle> {
  late int selectedIndex;

  @override
  void initState() {
    selectedIndex = widget.initialIndex;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SegmentedToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        selectedIndex = widget.initialIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double itemWidth = (constraints.maxWidth - 8) / widget.labels.length;

      return Container(
        height: 40,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Color(0xFFD7D7D7).withOpacity(0.8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment(-1.0 + (2.0 / (widget.labels.length - 1)) * selectedIndex, 0),
              child: Container(
                width: itemWidth,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(blurRadius: 15, color: AppColors.black.withOpacity(0.2))
                  ],
                ),
              ),
            ),
            Row(
              children: List.generate(widget.labels.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => selectedIndex = index);
                      widget.onSelected(index);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.labels[index],
                        style: CustomFont.calibri16.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selectedIndex == index ? Colors.black : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}
