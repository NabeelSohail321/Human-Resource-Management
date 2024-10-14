import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/resticatedprovider.dart';
import '../components.dart';

class ResticatedListPage extends StatefulWidget {
  const ResticatedListPage({super.key});

  @override
  State<ResticatedListPage> createState() => _ResticatedListPageState();
}

class _ResticatedListPageState extends State<ResticatedListPage> {
  @override
  void initState() {
    super.initState();
    // Fetch the resticated users when the page loads
    Provider.of<resticatedUsersProvider>(context, listen: false).fetchresticatedUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.customAppBar("Total Resticated"),
      body: Consumer<resticatedUsersProvider>(
        builder: (context, resticatedUsersProvider, child) {
          final resticatedUsers = resticatedUsersProvider.resticatedUsers;
          return ListView.builder(
            itemCount: resticatedUsers.length,
            itemBuilder: (context, index) {
              final user = resticatedUsers[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email: ${user.email}"),
                    Text("Manager Number: ${user.managerNumber}"),
                    Text("Department: ${user.departmentName }"),
                    Text("Phone Number: ${user.phone }"),
                    Text("Role Number: ${user.role }"),





                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
