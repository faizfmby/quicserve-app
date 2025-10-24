import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';

class ReportSection extends StatefulWidget {
  final List<String> labels;
  final ValueChanged<int> onSelected;
  final int initialIndex;

  const ReportSection({
    super.key,
    required this.labels,
    required this.onSelected,
    this.initialIndex = 0,
  });

  @override
  State<ReportSection> createState() => _ReportSectionState();
}

class _ReportSectionState extends State<ReportSection> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        /* gradient: const LinearGradient(
          colors: [
            Color(0xFF48A5AF),
            Color(0xFF5B9EA6)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ), */
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.labels.length, (index) {
          final bool isSelected = index == selectedIndex;

          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                  widget.onSelected(index);
                },
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: Alignment(-1.0 + (2.0 / (widget.labels.length - 1)) * selectedIndex, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
                    ),
                    child: Text(
                      widget.labels[index],
                      style: CustomFont.calibribold18.copyWith(
                        color: isSelected ? Colors.black : AppColors.lightgrey3.withOpacity(0.8),
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              if (index < widget.labels.length - 1)
                Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.4),
                  thickness: 0.7,
                  indent: 8,
                  endIndent: 8,
                ),
            ],
          );
        }),
      ),
    );
  }
}
