import 'package:energymanagement/riverpod/room_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class RoomDetailScreen extends ConsumerStatefulWidget {
  const RoomDetailScreen({
    super.key,
  });

  @override
  _RoomDetailScreenState createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen> {
  // Device states
  bool airConditionerOn = true;
  bool humidifierOn = false;
  bool deskLampOn = false;
  bool smartTvOn = false;

  // Device settings
  int temperature = 24;
  String acMode = "Cool";
  int fanSpeed = 3;

  @override
  Widget build(BuildContext context) {
    final selectedRoom = ref.read(selectedRoomProvider);
    final deviceInRoom = ref.watch(deviceInRoomProvider);
    print("Total device in house: ${deviceInRoom.length}");
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.indigo),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // Room title
                  Text(
                    selectedRoom!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  // Settings button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.hexagon_outlined, color: Colors.indigo),
                      onPressed: () {
                        // Show room settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Room settings')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Room image
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                image: const DecorationImage(
                  image: AssetImage("assets/images/temp_room_img.jpg"),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
            // Devices list
            _deviceListBuild(),
          ],
        ),
      ),
    );
  }

  Widget _deviceListBuild() {
    final devices = [
      DeviceCard(
        icon: Icons.ac_unit,
        title: 'Air Conditioner',
        isOn: airConditionerOn,
        onToggle: (bool value) {
          setState(() {
            airConditionerOn = value;
          });
        },
      ),
      DeviceCard(
        icon: Icons.water_drop_outlined,
        title: 'Humidifier',
        isOn: humidifierOn,
        onToggle: (bool value) {
          setState(() {
            humidifierOn = value;
          });
        },
      ),
      DeviceCard(
        icon: Icons.lightbulb_outline,
        title: 'Desk Lamp',
        isOn: deskLampOn,
        onToggle: (bool value) {
          setState(() {
            deskLampOn = value;
          });
        },
      ),
      DeviceCard(
        icon: Icons.tv,
        title: 'Smart TV',
        isOn: smartTvOn,
        onToggle: (bool value) {
          setState(() {
            smartTvOn = value;
          });
        },
      ),
    ];
    final deviceInRoom = ref.watch(deviceInRoomProvider);
    return Expanded(
      child: Column(
        children: [
          Expanded( // ListView phải hiển thị device được gán!
            child: deviceInRoom.length > 0 ? ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final DeviceCard deviceCard = devices[index];
                Widget? expandedContent;
                if (deviceCard.title == 'Air Conditioner' && deviceCard.isOn) {
                  expandedContent = _buildAirConditionerControls();
                }

                return DeviceCard(
                  icon: deviceCard.icon,
                  title: deviceCard.title,
                  isOn: deviceCard.isOn,
                  onToggle: deviceCard.onToggle,
                  expandedContent: expandedContent,
                );
              },
            ) : Center(child: Text("No Device Available!"),),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Device'),
                    onPressed: () => _showAddDeviceDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.withOpacity(0.2),
                      foregroundColor: Colors.indigo,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Assign Room')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.withOpacity(0.2),
                      foregroundColor: Colors.indigo,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Assign Room'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Air Conditioner expanded controls
  Widget _buildAirConditionerControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Temperature slider
        Row(
          children: [
            const Icon(Icons.thermostat, color: Colors.indigo),
            const SizedBox(width: 8),
            const Text('Temperature:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Text(
              '${temperature}°C',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
        Slider(
          value: temperature.toDouble(),
          min: 16,
          max: 30,
          divisions: 14,
          activeColor: Colors.indigo,
          inactiveColor: Colors.indigo.withOpacity(0.2),
          onChanged: (value) {
            setState(() {
              temperature = value.round();
            });
          },
        ),

        // Mode dropdown
        Row(
          children: [
            const Icon(Icons.mode_fan_off, color: Colors.indigo),
            const SizedBox(width: 8),
            const Text('Mode:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: acMode,
              underline: Container(
                height: 1,
                color: Colors.indigo.withOpacity(0.5),
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    acMode = newValue;
                  });
                }
              },
              items: <String>['Cool', 'Heat', 'Fan', 'Auto', 'Dry']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddDeviceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add New Device',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildDeviceOption(context, Icons.lightbulb_outline, 'Light'),
                  _buildDeviceOption(context, Icons.thermostat, 'Thermostat'),
                  _buildDeviceOption(context, Icons.speaker, 'Speaker'),
                  _buildDeviceOption(context, Icons.camera_alt_outlined, 'Camera'),
                  _buildDeviceOption(context, Icons.lock_outline, 'Smart Lock'),
                  _buildDeviceOption(context, Icons.curtains_outlined, 'Curtains'),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeviceOption(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adding $label')),
        );
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.indigo),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Replace the DeviceCard class with this enhanced version

class DeviceCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isOn;
  final Function(bool) onToggle;
  final Widget? expandedContent;

  const DeviceCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.isOn,
    required this.onToggle,
    this.expandedContent,
  }) : super(key: key);

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.title == 'Air Conditioner';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Device icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.isOn ? Colors.indigo.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.isOn ? Colors.indigo : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),

                // Device name
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: widget.isOn ? Colors.indigo : Colors.grey[700],
                  ),
                ),

                const Spacer(),

                // Expand/collapse button (only if it's an Air Conditioner and device is on)
                if (widget.title == 'Air Conditioner' && widget.isOn)
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),

                // Toggle switch
                Switch(
                  value: widget.isOn,
                  onChanged: widget.onToggle,
                  activeColor: Colors.indigo,
                  activeTrackColor: Colors.indigo.withOpacity(0.5),
                ),
              ],
            ),
          ),

          // Expanded content
          if (widget.title == 'Air Conditioner' && widget.isOn && _isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.expandedContent,
            ),
        ],
      ),
    );
  }
}