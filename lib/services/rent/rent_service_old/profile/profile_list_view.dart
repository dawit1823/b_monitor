//profile_list_view.dart
import 'package:flutter/material.dart';
import '../../../../dashboard/views/utilities/dialogs/delete_dialog.dart';
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
          color: Colors.white.withValues(alpha: 0.1),
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
          elevation: 0,
          child: ExpansionTile(
            collapsedIconColor: Colors.white,
            iconColor: Colors.lightBlue,
            tilePadding: const EdgeInsets.all(8.0),
            title: Text(
              'Company: $companyName',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.white),
            ),
            backgroundColor: Colors.black.withValues(alpha: 0.3),
            children: profiles.map((profile) {
              return ListTile(
                iconColor: Colors.white,
                selectedColor: Colors.black.withValues(alpha: 0.3),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                title: Text(
                  '${profile.companyName} / ${profile.firstName}',
                  style: const TextStyle(fontSize: 16.0, color: Colors.white),
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
}
