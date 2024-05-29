//rent_list.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/auth/auth_service.dart';
import 'package:r_and_e_monitor/services/cloud/services/cloud_property_service.dart';
import 'package:r_and_e_monitor/services/cloud/services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/rents/create_or_update_rents.dart';
import 'package:r_and_e_monitor/services/cloud/rents/error_dialogs.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/arguments/error_dialog.dart';
import 'package:r_and_e_monitor/services/cloud/rents/read_rent_page.dart';

class RentList extends StatefulWidget {
  const RentList({Key? key}) : super(key: key);

  @override
  State<RentList> createState() => _RentListState();
}

class _RentListState extends State<RentList> {
  late final RentService _rentService;
  late final PropertyService _propertyService;
  List<CloudProfile> _profiles = [];
  List<DatabaseProperty> _properties = [];
  bool _isLoading = true;

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    super.initState();
    _rentService = RentService();
    _propertyService = PropertyService();
    _fetchProfilesAndProperties();
  }

  Future<void> _fetchProfilesAndProperties() async {
    try {
      final profiles = await _rentService.allProfiles(creatorId: userId).first;
      final properties =
          await _propertyService.allProperties(creatorId: userId).first;
      setState(() {
        _profiles = profiles.toList();
        _properties = properties.toList();
        _isLoading = false;
      });
    } catch (e) {
      showErrorDialog(context, 'Error fetching profiles and properties: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (_profiles.isNotEmpty && _properties.isNotEmpty) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CreateOrUpdateRentView(
                    profiles: _profiles,
                    properties: _properties,
                  ),
                ));
              } else {
                showErrorDialog(
                    context, 'Profiles and properties are not loaded yet.');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream: _rentService.allRents(creatorId: userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  final allRents = snapshot.data as Iterable<CloudRent>;
                  final contractEndedRents = allRents
                      .where((rent) => rent.endContract == 'Contract_Ended');
                  final contractActiveRents = allRents
                      .where((rent) => rent.endContract == 'Contract_Active');
                  final contractProlongedRents = allRents.where(
                      (rent) => rent.endContract == 'Contract_Prolonged');

                  return ListView(
                    children: [
                      _buildRentSection('Contract Ended', contractEndedRents),
                      _buildRentSection('Contract Active', contractActiveRents),
                      _buildRentSection(
                          'Contract Prolonged', contractProlongedRents),
                    ],
                  );
                } else {
                  return const Center(child: Text('No rents available.'));
                }
              },
            ),
    );
  }

  Widget _buildRentSection(String title, Iterable<CloudRent> rents) {
    return ExpansionTile(
      title: Text(title),
      children: rents.map((rent) {
        return ListTile(
          title: Text(rent.contract),
          subtitle: Text('Due: ${rent.dueDate}'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ReadRentPage(rentId: rent.id),
            ));
          },
          onLongPress: () {
            if (_profiles.isNotEmpty && _properties.isNotEmpty) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CreateOrUpdateRentView(
                  rent: rent,
                  profiles: _profiles,
                  properties: _properties,
                ),
              ));
            } else {
              showErrorDialog(
                  context, 'Profiles and properties are not loaded yet.');
            }
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                await _rentService.deleteRent(id: rent.id);
              }
            },
          ),
        );
      }).toList(),
    );
  }
}
