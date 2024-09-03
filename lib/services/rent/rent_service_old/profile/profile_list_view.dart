// profile_list_view.dart
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

        return ExpansionTile(
          title: Text('Company: $companyName'),
          children: profiles.map((profile) {
            return ListTile(
              title: Text('${profile.firstName} ${profile.lastName}'),
              onTap: () => onTap(profile),
              onLongPress: () => onLongPress(profile),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final shouldDelete = await showDeleteDialog(context);
                  if (shouldDelete) {
                    onDeleteProfile(profile);
                  }
                },
              ),
            );
          }).toList(),
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
