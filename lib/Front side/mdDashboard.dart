
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MD Analytics',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 5; // Default for large screens (like laptop)

          // Check if it's mobile or tablet/laptop
          if (constraints.maxWidth < 600) {
            crossAxisCount = 2; // Mobile screens
          } else if (constraints.maxWidth < 1200) {
            crossAxisCount = 5; // Tablet screens
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 20.0,
              children: [
                DashboardItem(
                  icon: Icons.people,
                  label: 'Demographics',
                  onButtonPressed: () {},
                ),
                DashboardItem(
                    icon: Icons.diversity_3,
                    label: 'Diversity',
                    onButtonPressed: () {}),
                DashboardItem(
                    icon: Icons.emoji_events,
                    label: 'Awards',
                    onButtonPressed: () {}),
                DashboardItem(
                    icon: Icons.folder_open,
                    label: 'Open Positions',
                    onButtonPressed: () {}),
                DashboardItem(
                    icon: Icons.check_circle,
                    label: 'Filled Positions',
                    onButtonPressed: () {}),
                DashboardItem(
                    icon: Icons.remove_circle,
                    label: 'Terminations',
                    onButtonPressed: () {}),
                DashboardItem(
                    icon: Icons.money,
                    label: 'Compensation',
                    onButtonPressed: () {}),
                DashboardItem(
                    icon: Icons.how_to_reg,
                    label: 'Hires',
                    onButtonPressed: () {}),
                DashboardItem(
                    icon: Icons.bar_chart,
                    label: 'Forecast',
                    onButtonPressed: () {}),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DashboardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onButtonPressed;

  const DashboardItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onButtonPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.teal,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.black87,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}