import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../models/subscription_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_tile.dart';
import 'add_subscription_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscriptions'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'All'),
            Tab(text: 'Analytics'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<SubscriptionProvider>().refresh();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveSubscriptionsTab(),
          _buildAllSubscriptionsTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddSubscriptionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActiveSubscriptionsTab() {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        final activeSubscriptions = provider.activeSubscriptions;
        final overdueSubscriptions = provider.getOverdueSubscriptions();
        final renewingSoon = provider.getSubscriptionsNeedingRenewal(7);

        return RefreshIndicator(
          onRefresh: () async {
            await provider.refresh();
          },
          child: CustomScrollView(
            slivers: [
              // Summary Cards
              SliverToBoxAdapter(
                child: _buildSummaryCards(provider),
              ),

              // Overdue Subscriptions
              if (overdueSubscriptions.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Overdue Subscriptions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 300),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildSubscriptionTile(
                              overdueSubscriptions[index],
                              provider,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: overdueSubscriptions.length,
                  ),
                ),
              ],

              // Renewing Soon
              if (renewingSoon.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Renewing Soon',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index + overdueSubscriptions.length,
                        duration: const Duration(milliseconds: 300),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildSubscriptionTile(
                              renewingSoon[index],
                              provider,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: renewingSoon.length,
                  ),
                ),
              ],

              // All Active Subscriptions
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'All Active Subscriptions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if (activeSubscriptions.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.subscriptions, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No active subscriptions'),
                          Text('Tap + to add your first subscription'),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 300),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildSubscriptionTile(
                              activeSubscriptions[index],
                              provider,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: activeSubscriptions.length,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllSubscriptionsTab() {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        List<SubscriptionModel> filteredSubscriptions = provider.subscriptions;

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          filteredSubscriptions = filteredSubscriptions.where((subscription) =>
              subscription.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              subscription.category.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        // Apply category filter
        if (_selectedFilter != 'All') {
          filteredSubscriptions = filteredSubscriptions
              .where((subscription) => subscription.category == _selectedFilter)
              .toList();
        }

        return Column(
          children: [
            // Search and Filter
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search subscriptions...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Video Streaming', 'Music Streaming', 'Gaming', 'Cloud Storage', 'Productivity']
                          .map((category) {
                        final isSelected = _selectedFilter == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = selected ? category : 'All';
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Subscriptions List
            Expanded(
              child: filteredSubscriptions.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No subscriptions found'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredSubscriptions.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 300),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _buildSubscriptionTile(
                                filteredSubscriptions[index],
                                provider,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        final monthlySpend = provider.getTotalMonthlySpending();
        final yearlySpend = provider.getTotalYearlySpending();
        final categorySpending = provider.getMonthlySpendingByCategory();
        final billingDistribution = provider.getBillingCycleDistribution();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spending Overview
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('Monthly Spend'),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.formatIndianCurrency(monthlySpend),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('Yearly Spend'),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.formatIndianCurrency(yearlySpend),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Breakdown
              const Text(
                'Spending by Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...categorySpending.entries.map((entry) {
                final percentage = monthlySpend > 0 ? (entry.value / monthlySpend) * 100 : 0;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatIndianCurrency(entry.value),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Billing Cycle Distribution
              const Text(
                'Billing Cycles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...billingDistribution.entries.map((entry) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getBillingCycleName(entry.key),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '${entry.value} subscription${entry.value != 1 ? 's' : ''}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(SubscriptionProvider provider) {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${provider.activeSubscriptions.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text('Active'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      CurrencyFormatter.formatIndianCurrency(provider.getTotalMonthlySpending()),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text('Monthly'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${provider.getOverdueSubscriptions().length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const Text('Overdue'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTile(SubscriptionModel subscription, SubscriptionProvider provider) {
    return SubscriptionTile(
      subscription: subscription,
      onTap: () {
        // TODO: Navigate to subscription details
      },
      onEdit: () {
        // TODO: Navigate to edit subscription
      },
      onDelete: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Subscription'),
            content: Text('Are you sure you want to delete ${subscription.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          try {
            await provider.deleteSubscription(subscription.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subscription deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error deleting subscription: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      },
      onToggleActive: () async {
        try {
          await provider.toggleSubscriptionStatus(subscription.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  subscription.isActive
                      ? 'Subscription paused'
                      : 'Subscription resumed',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating subscription: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
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