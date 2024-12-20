//
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/profile/create_or_update_profile.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/profile/profile_list_view.dart';
import '../../../cloud/cloud_data_models.dart';
import '../../../cloud/profiles/read_profile.dart';
import '../../../cloud/employee_services/cloud_rent_service.dart';

class ListProfileEmployee extends StatefulWidget {
  final String creatorId;
  final String companyId;

  const ListProfileEmployee(
      {super.key, required this.creatorId, required this.companyId});

  @override
  State<ListProfileEmployee> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ListProfileEmployee> {
  late final RentService _rentService;

  @override
  void initState() {
    _rentService = RentService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 66, 143, 107),
        title: const Text("Profiles"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateOrUpdateProfile(
                    profile: null, // No property for creation
                    creatorId: widget.creatorId,
                    companyId: widget.companyId,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
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
                image: AssetImage('assets/bg/accountant_dashboard.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withValues(
                    alpha: 0.3), // Optional tint for better contrast
              ),
            ),
          ),
          StreamBuilder(
            stream: _rentService.allProfiles(
              creatorId: widget.creatorId,
            ),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    final allProfiles = snapshot.data as Iterable<CloudProfile>;
                    final filteredProfiles = allProfiles.where((profile) =>
                        profile.creatorId == widget.creatorId &&
                        profile.companyId == widget.companyId);
                    final profilesByCompanyId =
                        _groupProfilesByCompanyId(filteredProfiles);

                    return FutureBuilder<Map<String, String>>(
                      future:
                          _getCompanyNames(profilesByCompanyId.keys.toList()),
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
                              await _rentService.deleteProfile(id: profile.id);
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
                                  builder: (context) => CreateOrUpdateProfile(
                                    profile: profile,
                                    creatorId: profile.creatorId,
                                    companyId: profile.companyId,
                                  ),
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
                  return const Center(child: Text('Error loading profiles'));
              }
            },
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
    final Map<String, List<CloudProfile>> groupedProfiles = {};
    for (var profile in profiles) {
      if (!groupedProfiles.containsKey(profile.companyId)) {
        groupedProfiles[profile.companyId] = [];
      }
      groupedProfiles[profile.companyId]!.add(profile);
    }
    return groupedProfiles;
  }
}
