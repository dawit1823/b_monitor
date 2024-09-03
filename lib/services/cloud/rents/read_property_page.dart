import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/property_mangement/new/create_or_update_properties.dart';
import '../cloud_data_models.dart';
import '../employee_services/cloud_property_service.dart';

class ReadPropertyPage extends StatelessWidget {
  final String propertyId;
  final PropertyService _propertyService = PropertyService();

  ReadPropertyPage({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Property'),
        centerTitle: true,
      ),
      body: FutureBuilder<CloudProperty>(
        future: _propertyService.getProperty(id: propertyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          } else {
            final property = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      leading: const Icon(Icons.home, color: Colors.blueAccent),
                      title: const Text('Property Type'),
                      subtitle: Text(property.propertyType),
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      leading: const Icon(Icons.layers, color: Colors.blueAccent),
                      title: const Text('Floor Number'),
                      subtitle: Text(property.floorNumber.toString()),
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      leading: const Icon(Icons.confirmation_number,
                          color: Colors.blueAccent),
                      title: const Text('Property Number'),
                      subtitle: Text(property.propertyNumber),
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      leading:
                          const Icon(Icons.attach_money, color: Colors.blueAccent),
                      title: const Text('Price Per Month'),
                      subtitle: Text('\$${property.pricePerMonth.toString()}'),
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      leading:
                          const Icon(Icons.square_foot, color: Colors.blueAccent),
                      title: const Text('Size in Square Meters'),
                      subtitle: Text(property.sizeInSquareMeters.toString()),
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      leading:
                          const Icon(Icons.description, color: Colors.blueAccent),
                      title: const Text('Description'),
                      subtitle: Text(property.description),
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      leading: Icon(
                          property.isRented ? Icons.check_circle : Icons.cancel,
                          color: property.isRented ? Colors.green : Colors.red),
                      title: const Text('Rented Status'),
                      subtitle: Text(property.isRented ? "Rented" : "Free"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NewPropertyView(
                              property: property, // Pass the current property
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Update Property'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
