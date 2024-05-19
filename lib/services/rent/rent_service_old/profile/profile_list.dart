// profile_list.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/profile/read_profile.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/rent_service.dart';
import 'new_profile.dart'; // Import the NewProfile page

class ProfileList extends StatefulWidget {
  const ProfileList({Key? key}) : super(key: key);

  @override
  State<ProfileList> createState() => _ProfileListState();
}

class _ProfileListState extends State<ProfileList> {
  final _rentService = RentService();
  List<DatabaseProfile> _profiles = [];

  @override
  void initState() {
    super.initState();
    _getProfiles();
  }

  Future<void> _getProfiles() async {
    final profiles = await _rentService.readAllProfiles();
    setState(() {
      _profiles = profiles.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _navigateToNewProfile();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _profiles.length,
        itemBuilder: (context, index) {
          final profile = _profiles[index];
          return ListTile(
            title: Text(profile.companyName ?? profile.firstName!),
            subtitle: Text(profile.email),
            onTap: () => _navigateToProfile(profile),
          );
        },
      ),
    );
  }

  void _navigateToProfile(DatabaseProfile profile) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileReadPage(profile: profile),
      ),
    );
  }

  void _navigateToNewProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewProfile(),
      ),
    );
    // Refresh the profile list after returning from the NewProfile page
    _getProfiles();
  }
}
