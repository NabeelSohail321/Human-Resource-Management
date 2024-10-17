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
    // Fetch the restricted users when the page loads after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestrictedUsersProvider>(context, listen: false).fetchRestrictedUsers();
    });
  }

  void _moveManagerBack(String userId) {
    final restrictedUsersProvider = Provider.of<RestrictedUsersProvider>(context, listen: false);

    // Call the provider method to move the manager back
    restrictedUsersProvider.moveUserBack(userId).then((_) {
      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Manager moved back and status updated to Active!")),
      );

      // Refresh the list of restricted users
      restrictedUsersProvider.fetchRestrictedUsers();
    }).catchError((error) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to move manager back: $error")),
      );
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.customAppBar("Total Restricted"),
      body: Consumer<RestrictedUsersProvider>(
        builder: (context, resticatedUsersProvider, child) {
          final resticatedUsers = resticatedUsersProvider.restrictedUsers;

          // Handle loading state
          if (resticatedUsers.isEmpty && resticatedUsersProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (resticatedUsersProvider.errorMessage != null) {
            return Center(child: Text(resticatedUsersProvider.errorMessage!));
          }

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
                    Text("Department: ${user.departmentName}"),
                    Text("Phone Number: ${user.phone}"),
                    Text("Role Number: ${user.role}"),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    _moveManagerBack(user.uid); // Call method to move manager back
                  },
                  child: const Text('Move Back'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
