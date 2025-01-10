//list_property.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/property/create_or_update_property.dart';
import 'package:r_and_e_monitor/services/cloud/property/properties_list_view.dart';

import 'package:flutter/material.dart';

import '../../rents/read_property_page.dart';

class ListProperty extends StatefulWidget {
  final String creatorId;
  final String companyId;

  const ListProperty(
      {super.key, required this.creatorId, required this.companyId});

  @override
  State<ListProperty> createState() => _PropertyViewState();
}

class _PropertyViewState extends State<ListProperty> {
  late final PropertyService _propertyService;
  late final RentService _rentService;

  String _sortCriteria = 'None'; // Default sort criteria

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
        backgroundColor: const Color.fromARGB(255, 66, 143, 107),
        title: const Text("My Properties"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateOrUpdateProperty(
                    property: null,
                    creatorId: widget.creatorId,
                    companyId: widget.companyId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg/accountant_dashboard.jpg',
              fit: BoxFit.cover,
            ),
          ),
          StreamBuilder(
            stream: _propertyService.allProperties(creatorId: widget.creatorId),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    final allProperties = snapshot.data!;
                    final filteredProperties = allProperties.where((property) =>
                        property.creatorId == widget.creatorId &&
                        property.companyId == widget.companyId);

                    // Apply sorting
                    final sortedProperties = _sortProperties(
                        filteredProperties.toList(), _sortCriteria);

                    final propertiesByCompanyId =
                        _groupPropertiesByCompanyId(sortedProperties);

                    return FutureBuilder<Map<String, String>>(
                      future:
                          _getCompanyNames(propertiesByCompanyId.keys.toList()),
                      builder: (context, companyNamesSnapshot) {
                        if (companyNamesSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                color: Colors.transparent,
                                elevation: 6.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 16.0),
                                child: ExpansionTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Company: $companyName',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          setState(() {
                                            _sortCriteria = value;
                                          });
                                        },
                                        icon: const Icon(Icons.sort),
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'floorNumber',
                                            child: Text('Sort by Floor Number'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'propertyNumber',
                                            child:
                                                Text('Sort by Property Number'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'pricePerMonth',
                                            child: Text(
                                                'Sort by Price (Low to High)'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'sizeInSquareMeters',
                                            child: Text(
                                                'Sort by Size (Small to Big)'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  children: [
                                    for (var rentalStatus in [true, false])
                                      _buildRentalStatusSection(
                                        rentalStatus,
                                        propertiesByRentalStatus[
                                                rentalStatus] ??
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
        ],
      ),
    );
  }

  List<CloudProperty> _sortProperties(
      List<CloudProperty> properties, String criteria) {
    switch (criteria) {
      case 'floorNumber':
        properties.sort((a, b) => a.floorNumber.compareTo(b.floorNumber));
        break;
      case 'propertyNumber':
        properties.sort((a, b) => a.propertyNumber.compareTo(b.propertyNumber));
        break;
      case 'pricePerMonth':
        properties.sort((a, b) => a.pricePerMonth.compareTo(b.pricePerMonth));
        break;
      case 'sizeInSquareMeters':
        properties.sort(
            (a, b) => a.sizeInSquareMeters.compareTo(b.sizeInSquareMeters));
        break;
    }
    return properties;
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: const Color.fromARGB(255, 224, 229, 235),
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
      child: ExpansionTile(
        title: Text(
          rentalStatus ? 'Rented Properties' : 'Free Properties',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: rentalStatus ? Colors.green : Colors.red,
          ),
        ),
        leading: Icon(
          rentalStatus ? Icons.check_circle_outline : Icons.highlight_off,
          color: rentalStatus ? Colors.green : Colors.red,
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
                  builder: (context) => CreateOrUpdateProperty(
                    property: property,
                    creatorId: widget.creatorId,
                    companyId: widget.companyId,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
