import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/ott_platforms.dart';

class CostInputField extends StatefulWidget {
  final TextEditingController controller;
  final OTTPlatform? selectedPlatform;

  const CostInputField({
    super.key,
    required this.controller,
    this.selectedPlatform,
  });

  @override
  State<CostInputField> createState() => _CostInputFieldState();
}

class _CostInputFieldState extends State<CostInputField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            labelText: 'Cost',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.currency_rupee),
            suffixText: 'INR',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the cost';
            }
            final cost = double.tryParse(value);
            if (cost == null || cost <= 0) {
              return 'Please enter a valid cost';
            }
            return null;
          },
        ),
        if (widget.selectedPlatform != null &&
            widget.selectedPlatform!.popularPlans.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Popular Plans:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.selectedPlatform!.popularPlans.map((plan) {
              return ActionChip(
                label: Text('₹${plan.toInt()}'),
                onPressed: () {
                  widget.controller.text = plan.toString();
                },
                backgroundColor: Colors.grey.shade100,
                side: BorderSide(color: Colors.grey.shade300),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}