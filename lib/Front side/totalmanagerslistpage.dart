import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/managerprovider.dart';
import '../components.dart';


class ManagersListPage extends StatefulWidget {
  const ManagersListPage({super.key});

  @override
  State<ManagersListPage> createState() => _ManagersListPageState();
}

class _ManagersListPageState extends State<ManagersListPage> {
  @override
  void initState() {
    super.initState();
    // Fetch the managers when the page loads
    Provider.of<ManagersProvider>(context, listen: false).fetchManagers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.customAppBar("Total Managers"),
      body: Consumer<ManagersProvider>(
        builder: (context, managersProvider, child) {
          final managers = managersProvider.managers;
          return ListView.builder(
            itemCount: managers.length,
            itemBuilder: (context, index) {
              final manager = managers[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: ListTile(
                    title: Text(manager.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email: ${manager.email}"),
                        Text("Manager Number: ${manager.managerNumber}"),
                        Text("Email: ${manager.departmentName }"),
                        Text("Phone Number: ${manager.phone }"),


                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        managersProvider.restrictManager(manager);
                      },
                      child: const Text('Restrict'),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
