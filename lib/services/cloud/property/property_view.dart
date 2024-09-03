import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/property/properties_list_view.dart';
import '../../auth/auth_service.dart';
import '../../property_mangement/new/create_or_update_properties.dart';
import '../rents/read_property_page.dart';

class PropertyView extends StatefulWidget {
  const PropertyView({super.key});

  @override
  State<PropertyView> createState() => _PropertyViewState();
}

class _PropertyViewState extends State<PropertyView> {
  late final PropertyService _propertyService;
  late final RentService _rentService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _propertyService = PropertyService();
    _rentService = RentService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Properties"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const NewPropertyView(),
              ));
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _propertyService.allProperties(creatorId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allProperties = snapshot.data!;
                final propertiesByCompanyId =
                    _groupPropertiesByCompanyId(allProperties);

                return FutureBuilder<Map<String, String>>(
                  future: _getCompanyNames(propertiesByCompanyId.keys.toList()),
                  builder: (context, companyNamesSnapshot) {
                    if (companyNamesSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (companyNamesSnapshot.hasData) {
                      final companyNames = companyNamesSnapshot.data!;
                      return ListView.builder(
                        itemCount: propertiesByCompanyId.length,
                        itemBuilder: (context, companyIndex) {
                          final companyId = propertiesByCompanyId.keys
                              .elementAt(companyIndex);
                          final propertiesByRentalStatus =
                              propertiesByCompanyId[companyId]!;
                          final companyName =
                              companyNames[companyId] ?? 'Unknown';

                          return Card(
                            elevation: 4.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            child: ExpansionTile(
                              title: Text(
                                'Company: $companyName',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              children: [
                                for (var rentalStatus in [true, false])
                                  _buildRentalStatusSection(
                                    rentalStatus,
                                    propertiesByRentalStatus[rentalStatus] ??
                                        [],
                                    companyName,
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    return const Center(
                        child: Text('Error loading company names'));
                  },
                );
              } else {
                return const Center(child: Text('No properties found'));
              }
            default:
              return const Center(child: Text('Error loading properties'));
          }
        },
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

  Map<String, Map<bool, List<CloudProperty>>> _groupPropertiesByCompanyId(
      Iterable<CloudProperty> properties) {
    final Map<String, Map<bool, List<CloudProperty>>> groupedProperties = {};
    for (var property in properties) {
      final companyId = property.companyId;
      final rentalStatus = property.isRented;
      groupedProperties.putIfAbsent(companyId, () => {true: [], false: []});
      groupedProperties[companyId]![rentalStatus]!.add(property);
    }
    return groupedProperties;
  }

  Widget _buildRentalStatusSection(
      bool rentalStatus, List<CloudProperty> properties, String companyName) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
      child: ExpansionTile(
        title: Text(
          rentalStatus ? 'Rented Properties' : 'Free Properties',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: rentalStatus ? Colors.green : Colors.red),
        ),
        children: properties.map((property) {
          return PropertyListTile(
            property: property,
            companyName: companyName,
            onDeleteProperty: (property) async {
              await _propertyService.deleteProperty(id: property.id);
            },
            onTap: (property) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ReadPropertyPage(propertyId: property.id),
                ),
              );
            },
            onLongPress: (property) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NewPropertyView(property: property),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
