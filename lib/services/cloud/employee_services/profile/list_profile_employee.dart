// list_profile_employee.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'create_or_update_profile.dart';

class ListProfileEmployee extends StatelessWidget {
  final String creatorId;
  final String companyId;

  const ListProfileEmployee({
    super.key,
    required this.creatorId,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final RentService rentService = RentService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile List'),
      ),
      body: StreamBuilder<Iterable<CloudProfile>>(
        stream: rentService.allProfiles(creatorId: creatorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading profiles.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No profiles found.'));
          }

          final profiles = snapshot.data!.where((profile) =>
              profile.companyId == companyId && profile.creatorId == creatorId);

          if (profiles.isEmpty) {
            return const Center(child: Text('No profiles found.'));
          }

          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles.elementAt(index);
              return ListTile(
                title: Text('${profile.firstName} ${profile.lastName}'),
                subtitle: Text(profile.email),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateOrUpdateProfile(
                          profile: profile,
                          creatorId: creatorId,
                          companyId: companyId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateOrUpdateProfile(
                creatorId: creatorId,
                companyId: companyId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
