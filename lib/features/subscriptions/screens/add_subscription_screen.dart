import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/ott_platforms.dart';
import '../../../models/subscription_model.dart';
import '../../../features/authentication/providers/auth_provider.dart' as auth;
import '../providers/subscription_provider.dart';
import '../widgets/platform_dropdown.dart';
import '../widgets/billing_cycle_selector.dart';
import '../widgets/cost_input_field.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _descriptionController = TextEditingController();

  OTTPlatform? _selectedPlatform;
  BillingCycle _selectedBillingCycle = BillingCycle.monthly;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  bool _reminderEnabled = true;
  List<int> _reminderDays = [7, 3, 1];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onPlatformSelected(OTTPlatform? platform) {
    setState(() {
      _selectedPlatform = platform;
      if (platform != null) {
        _nameController.text = platform.name;
        if (platform.popularPlans.isNotEmpty) {
          _costController.text = platform.popularPlans.first.toString();
        }
      }
    });
  }

  void _onBillingCycleChanged(BillingCycle cycle) {
    setState(() {
      _selectedBillingCycle = cycle;
      _updateNextBillingDate();
    });
  }

  void _updateNextBillingDate() {
    final now = DateTime.now();
    switch (_selectedBillingCycle) {
      case BillingCycle.weekly:
        _nextBillingDate = now.add(const Duration(days: 7));
        break;
      case BillingCycle.monthly:
        _nextBillingDate = DateTime(now.year, now.month + 1, now.day);
        break;
      case BillingCycle.quarterly:
        _nextBillingDate = DateTime(now.year, now.month + 3, now.day);
        break;
      case BillingCycle.halfYearly:
        _nextBillingDate = DateTime(now.year, now.month + 6, now.day);
        break;
      case BillingCycle.yearly:
        _nextBillingDate = DateTime(now.year + 1, now.month, now.day);
        break;
    }
  }

  Future<void> _saveSubscription() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final subscription = SubscriptionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: context.read<auth.AuthProvider>().user?.uid ?? 'anonymous',
        name: _nameController.text.trim(),
        category: _selectedPlatform?.category ?? 'Other',
        cost: double.parse(_costController.text),
        billingCycle: _selectedBillingCycle,
        nextBilling: _nextBillingDate,
        paymentMethod: _selectedPaymentMethod,
        reminderEnabled: _reminderEnabled,
        reminderDays: _reminderDays,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        logoUrl: _selectedPlatform?.logoUrl,
      );

      await context.read<SubscriptionProvider>().addSubscription(subscription);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding subscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Subscription'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Platform Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Platform',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      PlatformDropdown(
                        selectedPlatform: _selectedPlatform,
                        onPlatformSelected: _onPlatformSelected,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Basic Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Subscription Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.subscriptions),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a subscription name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CostInputField(
                        controller: _costController,
                        selectedPlatform: _selectedPlatform,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Billing Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Billing Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      BillingCycleSelector(
                        selectedCycle: _selectedBillingCycle,
                        onCycleChanged: _onBillingCycleChanged,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<PaymentMethod>(
                        value: _selectedPaymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.payment),
                        ),
                        items: PaymentMethod.values.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(_getPaymentMethodName(method)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _nextBillingDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 1095)),
                          );
                          if (date != null) {
                            setState(() {
                              _nextBillingDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Next Billing Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${_nextBillingDate.day}/${_nextBillingDate.month}/${_nextBillingDate.year}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reminder Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminder Settings',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Enable Reminders'),
                        subtitle: const Text('Get notified before renewal'),
                        value: _reminderEnabled,
                        onChanged: (value) {
                          setState(() {
                            _reminderEnabled = value;
                          });
                        },
                      ),
                      if (_reminderEnabled) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Remind me before:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [7, 3, 1].map((days) {
                            final isSelected = _reminderDays.contains(days);
                            return FilterChip(
                              label: Text('$days day${days > 1 ? 's' : ''}'),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _reminderDays.add(days);
                                  } else {
                                    _reminderDays.remove(days);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSubscription,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Subscription'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.netBanking:
        return 'Net Banking';
      case PaymentMethod.wallet:
        return 'Digital Wallet';
      case PaymentMethod.emi:
        return 'EMI';
    }
  }
}