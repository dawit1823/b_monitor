// rent_list.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/auth/auth_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/rents/create_or_update_rents.dart';
import 'package:r_and_e_monitor/services/cloud/rents/error_dialogs.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/arguments/error_dialog.dart';
import 'package:r_and_e_monitor/services/cloud/rents/read_rent_page.dart';
import 'package:r_and_e_monitor/services/cloud/rents/reports/generate_rent_report.dart';

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

  Future<String> _fetchCompanyName(String companyId) async {
    final company = await _rentService.getCompanyById(companyId: companyId);
    return company.companyName;
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

                  final rentsByCompany =
                      <String, Map<String, List<CloudRent>>>{};

                  for (var rent in allRents) {
                    if (!rentsByCompany.containsKey(rent.companyId)) {
                      rentsByCompany[rent.companyId] = {
                        'Contract_Ended': [],
                        'Contract_Active': [],
                        'Contract_Prolonged': [],
                      };
                    }
                    rentsByCompany[rent.companyId]![rent.endContract]!
                        .add(rent);
                  }

                  return FutureBuilder<Map<String, String>>(
                    future: _fetchCompanyNames(rentsByCompany.keys.toList()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              'Error fetching company names: ${snapshot.error}'),
                        );
                      } else if (snapshot.hasData) {
                        final companyNames = snapshot.data!;
                        return ListView(
                          children: rentsByCompany.entries.map((entry) {
                            final companyId = entry.key;
                            final companyName =
                                companyNames[companyId] ?? 'Unknown Company';
                            final groupedRents = entry.value;
                            return ExpansionTile(
                              title: Text(companyName),
                              children: [
                                _buildRentSection('Contract Ended',
                                    groupedRents['Contract_Ended']!),
                                _buildRentSection('Contract Active',
                                    groupedRents['Contract_Active']!),
                                _buildRentSection('Contract Prolonged',
                                    groupedRents['Contract_Prolonged']!),
                                ListTile(
                                  title: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GenerateRentReport(
                                                  companyId: companyId),
                                        ),
                                      );
                                    },
                                    child: const Text('View Rent Report'),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        );
                      } else {
                        return const Center(child: Text('No rents available.'));
                      }
                    },
                  );
                } else {
                  return const Center(child: Text('No rents available.'));
                }
              },
            ),
    );
  }

  Future<Map<String, String>> _fetchCompanyNames(
      List<String> companyIds) async {
    final Map<String, String> companyNames = {};
    for (var companyId in companyIds) {
      final companyName = await _fetchCompanyName(companyId);
      companyNames[companyId] = companyName;
    }
    return companyNames;
  }

  Widget _buildRentSection(String title, List<CloudRent> rents) {
    return ExpansionTile(
      title: Text('$title (${rents.length})'),
      children: rents.map((rent) {
        final property =
            _properties.firstWhere((prop) => prop.id == rent.propertyId);
        final profile =
            _profiles.firstWhere((prop) => prop.id == rent.profileId);
        return ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile Name: ${profile.companyName}'),
              Text('Property Number: ${property.propertyNumber}'),
            ],
          ),
          subtitle: Text(' ${rent.contract}  '),
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
