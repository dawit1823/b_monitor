//rent_list.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/delete_dialog.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/error_dialog.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/rents/create_or_update_rent_employee.dart';
import 'package:r_and_e_monitor/services/cloud/rents/read_rent_page.dart';
import 'package:r_and_e_monitor/services/cloud/rents/reports/generate_rent_report.dart';
import 'package:r_and_e_monitor/services/helper/loading/loading_screen.dart';

class ListRentEmployee extends StatefulWidget {
  final String creatorId;
  final String companyId;

  const ListRentEmployee({
    super.key,
    required this.creatorId,
    required this.companyId,
  });
  @override
  State<ListRentEmployee> createState() => _ListRentEmployeeState();
}

class _ListRentEmployeeState extends State<ListRentEmployee> {
  late final RentService _rentService;
  late final PropertyService _propertyService;
  List<CloudProfile> _profiles = [];
  List<CloudProperty> _properties = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _rentService = RentService();
    _propertyService = PropertyService();
    _initializeData();
  }

  Future<void> _initializeData() async {
    LoadingScreen().show(
      context: context,
      text: 'Loading profiles and properties...',
    );
    try {
      final profilesStream =
          _rentService.allProfiles(creatorId: widget.creatorId);
      final propertiesStream =
          _propertyService.allProperties(creatorId: widget.creatorId);

      final profiles = await profilesStream.first;
      final properties = await propertiesStream.first;

      setState(() {
        _profiles = profiles.toList();
        _properties = properties.toList();
        _isInitialized = true;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      await showErrorDialog(context, 'Error loading data: ${e.toString()}');
    } finally {
      LoadingScreen().hide();
    }
  }

  Future<Map<String, String>> _fetchCompanyNames(
      List<String> companyIds) async {
    final Map<String, String> companyNames = {};
    for (var companyId in companyIds) {
      try {
        final company = await _rentService.getCompanyById(companyId: companyId);
        companyNames[companyId] = company.companyName;
      } catch (e) {
        companyNames[companyId] = 'Unknown Company';
      }
    }
    return companyNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 66, 143, 107),
        title: const Text('Rent List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (_profiles.isNotEmpty && _properties.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateOrUpdateRentEmployeeView(
                      creatorId: widget.creatorId,
                      companyId: widget.companyId,
                      profiles: _profiles,
                      properties: _properties,
                    ),
                  ),
                );
              } else {
                showErrorDialog(
                  context,
                  'Profiles and properties are not loaded yet.',
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/bg/accountant_dashboard.jpg', // Add your image asset path
              fit: BoxFit.cover,
            ),
          ),
          // Main Content
          _isInitialized
              ? StreamBuilder<Iterable<CloudRent>>(
                  stream: _rentService.allRents(
                      creatorId: widget.creatorId, companyId: widget.companyId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      LoadingScreen().show(
                        context: context,
                        text: 'Loading rents...',
                      );
                      return Container();
                    } else {
                      LoadingScreen().hide();
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading rents: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No rents available.'),
                      );
                    }

                    final allRents = snapshot.data!
                        .where((rent) =>
                            rent.creatorId == widget.creatorId &&
                            rent.companyId == widget.companyId)
                        .toList();

                    final rentsByCompany =
                        <String, Map<String, List<CloudRent>>>{};

                    for (var rent in allRents) {
                      rentsByCompany.putIfAbsent(rent.companyId, () {
                        return {
                          'Contract_Ended': [],
                          'Contract_Active': [],
                          'Contract_Prolonged': [],
                        };
                      })[rent.endContract]!.add(rent);
                    }

                    return FutureBuilder<Map<String, String>>(
                      future: _fetchCompanyNames(rentsByCompany.keys.toList()),
                      builder: (context, companySnapshot) {
                        if (companySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          LoadingScreen().show(
                            context: context,
                            text: 'Loading company names...',
                          );
                          return Container();
                        } else {
                          LoadingScreen().hide();
                        }

                        if (companySnapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading company names: ${companySnapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final companyNames = companySnapshot.data!;

                        return ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: rentsByCompany.length,
                          itemBuilder: (context, index) {
                            final companyId =
                                rentsByCompany.keys.elementAt(index);
                            final companyName =
                                companyNames[companyId] ?? 'Unknown Company';
                            final groupedRents = rentsByCompany[companyId]!;

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 6.0,
                              color: Colors.white.withOpacity(0.2),
                              shadowColor: const Color.fromARGB(255, 0, 0, 0),
                              margin:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: ExpansionTile(
                                title: Text(
                                  companyName,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                children: [
                                  _buildRentSection(
                                    title: 'Contract Ended',
                                    rents: groupedRents['Contract_Ended']!,
                                    context: context,
                                  ),
                                  _buildRentSection(
                                    title: 'Contract Active',
                                    rents: groupedRents['Contract_Active']!,
                                    context: context,
                                  ),
                                  _buildRentSection(
                                    title: 'Contract Prolonged',
                                    rents: groupedRents['Contract_Prolonged']!,
                                    context: context,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                GenerateRentReport(
                                                    companyId: companyId),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.insert_chart),
                                      label: const Text('View Rent Report'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12.0,
                                          horizontal: 20.0,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        backgroundColor:
                                            Color.fromARGB(255, 66, 143, 107),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                )
              : const Center(
                  child: Text('Initializing...'),
                ),
        ],
      ),
    );
  }

  Widget _buildRentSection({
    required String title,
    required List<CloudRent> rents,
    required BuildContext context,
  }) {
    if (rents.isEmpty) {
      return ListTile(
        title: Text(
          '$title (0)',
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        subtitle: const Text(
          'No rents available in this category.',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      );
    }

    return ExpansionTile(
      title: Text(
        '$title (${rents.length})',
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      children: rents.map((rent) {
        final property = _properties.firstWhere(
          (prop) => prop.id == rent.propertyId,
        );

        final profile = _profiles.firstWhere(
          (prof) => prof.id == rent.profileId,
        );

        return ListTile(
          title: Text(
            'Property: ${property.propertyNumber}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile: ${profile.companyName}'),
              Text('Contract: ${rent.contract}'),
            ],
          ),
          isThreeLine: true,
          trailing: PopupMenuButton<String>(
            color: Colors.white.withOpacity(0.8),
            onSelected: (value) async {
              if (value == 'View') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ReadRentPage(rentId: rent.id),
                  ),
                );
              } else if (value == 'Edit') {
                if (_profiles.isNotEmpty && _properties.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CreateOrUpdateRentEmployeeView(
                        rent: rent,
                        creatorId: widget.creatorId,
                        companyId: widget.companyId,
                        profiles: _profiles,
                        properties: _properties,
                      ),
                    ),
                  );
                } else {
                  await showErrorDialog(
                    context,
                    'Profiles and properties are not loaded yet.',
                  );
                }
              } else if (value == 'Delete') {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  await _rentService.deleteRent(id: rent.id);
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'View',
                child: Text('View'),
              ),
              const PopupMenuItem(
                value: 'Edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem(
                value: 'Delete',
                child: Text('Delete'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
