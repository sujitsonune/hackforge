import 'package:flutter/material.dart';

import '../../../models/subscription_model.dart';

class BillingCycleSelector extends StatelessWidget {
  final BillingCycle selectedCycle;
  final Function(BillingCycle) onCycleChanged;

  const BillingCycleSelector({
    super.key,
    required this.selectedCycle,
    required this.onCycleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Cycle',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BillingCycle.values.map((cycle) {
            final isSelected = selectedCycle == cycle;
            return FilterChip(
              label: Text(_getBillingCycleName(cycle)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onCycleChanged(cycle);
                }
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getBillingCycleName(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.weekly:
        return 'Weekly';
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.quarterly:
        return 'Quarterly';
      case BillingCycle.halfYearly:
        return 'Half Yearly';
      case BillingCycle.yearly:
        return 'Yearly';
    }
  }
}