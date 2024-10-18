import 'package:flutter/material.dart';
import '../../../cloud/cloud_data_models.dart';

typedef ProfileCallback = void Function(CloudProfile profile);

class ProfilesListView extends StatelessWidget {
  final Map<String, List<CloudProfile>> groupedProfiles;
  final Map<String, String> companyNames;
  final ProfileCallback onDeleteProfile;
  final ProfileCallback onTap;
  final ProfileCallback onLongPress;

  const ProfilesListView({
    super.key,
    required this.groupedProfiles,
    required this.companyNames,
    required this.onDeleteProfile,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: groupedProfiles.length,
      itemBuilder: (context, index) {
        final companyId = groupedProfiles.keys.elementAt(index);
        final profiles = groupedProfiles[companyId]!;
        final companyName = companyNames[companyId] ?? 'Unknown';

        return Card(
          color: Colors.transparent,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 5.0,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(16.0),
            title: Text(
              'Company: $companyName',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            backgroundColor: Colors.transparent,
            children: profiles.map((profile) {
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                title: Text(
                  '${profile.firstName} ${profile.lastName}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                onTap: () => onTap(profile),
                onLongPress: () => onLongPress(profile),
                tileColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final shouldDelete = await showDeleteDialog(context);
                    if (shouldDelete) {
                      onDeleteProfile(profile);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<bool> showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete"),
          content: const Text("Are you sure you want to delete this profile?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}
