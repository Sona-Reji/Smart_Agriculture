import 'package:flutter/material.dart';
import '../services/sensor_data_service.dart';
import '../services/community_service.dart';
import '../services/resource_service.dart';
import 'dashboard_screen.dart';
import 'community_screen.dart';
import 'explore_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';
import '../utils/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final SensorDataService _sensorService = SensorDataService();
  final CommunityService _communityService = CommunityService();
  final ResourceService _resourceService = ResourceService();

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _sensorService,
      builder: (context, _) {
        final activeAlertsCount = _sensorService.getActiveAlerts().length;

        final screens = [
          DashboardScreen(
            service: _sensorService,
            onNavigateToTab: _onTabSelected,
          ),
          CommunityScreen(
            service: _communityService,
            initialTab: 1, // Farmers Near You tab
          ),
          ExploreScreen(
            resourceService: _resourceService,
            communityService: _communityService,
          ),
          AlertsScreen(service: _sensorService),
          ProfileScreen(
            communityService: _communityService,
            resourceService: _resourceService,
            sensorService: _sensorService,
          ),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabSelected,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.people_outline_rounded),
                selectedIcon: Icon(Icons.people_rounded),
                label: 'Farmers',
              ),
              const NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: activeAlertsCount > 0
                    ? Badge(
                        label: Text('$activeAlertsCount'),
                        backgroundColor: AppColors.statusCritical,
                        child: const Icon(Icons.warning_amber_outlined),
                      )
                    : const Icon(Icons.warning_amber_outlined),
                selectedIcon: activeAlertsCount > 0
                    ? Badge(
                        label: Text('$activeAlertsCount'),
                        backgroundColor: AppColors.statusCritical,
                        child: const Icon(Icons.warning_amber_rounded),
                      )
                    : const Icon(Icons.warning_amber_rounded),
                label: 'Alerts',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
