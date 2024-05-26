// profile_list_view.dart
import 'package:flutter/material.dart';

import '../../../cloud/cloud_data_models.dart';

typedef ProfileCallback = void Function(CloudProfile profile);

class ProfilesListView extends StatelessWidget {
  final Iterable<CloudProfile> profiles;
  final ProfileCallback onDeleteProfile;
  final ProfileCallback onTap;
  final ProfileCallback onLongPress;

  const ProfilesListView({
    Key? key,
    required this.profiles,
    required this.onDeleteProfile,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles.elementAt(index);
        return ListTile(
          title: Text(profile.companyName),
          subtitle: Text('${profile.firstName} ${profile.lastName}'),
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
