import 'package:flutter/material.dart';

import '../models/user_profile_model.dart';
import '../theme/app_theme.dart';

class WalletScreen extends StatefulWidget {
  final AppUser user;

  const WalletScreen({super.key, required this.user});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late final List<_ExpenseCategory> _categories;

  @override
  void initState() {
    super.initState();
    _categories = [
      _ExpenseCategory('Transport', 34, Icons.directions_car),
      _ExpenseCategory('Food', 46, Icons.restaurant),
      _ExpenseCategory('Tickets', 28, Icons.confirmation_number),
      _ExpenseCategory('Shopping', 18, Icons.shopping_bag_outlined),
      _ExpenseCategory('Buffer', 12, Icons.health_and_safety_outlined),
    ];
  }

  double get _spent =>
      _categories.fold(0, (total, category) => total + category.amount);

  void _addSpend(String label, double amount) {
    final index = _categories.indexWhere((item) => item.label == label);
    if (index == -1) return;
    setState(() {
      _categories[index] = _categories[index].copyWith(
        amount: _categories[index].amount + amount,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dailyBudget = switch (widget.user.preferences.budget) {
      BudgetPreference.low => 45.0,
      BudgetPreference.medium => 90.0,
      BudgetPreference.luxury => 220.0,
    };
    final remaining = dailyBudget - _spent;
    final progress = (_spent / dailyBudget).clamp(0.0, 1.3);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.midnight,
        title: const Text('Travel wallet'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.midnight, AppColors.obsidian],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily travel budget',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${dailyBudget.toStringAsFixed(0)} target',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  remaining >= 0
                      ? '\$${remaining.toStringAsFixed(0)} left for today'
                      : 'You are \$${remaining.abs().toStringAsFixed(0)} over target',
                  style: TextStyle(
                    color: remaining >= 0 ? AppColors.goldSoft : Colors.redAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: progress > 1 ? 1 : progress,
                    backgroundColor: Colors.white.withAlpha(18),
                    color: remaining >= 0 ? AppColors.gold : AppColors.redAlert,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: 'Spent',
                        value: '\$${_spent.toStringAsFixed(0)}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatBox(
                        label: 'Biggest cost',
                        value: _categories
                            .reduce(
                              (left, right) =>
                                  left.amount >= right.amount ? left : right,
                            )
                            .label,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Quick add',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickAddChip(
                label: 'Ride +\$6',
                onTap: () => _addSpend('Transport', 6),
              ),
              _QuickAddChip(
                label: 'Meal +\$8',
                onTap: () => _addSpend('Food', 8),
              ),
              _QuickAddChip(
                label: 'Ticket +\$12',
                onTap: () => _addSpend('Tickets', 12),
              ),
              _QuickAddChip(
                label: 'Snacks +\$4',
                onTap: () => _addSpend('Food', 4),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ..._categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryCard(
                category: category,
                total: dailyBudget,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet guidance',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Keep one small buffer for a last-minute ride, one meal, and one paid attraction. Use the fair price guide before agreeing to long transfers.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _ExpenseCategory category;
  final double total;

  const _CategoryCard({
    required this.category,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final share = (category.amount / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151D30),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.gold.withAlpha(18),
            child: Icon(category.icon, color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '\$${category.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: share,
                    backgroundColor: Colors.white.withAlpha(10),
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withAlpha(160)),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAddChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _ExpenseCategory {
  final String label;
  final double amount;
  final IconData icon;

  const _ExpenseCategory(this.label, this.amount, this.icon);

  _ExpenseCategory copyWith({
    String? label,
    double? amount,
    IconData? icon,
  }) {
    return _ExpenseCategory(
      label ?? this.label,
      amount ?? this.amount,
      icon ?? this.icon,
    );
  }
}
