// profile_view.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/profile/profile_list_view.dart';
import '../../../../dashboard/views/constants/routes.dart';
import '../../../auth/auth_service.dart';
import '../../../cloud/cloud_data_models.dart';
import '../../../cloud/profiles/read_profile.dart';
import '../../../cloud/services/cloud_rent_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final RentService _rentService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _rentService = RentService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profiles"), actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              createOrUpdateProfileRoute,
            );
          },
          icon: const Icon(Icons.add),
        ),
      ]),
      body: StreamBuilder(
        stream: _rentService.allProfiles(creatorId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allProfiles = snapshot.data as Iterable<CloudProfile>;
                return ProfilesListView(
                  profiles: allProfiles,
                  onDeleteProfile: (profile) async {
                    await _rentService.deleteProfile(id: profile.id);
                  },
                  onTap: (profile) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReadProfile(profile: profile),
                      ),
                    );
                  },
                  onLongPress: (profile) {
                    Navigator.of(context).pushNamed(
                      createOrUpdateProfileRoute,
                      arguments: profile,
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
