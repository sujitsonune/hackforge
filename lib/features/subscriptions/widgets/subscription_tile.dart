import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../models/subscription_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/constants/ott_platforms.dart';

class SubscriptionTile extends StatelessWidget {
  final SubscriptionModel subscription;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleActive;

  const SubscriptionTile({
    super.key,
    required this.subscription,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final platform = OTTPlatforms.getPlatformById(subscription.category.toLowerCase().replaceAll(' ', '_'));
    final daysUntilRenewal = subscription.daysUntilRenewal;
    final isRenewalSoon = daysUntilRenewal <= 7 && daysUntilRenewal > 0;
    final isOverdue = daysUntilRenewal < 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (_) => onToggleActive?.call(),
              backgroundColor: subscription.isActive ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              icon: subscription.isActive ? Icons.pause : Icons.play_arrow,
              label: subscription.isActive ? 'Pause' : 'Resume',
            ),
            SlidableAction(
              onPressed: (_) => onDelete?.call(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isOverdue 
                      ? Colors.red.shade300
                      : isRenewalSoon 
                          ? Colors.orange.shade300
                          : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  // Platform Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: platform != null
                          ? Color(int.parse(platform.color.replaceFirst('#', '0xFF')))
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: subscription.logoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                subscription.logoUrl!,
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    subscription.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Text(
                              subscription.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Subscription Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subscription.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: subscription.isActive 
                                      ? null 
                                      : Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!subscription.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Paused',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subscription.category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              CurrencyFormatter.formatIndianCurrency(subscription.cost),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              ' / ${_getBillingCycleName(subscription.billingCycle)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Renewal Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? Colors.red.shade100
                              : isRenewalSoon
                                  ? Colors.orange.shade100
                                  : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isOverdue
                              ? 'Overdue'
                              : isRenewalSoon
                                  ? '${daysUntilRenewal}d left'
                                  : '${daysUntilRenewal}d left',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isOverdue
                                ? Colors.red.shade700
                                : isRenewalSoon
                                    ? Colors.orange.shade700
                                    : Colors.green.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${subscription.nextBilling.day}/${subscription.nextBilling.month}/${subscription.nextBilling.year}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getBillingCycleName(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.weekly:
        return 'week';
      case BillingCycle.monthly:
        return 'month';
      case BillingCycle.quarterly:
        return '3 months';
      case BillingCycle.halfYearly:
        return '6 months';
      case BillingCycle.yearly:
        return 'year';
    }
  }
}