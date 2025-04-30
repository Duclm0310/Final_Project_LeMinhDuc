import 'package:flutter/material.dart';
import 'DeviceDetail.dart';

class SmartDevice {
  final String id;
  final String name;
  final String type; // lighting, climate, entertainment, security, etc.
  final String location;
  bool isOn;
  late final double powerUsage; // in watts
  final double totalConsumption;
  Map<String, dynamic> settings;

  SmartDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.isOn,
    required this.powerUsage,
    required this.totalConsumption,
    required this.settings,
  });
}

/*final List<SmartDevice> _devices = [
  SmartDevice(
    id: '1',
    name: 'Light SL01C',
    type: 'Light',
    location: 'Living Room',
    isOn: true,
    powerUsage: 8.0,
    totalConsumption: 5.0,
    settings: {
      'brightness': 75,
      'wattage': 8,
      'mode': 'Auto',
    },
  ),
  SmartDevice(
    id: '2',
    name: 'Light SL02C',
    type: 'Light',
    location: 'Bedroom',
    isOn: false,
    powerUsage: 9.0,
    totalConsumption: 3.5,
    settings: {
      'brightness': 60,
      'wattage': 9,
      'mode': 'Day',
    },
  ),
  SmartDevice(
    id: '3',
    name: 'Light SL03C',
    type: 'Light',
    location: 'Kitchen',
    isOn: true,
    powerUsage: 12.0,
    totalConsumption: 7.2,
    settings: {
      'brightness': 90,
      'wattage': 12,
      'mode': 'Cool',
    },
  ),
  SmartDevice(
    id: '4',
    name: 'Light SL04C',
    type: 'Light',
    location: 'Bathroom',
    isOn: false,
    powerUsage: 16.0,
    totalConsumption: 2.8,
    settings: {
      'brightness': 50,
      'wattage': 16,
      'mode': 'Night',
    },
  ),
  SmartDevice(
    id: '5',
    name: 'AC Unit',
    type: 'Climate',
    location: 'Living Room',
    isOn: true,
    powerUsage: 1200.0,
    totalConsumption: 45.0,
    settings: {
      'temperature': 23,
      'mode': 'Cool',
      'fanSpeed': 'Auto',
    },
  ),
  SmartDevice(
    id: '6',
    name: 'Thermostat',
    type: 'Climate',
    location: 'Bedroom',
    isOn: true,
    powerUsage: 5.0,
    totalConsumption: 1.2,
    settings: {
      'temperature': 21,
      'mode': 'Heat',
      'schedule': true,
    },
  ),
];

//Smart Devices Screen - Shows devices grouped by type
class SmartDevicesScreen extends StatefulWidget {
  final Map<String, Map<String, dynamic>> housesData;

  const SmartDevicesScreen({
    Key? key,
    required this.housesData,
  }) : super(key: key);

  @override
  State<SmartDevicesScreen> createState() => _SmartDevicesScreenState();
}

class _SmartDevicesScreenState extends State<SmartDevicesScreen> {
  String _selectedHouse = '';
  String _selectedType = 'All';
  List<String> _deviceTypes = ['All'];
  Map<String, List<SmartDevice>> _devicesByType = {};

  @override
  void initState() {
    super.initState();

    // Set the first house as selected by default
    if (widget.housesData.isNotEmpty) {
      _selectedHouse = widget.housesData.keys.first;
    }

    _updateDeviceTypes();
  }

  void _updateDeviceTypes() {
    // Get all device types from all houses
    final Set<String> types = {'All'};

    for (final house in widget.housesData.values) {
      final devices = house['smartDevices'] as List<SmartDevice>;
      for (final device in devices) {
        types.add(device.type);
      }
    }

    setState(() {
      _deviceTypes = types.toList();
      _updateDevicesByType();
    });
  }

  void _updateDevicesByType() {
    final Map<String, List<SmartDevice>> devicesByType = {};

    // If a house is selected, only show devices from that house
    if (_selectedHouse.isNotEmpty) {
      final houseData = widget.housesData[_selectedHouse];
      if (houseData != null) {
        final devices = houseData['smartDevices'] as List<SmartDevice>;

        // Group devices by type
        for (final device in devices) {
          if (_selectedType == 'All' || device.type == _selectedType) {
            if (!devicesByType.containsKey(device.type)) {
              devicesByType[device.type] = [];
            }
            devicesByType[device.type]!.add(device);
          }
        }
      }
    } else {
      // Show devices from all houses
      for (final house in widget.housesData.entries) {
        final devices = house.value['smartDevices'] as List<SmartDevice>;

        // Group devices by type
        for (final device in devices) {
          if (_selectedType == 'All' || device.type == _selectedType) {
            if (!devicesByType.containsKey(device.type)) {
              devicesByType[device.type] = [];
            }
            devicesByType[device.type]!.add(device);
          }
        }
      }
    }

    setState(() {
      _devicesByType = devicesByType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Devices'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // House selector
          if (widget.housesData.length > 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select House',
                  border: OutlineInputBorder(),
                ),
                value: _selectedHouse,
                items: [
                  for (final house in widget.housesData.keys)
                    DropdownMenuItem(
                      value: house,
                      child: Text(house),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedHouse = value;
                      _updateDevicesByType();
                    });
                  }
                },
              ),
            ),

          // Device type filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final type in _deviceTypes)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(type),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedType = type;
                              _updateDevicesByType();
                            });
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Devices list grouped by type
          Expanded(
            child: _devicesByType.isEmpty
                ? const Center(
                    child: Text('No devices found'),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          for (final entry in _devicesByType.entries)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: entry.value.length,
                                  itemBuilder: (context, index) {
                                    final device = entry.value[index];
                                    return _buildDeviceCard(device);
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(SmartDevice device) {
    // Get icon based on device type
    IconData iconData;
    switch (device.icon) {
      case 'lightbulb':
        iconData = Icons.lightbulb;
        break;
      case 'air_conditioner':
        iconData = Icons.ac_unit;
        break;
      case 'tv':
        iconData = Icons.tv;
        break;
      case 'lock':
        iconData = Icons.lock;
        break;
      case 'thermostat':
        iconData = Icons.thermostat;
        break;
      case 'speaker':
        iconData = Icons.speaker;
        break;
      case 'camera':
        iconData = Icons.camera_alt;
        break;
      default:
        iconData = Icons.devices;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 1,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceDetailScreen(device: device),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: device.isOn ? Colors.teal : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      device.location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${device.powerUsage.toStringAsFixed(1)} W • ${device.dailyUsage.toStringAsFixed(2)} kWh/day',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: device.isOn,
                onChanged: (value) {
                  setState(() {
                    device.isOn = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/

// Device List Screen
class DeviceListScreen extends StatefulWidget {
  final String deviceType;

  const DeviceListScreen({
    Key? key,
    required this.deviceType,
  }) : super(key: key);

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  // Sample data
  final List<SmartDevice> _devices = [
    SmartDevice(
      id: '1',
      name: 'Light SL01C',
      type: 'Light',
      location: 'Living Room',
      isOn: true,
      powerUsage: 8.0,
      totalConsumption: 5.0,
      settings: {
        'brightness': 75,
        'wattage': 8,
        'mode': 'Auto',
      },
    ),
    SmartDevice(
      id: '2',
      name: 'Light SL02C',
      type: 'Light',
      location: 'Bedroom',
      isOn: false,
      powerUsage: 9.0,
      totalConsumption: 3.5,
      settings: {
        'brightness': 60,
        'wattage': 9,
        'mode': 'Day',
      },
    ),
    SmartDevice(
      id: '3',
      name: 'Light SL03C',
      type: 'Light',
      location: 'Kitchen',
      isOn: true,
      powerUsage: 12.0,
      totalConsumption: 7.2,
      settings: {
        'brightness': 90,
        'wattage': 12,
        'mode': 'Cool',
      },
    ),
    SmartDevice(
      id: '4',
      name: 'Light SL04C',
      type: 'Light',
      location: 'Bathroom',
      isOn: false,
      powerUsage: 16.0,
      totalConsumption: 2.8,
      settings: {
        'brightness': 50,
        'wattage': 16,
        'mode': 'Night',
      },
    ),
    SmartDevice(
      id: '5',
      name: 'AC Unit',
      type: 'Climate',
      location: 'Living Room',
      isOn: true,
      powerUsage: 1200.0,
      totalConsumption: 45.0,
      settings: {
        'temperature': 23,
        'mode': 'Cool',
        'fanSpeed': 'Auto',
      },
    ),
    SmartDevice(
      id: '6',
      name: 'Thermostat',
      type: 'Climate',
      location: 'Bedroom',
      isOn: true,
      powerUsage: 5.0,
      totalConsumption: 1.2,
      settings: {
        'temperature': 21,
        'mode': 'Heat',
        'schedule': true,
      },
    ),
  ];

  List<SmartDevice> get filteredDevices {
    if (widget.deviceType == 'All Devices') {
      return _devices;
    } else {
      return _devices.where((device) => device.type == widget.deviceType).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.deviceType == 'All Devices' ? 'Smart Home' : '${widget.deviceType} List',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: filteredDevices.isEmpty
                ? const Center(
                    child: Text('No devices found'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDevices.length,
                    itemBuilder: (context, index) {
                      final device = filteredDevices[index];
                      return DeviceListItem(
                        device: device,
                        onToggle: (value) {
                          setState(() {
                            device.isOn = value;
                          });
                        },
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceDetailScreen(device: device),
                            ),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Device'),
                              content: Text('Are you sure you want to delete ${device.name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _devices.remove(device);
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class DeviceListItem extends StatelessWidget {
  final SmartDevice device;
  final Function(bool) onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DeviceListItem({
    Key? key,
    required this.device,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceDetailScreen(device: device),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          device.name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(device.location),
        trailing: IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.red[400],
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
