import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';

typedef PropertyCallback = void Function(DatabaseProperty property);

class PropertyListView extends StatelessWidget {
  final Iterable<DatabaseProperty> properties;
  final PropertyCallback onDeleteProperty;
  final PropertyCallback onTap;
  final PropertyCallback onLongPress;

  const PropertyListView({
    Key? key,
    required this.properties,
    required this.onDeleteProperty,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties.elementAt(index);
        return ListTile(
          title: Text(property.propertyNumber),
          subtitle: Text(property.description),
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
