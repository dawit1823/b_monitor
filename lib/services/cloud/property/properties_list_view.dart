import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/helper/loading/loading_screen.dart';

typedef PropertyCallback = void Function(CloudProperty property);

class PropertyListView extends StatelessWidget {
  final Map<String, Map<bool, List<CloudProperty>>> groupedProperties;
  final PropertyCallback onDeleteProperty;
  final PropertyCallback onTap;
  final PropertyCallback onLongPress;
  final Map<String, String> companyNames;

  const PropertyListView({
    super.key,
    required this.groupedProperties,
    required this.onDeleteProperty,
    required this.onTap,
    required this.onLongPress,
    required this.companyNames,
  });

  @override
  Widget build(BuildContext context) {
    if (groupedProperties.isEmpty) {
      LoadingScreen().show(
        context: context,
        text: 'Loading properties...',
      );
    } else {
      LoadingScreen().hide();
    }

    return ListView.builder(
      itemCount: groupedProperties.length,
      itemBuilder: (context, companyIndex) {
        final companyId = groupedProperties.keys.elementAt(companyIndex);
        final propertiesByRentalStatus = groupedProperties[companyId]!;
        final companyName = companyNames[companyId] ?? 'Unknown';

        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: ExpansionTile(
            title: Text(
              'Company: $companyName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              for (var rentalStatus in [true, false])
                Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 16.0),
                  child: ExpansionTile(
                    title: Text(
                      rentalStatus ? 'Rented Properties' : 'Free Properties',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: rentalStatus ? Colors.green : Colors.red),
                    ),
                    children:
                        propertiesByRentalStatus[rentalStatus]!.map((property) {
                      return PropertyListTile(
                        property: property,
                        companyName: companyName,
                        onDeleteProperty: onDeleteProperty,
                        onTap: onTap,
                        onLongPress: onLongPress,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class PropertyListTile extends StatelessWidget {
  final CloudProperty property;
  final PropertyCallback onDeleteProperty;
  final PropertyCallback onTap;
  final PropertyCallback onLongPress;
  final String companyName;

  const PropertyListTile({
    super.key,
    required this.property,
    required this.onDeleteProperty,
    required this.onTap,
    required this.onLongPress,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        property.propertyNumber,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('${property.description}\nCompany: $companyName'),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          final shouldDelete = await showDeleteDialog(context);
          if (shouldDelete) {
            onDeleteProperty(property);
          }
        },
      ),
      onTap: () {
        onTap(property);
      },
      onLongPress: () {
        onLongPress(property);
      },
    );
  }
}

Future<bool> showDeleteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete'),
        content: const Text('Are you sure you want to delete this property?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
