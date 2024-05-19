import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/create_rent_form.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/read_rent_page.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/delete_rent.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/rent_service.dart';

import '../../../property_mangement/new/property_service.dart';

class RentList extends StatefulWidget {
  const RentList({Key? key}) : super(key: key);

  @override
  State<RentList> createState() => _RentListState();
}

class _RentListState extends State<RentList> {
  final RentService _rentService = RentService();
  final PropertyService _propertyService = PropertyService();
  List<DatabaseProfile> _profiles = [];
  List<DatabaseProperty> _properties = [];
  List<DatabaseRent> _rents = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load profiles, properties, and rents
    final profiles = await _rentService.readAllProfiles();
    final properties = await _propertyService.getAllProperties();
    final rents = await _rentService.readAllRents();
    setState(() {
      _profiles = profiles.toList();
      _properties = properties.toList();
      _rents = rents.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent List'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _rents.length,
                    itemBuilder: (context, index) {
                      final rent = _rents[index];
                      return ListTile(
                        title: Text('Contract: ${rent.contract}'),
                        subtitle: Text(
                          'Due Date: ${rent.dueDate}\nAmount: ${rent.rentAmount}',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReadRentPage(rentId: rent.rentId),
                            ),
                          );
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => DeleteRentDialog(
                              onConfirm: () async {
                                await _rentService.deleteRent(
                                    rentId: rent.rentId);
                                _loadData();
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateRentFormWidget(
                      profiles: _profiles,
                      properties: _properties,
                    ),
                  ),
                ).then((_) {
                  _loadData();
                });
              },
              child: const Text('Add a Rent'),
            ),
          ),
        ],
      ),
    );
  }
}
