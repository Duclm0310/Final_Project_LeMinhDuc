import 'package:flutter/material.dart';

class ToggleSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const ToggleSwitch({super.key, this.initialValue = false, this.onChanged});

  @override
  _ToggleSwitchState createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch> {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _isOn,
      onChanged: (value) {
        setState(() {
          _isOn = value;
        });
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFF65558F),
      inactiveTrackColor: Colors.grey[300],
      inactiveThumbColor: Colors.white,
    );
  }
}
