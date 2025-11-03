import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';

class _RecommendationBanner extends StatelessWidget {
  final String suggestedItem;
  final VoidCallback onAddSuggested;

  const _RecommendationBanner({
    required this.suggestedItem,
    required this.onAddSuggested,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                'AI Recommends: Add $suggestedItem?',
                style: CustomFont.calibri16.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onAddSuggested,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            ),
            child: Text(
              'Yes, Add',
              style: CustomFont.calibri16.copyWith(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
