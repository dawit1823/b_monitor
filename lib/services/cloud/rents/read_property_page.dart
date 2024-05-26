import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import '../cloud_data_models.dart';
import '../services/cloud_property_service.dart';

class ReadPropertyPage extends StatelessWidget {
  final String propertyId;
  final PropertyService _propertyService = PropertyService();

  ReadPropertyPage({Key? key, required this.propertyId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Property')),
      body: FutureBuilder<DatabaseProperty>(
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Property Type: ${property.propertyType}'),
                  Text('Floor Number: ${property.floorNumber}'),
                  Text('Property Number: ${property.propertyNumber}'),
                  Text('Price Per Month: ${property.pricePerMonth}'),
                  Text('Size in Square Meters: ${property.sizeInSquareMeters}'),
                  Text('Description: ${property.description}'),
                  Text('Rented: ${property.isRented ? "Rented" : "Free"}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        newPropertyRoute,
                        arguments: property,
                      );
                    },
                    child: const Text('Update Property'),
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
