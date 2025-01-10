//rent_list.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/delete_dialog.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/error_dialog.dart';
import 'package:r_and_e_monitor/services/auth/auth_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/rents/create_or_update_rents.dart';
import 'package:r_and_e_monitor/services/cloud/rents/read_rent_page.dart';
import 'package:r_and_e_monitor/services/cloud/rents/reports/generate_rent_report.dart';
import 'package:r_and_e_monitor/services/helper/loading/loading_screen.dart';

class RentList extends StatefulWidget {
  const RentList({super.key});

  @override
  State<RentList> createState() => _RentListState();
}

class _RentListState extends State<RentList> {
  String _currentSortOption = 'property.propertyNumber';
  late final RentService _rentService;
  late final PropertyService _propertyService;
  List<CloudProfile> _profiles = [];
  List<CloudProperty> _properties = [];
  bool _isInitialized = false;
  String _searchQuery = '';

  String get userId => AuthService.firebase().currentUser!.id;

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
      final profilesStream = _rentService.allProfiles(creatorId: userId);
      final propertiesStream =
          _propertyService.allProperties(creatorId: userId);

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

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _sortRents(List<CloudRent> rents) {
    rents.sort((a, b) {
      final propertyA =
          _properties.firstWhere((prop) => prop.id == a.propertyId);
      final propertyB =
          _properties.firstWhere((prop) => prop.id == b.propertyId);

      switch (_currentSortOption) {
        case 'property.floorNumber':
          return propertyA.floorNumber.compareTo(propertyB.floorNumber);
        case 'property.propertyNumber':
          return propertyA.propertyNumber.compareTo(propertyB.propertyNumber);
        case 'profile.companyName':
          final profileA =
              _profiles.firstWhere((prof) => prof.id == a.profileId);
          final profileB =
              _profiles.firstWhere((prof) => prof.id == b.profileId);
          return profileA.companyName.compareTo(profileB.companyName);
        case 'property.sizeInSquareMeters':
          return propertyA.sizeInSquareMeters
              .compareTo(propertyB.sizeInSquareMeters);
        default:
          return 0;
      }
    });
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

  List<CloudRent> _filterRents(Iterable<CloudRent> allRents) {
    final filteredRents = _searchQuery.isEmpty
        ? allRents.toList()
        : allRents.where((rent) {
            final profile =
                _profiles.firstWhere((prof) => prof.id == rent.profileId);
            final property =
                _properties.firstWhere((prop) => prop.id == rent.propertyId);
            return profile.companyName.toLowerCase().contains(_searchQuery) ||
                property.propertyNumber.contains(_searchQuery);
          }).toList();

    _sortRents(filteredRents);
    return filteredRents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent List'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              if (_profiles.isNotEmpty && _properties.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateOrUpdateRentView(
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
                color: Colors.black
                    .withAlpha(50), // Optional tint for better contrast
              ),
            ),
          ),
          // Search Bar
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  onChanged: _updateSearchQuery,
                  decoration: InputDecoration(
                    labelText: 'Search by Property or Profile Name',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      // fontWeight: FontWeight.bold,
                    ),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              // Main Content
              _isInitialized
                  ? Expanded(
                      child: StreamBuilder<Iterable<CloudRent>>(
                        stream: _rentService.allRents(creatorId: userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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

                          final allRents = snapshot.data!;
                          final filteredRents = _filterRents(allRents);

                          final rentsByCompany =
                              <String, Map<String, List<CloudRent>>>{};

                          for (var rent in filteredRents) {
                            rentsByCompany.putIfAbsent(rent.companyId, () {
                              return {
                                'Contract_Ended': [],
                                'Contract_Active': [],
                              };
                            })[rent.endContract]!.add(rent);
                          }

                          return FutureBuilder<Map<String, String>>(
                            future: _fetchCompanyNames(
                                rentsByCompany.keys.toList()),
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
                                  final companyName = companyNames[companyId] ??
                                      'Unknown Company';
                                  final groupedRents =
                                      rentsByCompany[companyId]!;

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    elevation: 6.0,
                                    color: Colors.transparent.withAlpha(50),
                                    shadowColor:
                                        const Color.fromARGB(255, 0, 0, 0),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: ExpansionTile(
                                      backgroundColor:
                                          Colors.white.withAlpha(25),
                                      collapsedIconColor: Colors.white,
                                      iconColor: Colors.white,
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            companyName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.sort,
                                                color: Colors.white),
                                            onSelected: (value) {
                                              setState(() {
                                                _currentSortOption = value;
                                              });
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'property.floorNumber',
                                                child: Text(
                                                    'Sort by Floor Number'),
                                              ),
                                              const PopupMenuItem(
                                                value:
                                                    'property.propertyNumber',
                                                child: Text(
                                                    'Sort by Property Number'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'profile.companyName',
                                                child: Text(
                                                    'Sort by Company Name'),
                                              ),
                                              const PopupMenuItem(
                                                value:
                                                    'property.sizeInSquareMeters',
                                                child: Text(
                                                    'Sort by Size (Sq. Meters)'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      children: [
                                        _buildRentSection(
                                          title: 'Contract Ended',
                                          rents: _filterRents(
                                              groupedRents['Contract_Ended']!),
                                          context: context,
                                        ),
                                        _buildRentSection(
                                          title: 'Contract Active',
                                          rents: _filterRents(
                                              groupedRents['Contract_Active']!),
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
                                            icon: const Icon(Icons.insert_chart,
                                                color: Colors.white),
                                            label:
                                                const Text('View Rent Report'),
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 20.0,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
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
                      ),
                    )
                  : const Center(
                      child: Text('Initializing...'),
                    ),
            ],
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
        style: ListTileStyle.list,
        title: Text(
          '$title (0)',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        subtitle: const Text(
          'No rents available in this category.',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }

    return ExpansionTile(
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      backgroundColor: Colors.white.withAlpha(25),
      title: Text(
        '$title (${rents.length})',
        style: const TextStyle(
          color: Colors.white,
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
          shape: Border.all(color: Colors.transparent.withAlpha(25)),
          tileColor: Colors.black.withAlpha(50),
          title: Text(
            'Property: ${property.propertyNumber}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile: ${profile.companyName}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                'Contract: ${rent.contract}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          isThreeLine: true,
          trailing: PopupMenuButton<String>(
            iconColor: Colors.white,
            color: Colors.white,
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
                      builder: (context) => CreateOrUpdateRentView(
                        rent: rent,
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
