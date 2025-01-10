//profile_view.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/profile/create_or_update_profile.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/profile/profile_list_view.dart';
import '../../../../dashboard/views/constants/routes.dart';
import '../../../auth/auth_service.dart';
import '../../../cloud/cloud_data_models.dart';
import '../../../cloud/profiles/read_profile.dart';
import '../../../cloud/employee_services/cloud_rent_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final RentService _rentService;
  String get userId => AuthService.firebase().currentUser!.id;

  String searchText = "";

  @override
  void initState() {
    _rentService = RentService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profiles"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateProfileRoute);
            },
            icon: const Icon(Icons.add),
            color: Colors.white,
            iconSize: 40,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg/background_dashboard.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search profiles...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _rentService.allProfiles(creatorId: userId),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allProfiles =
                              snapshot.data as Iterable<CloudProfile>;
                          final filteredProfiles = allProfiles
                              .where((profile) =>
                                  profile.firstName
                                      .toLowerCase()
                                      .contains(searchText) ||
                                  profile.companyName
                                      .toLowerCase()
                                      .contains(searchText))
                              .toList();
                          final profilesByCompanyId =
                              _groupProfilesByCompanyId(filteredProfiles);

                          return FutureBuilder<Map<String, String>>(
                            future: _getCompanyNames(
                                profilesByCompanyId.keys.toList()),
                            builder: (context, companyNamesSnapshot) {
                              if (companyNamesSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (companyNamesSnapshot.hasData) {
                                final companyNames = companyNamesSnapshot.data!;
                                return ProfilesListView(
                                  groupedProfiles: profilesByCompanyId,
                                  companyNames: companyNames,
                                  onDeleteProfile: (profile) async {
                                    await _rentService.deleteProfile(
                                        id: profile.id);
                                  },
                                  onTap: (profile) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ReadProfile(profile: profile),
                                      ),
                                    );
                                  },
                                  onLongPress: (profile) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CreateOrUpdateProfile(
                                                profile: profile),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return const Center(
                                    child: Text('Error loading company names'));
                              }
                            },
                          );
                        } else {
                          return const Center(child: Text('No profiles found'));
                        }
                      default:
                        return const Center(
                            child: Text('Error loading profiles'));
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Map<String, String>> _getCompanyNames(List<String> companyIds) async {
    final companyNames = <String, String>{};
    for (var companyId in companyIds) {
      final company = await _rentService.getCompanyById(companyId: companyId);
      companyNames[companyId] = company.companyName;
    }
    return companyNames;
  }

  Map<String, List<CloudProfile>> _groupProfilesByCompanyId(
      Iterable<CloudProfile> profiles) {
    // Sort profiles by companyName alphabetically
    final sortedProfiles = profiles.toList()
      ..sort((a, b) => a.companyName.compareTo(b.companyName));

    final Map<String, List<CloudProfile>> groupedProfiles = {};
    for (var profile in sortedProfiles) {
      if (!groupedProfiles.containsKey(profile.companyId)) {
        groupedProfiles[profile.companyId] = [];
      }
      groupedProfiles[profile.companyId]!.add(profile);
    }
    return groupedProfiles;
  }
}
