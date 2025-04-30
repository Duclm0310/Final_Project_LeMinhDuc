import 'package:energymanagement/components/view/DevicesList.dart';
import 'package:flutter/material.dart';

class DeviceDetailScreen extends StatefulWidget {
  final SmartDevice device;

  const DeviceDetailScreen({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  late int _selectedWattage;
  late int _brightness;
  late String _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedWattage = widget.device.settings['wattage'] as int;
    _brightness = widget.device.settings['brightness'] as int;
    _selectedMode = widget.device.settings['mode'] as String;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.device.type == 'Light') {
      return _buildLightDetailScreen();
    } else {
      return _buildClimateDetailScreen();
    }
  }

  Widget _buildLightDetailScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.device.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wattage selection
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  _buildWattageButton(8),
                  _buildWattageButton(9),
                  _buildWattageButton(12),
                  _buildWattageButton(16),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Controller label
            const Center(
              child: Text(
                'Controller',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Intensity controller
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: _brightness / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF6E7BF2),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_brightness%',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'intensity',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Min/Max labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Min',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _brightness.toDouble(),
                      min: 0,
                      max: 100,
                      onChanged: (value) {
                        setState(() {
                          _brightness = value.toInt();
                          widget.device.settings['brightness'] = _brightness;
                        });
                      },
                    ),
                  ),
                  const Text(
                    'Max',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mode buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModeButton('Auto', Icons.auto_awesome),
                _buildModeButton('Cool', Icons.ac_unit),
                _buildModeButton('Day', Icons.wb_sunny),
                _buildModeButton('Night', Icons.nightlight_round),
              ],
            ),

            const SizedBox(height: 32),

            // Power consumption
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Power consumption',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.bolt,
                            color: const Color(0xFF6E7BF2),
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.device.totalConsumption}Kwh',
                            style: TextStyle(
                              color: const Color(0xFF6E7BF2),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.power,
                            color: const Color(0xFF6E7BF2),
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.device.powerUsage * 15}Kwh',
                            style: TextStyle(
                              color: const Color(0xFF6E7BF2),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClimateDetailScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.device.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Temperature control
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Temperature',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 32),
                        onPressed: () {
                          setState(() {
                            if ((widget.device.settings['temperature'] as int) > 16) {
                              widget.device.settings['temperature'] = (widget.device.settings['temperature'] as int) - 1;
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${widget.device.settings['temperature']}°C',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 32),
                        onPressed: () {
                          setState(() {
                            if ((widget.device.settings['temperature'] as int) < 30) {
                              widget.device.settings['temperature'] = (widget.device.settings['temperature'] as int) + 1;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mode selection
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildClimateModeButton('Cool', Icons.ac_unit),
                      _buildClimateModeButton('Heat', Icons.whatshot),
                      _buildClimateModeButton('Fan', Icons.air),
                      _buildClimateModeButton('Auto', Icons.auto_awesome),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Fan speed
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fan Speed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFanSpeedButton('Low'),
                      _buildFanSpeedButton('Medium'),
                      _buildFanSpeedButton('High'),
                      _buildFanSpeedButton('Auto'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Power consumption
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Power consumption',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.bolt,
                            color: const Color(0xFF6E7BF2),
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.device.totalConsumption}Kwh',
                            style: TextStyle(
                              color: const Color(0xFF6E7BF2),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.power,
                            color: const Color(0xFF6E7BF2),
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.device.powerUsage / 1000 * 24}Kwh',
                            style: TextStyle(
                              color: const Color(0xFF6E7BF2),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWattageButton(int wattage) {
    final isSelected = _selectedWattage == wattage;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedWattage = wattage;
            widget.device.settings['wattage'] = wattage;
            widget.device.powerUsage = wattage.toDouble();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$wattage watt',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String mode, IconData icon) {
    final isSelected = _selectedMode == mode;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
          widget.device.settings['mode'] = mode;
        });
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF6E7BF2), width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF6E7BF2),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              mode,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6E7BF2) : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClimateModeButton(String mode, IconData icon) {
    final isSelected = widget.device.settings['mode'] == mode;

    return GestureDetector(
      onTap: () {
        setState(() {
          widget.device.settings['mode'] = mode;
        });
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6E7BF2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6E7BF2) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              mode,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFanSpeedButton(String speed) {
    final isSelected = widget.device.settings['fanSpeed'] == speed;

    return GestureDetector(
      onTap: () {
        setState(() {
          widget.device.settings['fanSpeed'] = speed;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6E7BF2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6E7BF2) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          speed,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}