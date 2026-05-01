import 'package:flutter/material.dart';

import '../models/user_profile_model.dart';
import 'ai_assistant_screen.dart';
import 'home_screen.dart';
import 'itinerary_builder_screen.dart';
import 'profile_screen.dart';
import 'smart_map_screen.dart';

class TravelShellScreen extends StatefulWidget {
  final AppUser user;

  const TravelShellScreen({super.key, required this.user});

  @override
  State<TravelShellScreen> createState() => _TravelShellScreenState();
}

class _TravelShellScreenState extends State<TravelShellScreen> {
  int _index = 0;
  late AppUser _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  void _openTab(int index) {
    setState(() => _index = index);
  }

  void _refreshUser(AppUser user) {
    setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        user: _user,
        onOpenAssistant: () => _openTab(2),
        onOpenItinerary: () => _openTab(3),
        onOpenMap: () => _openTab(1),
        onOpenProfile: () => _openTab(4),
      ),
      const SmartMapScreen(),
      const AiAssistantScreen(),
      ItineraryBuilderScreen(user: _user),
      ProfileScreen(
        user: _user,
        onUserUpdated: _refreshUser,
      ),
    ];

    final showPlanFab = _index == 1;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _openTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Itinerary',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: showPlanFab
          ? FloatingActionButton.extended(
              heroTag: 'map-plan-fab',
              onPressed: () => _openTab(3),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Plan my day'),
            )
          : null,
    );
  }
}
