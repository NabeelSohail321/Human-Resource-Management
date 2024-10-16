import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  final Map<String, String> _selectedLocations = {};

  @override
  void initState() {
    super.initState();
    // Fetch the managers when the page loads
    Provider.of<ManagersProvider>(context, listen: false).fetchManagers();
  }

  void _updateWorkLocation(String managerId, String location) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Update the work location in the database under the current user node
      _databaseReference.child('Manager').child(managerId).update({
        'workLocation': location,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Work location updated to $location")),
        );

        // Fetch the latest managers data after the update
        Provider.of<ManagersProvider>(context, listen: false).fetchManagers();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update work location: $error")),
        );
      });
    }
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
              print("Manager ID: ${manager.uid}, Name: ${manager.name}, Work Location: ${manager.workLocation}");

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

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        DropdownButton<String>(
                          value: manager.workLocation, // Use null if it's empty
                          hint: const Text('Select Location'),
                          items: const [
                            DropdownMenuItem(
                              value: 'Work from Home',
                              child: Text('Work from Home'),
                            ),
                            DropdownMenuItem(
                              value: 'Work from Office',
                              child: Text('Work from Office'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedLocations[manager.uid] = value; // Update selected location for this employee
                              });
                              _updateWorkLocation(manager.uid, value); // Save selected option to the database
                            }
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            managersProvider.restrictManager(manager);
                          },
                          child: const Text('Restrict'),
                        ),
                      ],
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
