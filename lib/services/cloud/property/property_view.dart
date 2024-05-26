import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/services/cloud_property_service.dart';
import 'package:r_and_e_monitor/services/cloud/property/properties_list_view.dart';

import '../../auth/auth_service.dart';
import '../rents/read_property_page.dart';

class PropertyView extends StatefulWidget {
  const PropertyView({super.key});

  @override
  State<PropertyView> createState() => _PropertyViewState();
}

class _PropertyViewState extends State<PropertyView> {
  late final PropertyService _propertyService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _propertyService = PropertyService();
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
              Navigator.of(context).pushNamed(newPropertyRoute);
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
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allProperties =
                    snapshot.data as Iterable<DatabaseProperty>;
                return PropertyListView(
                  properties: allProperties,
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
                    Navigator.of(context).pushNamed(
                      newPropertyRoute,
                      arguments: property,
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
