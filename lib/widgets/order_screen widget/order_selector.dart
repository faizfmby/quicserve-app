import 'package:flutter/material.dart';

class OrderStatusSelector extends StatefulWidget {
  final List<String> options;
  final ValueChanged<int> onChanged;

  const OrderStatusSelector({
    super.key,
    required this.options,
    required this.onChanged,
  });

  @override
  State<OrderStatusSelector> createState() => _OrderStatusSelectorState();
}

class _OrderStatusSelectorState extends State<OrderStatusSelector> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment(-1 + (_selectedIndex * 1.0), 0),
            child: FractionallySizedBox(
              widthFactor: 1 / widget.options.length,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Row(
            children: List.generate(widget.options.length, (index) {
              final isSelected = _selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    widget.onChanged(index);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      widget.options[index],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.black54,
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
  }
}
