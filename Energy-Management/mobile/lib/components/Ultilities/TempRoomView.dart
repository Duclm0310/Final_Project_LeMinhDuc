import 'package:flutter/material.dart';
import '../models/RoomModel.dart';

class TempRoom extends StatefulWidget {
  final RoomModel room;
  final void Function(RoomModel updatedRoom) onUpdate;
  final VoidCallback onRemove;

  const TempRoom({
    super.key,
    required this.room,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<TempRoom> createState() => _TempRoomState();
}

class _TempRoomState extends State<TempRoom> {
  late TextEditingController _nameController;
  String? _selectedType;

  final List<String> _roomTypes = [
    'Bedroom',
    'Living Room',
    'Kitchen',
    'Bathroom',
    'Office'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room.name);
    _selectedType = widget.room.roomType;
  }

  void _handleNameChanged(String value) {
    widget.onUpdate(widget.room.copyWith(name: value));
  }

  void _handleTypeChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedType = value;
      });
      widget.onUpdate(widget.room.copyWith(roomType: value));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Room Name',
                border: OutlineInputBorder(),
              ),
              onChanged: _handleNameChanged,
              validator: (value) => value == null || value.isEmpty ? 'Enter room name' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Room Type',
                border: OutlineInputBorder(),
              ),
              items: _roomTypes
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: _handleTypeChanged,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text("Remove", style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
