import  'package:energymanagement/components/models/RoomModel.dart';
import 'package:energymanagement/components/Ultilities/TempRoomView.dart';
import 'package:energymanagement/riverpod/temp_house_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/HouseModel.dart';
import '../../riverpod/house_data_provider.dart';
import '../viewmodel/house_viewmodel.dart';

class AddHouseScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  void _submitForm(BuildContext context, WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newHouse = ref.watch(tempHouseProvider);
      final houseProvider = ref.read(houseViewModelProvider);
      await houseProvider.submitHouse();
      final isEdit = ref.read(tempHouseProvider.notifier).isEdit;
      if(context.mounted){
        if(isEdit){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('House "${newHouse.name}" update successfully!')),
          );
          Navigator.pop(context);
          Navigator.pop(context);
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('House "${newHouse.name}" create successfully!')),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final tempHouse = ref.watch(tempHouseProvider);
      final tempHouseFunc = ref.read(tempHouseProvider.notifier);
      final isEdit = ref.read(tempHouseProvider.notifier).isEdit;
      return Scaffold(
        appBar: AppBar(
            title: Text(isEdit ? "Edit House" :"Crate House"),
            leading: IconButton(onPressed: (){
              tempHouseFunc.reset();
              Navigator.pop(context);
      }, icon: Icon(Icons.arrow_back)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  // controller: _nameController,
                  initialValue: tempHouse.name,
                  decoration: const InputDecoration(
                    labelText: 'House Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                  ),
                  onChanged: (value) => tempHouseFunc.setName(value)
                  ,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a house name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  // controller: _addressController,
                  initialValue: tempHouse.address,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  onChanged: (value)=>tempHouseFunc.setAddress(value),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the house address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text('Rooms', style: Theme.of(context).textTheme.bodyMedium),
                ...tempHouse.rooms.map((r) {
                  return TempRoom(
                    key: ValueKey(r.id),
                    room: r,
                    onRemove: () => tempHouseFunc.removeRoomById(r.id!),
                    onUpdate: (updatedRoom) => tempHouseFunc.updateRoom(updatedRoom),
                  );
                }),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Room'),
                  onPressed: (){
                    final newRoom = RoomModel(
                      id: DateTime.now().toString(),
                      name: 'Room',
                      roomType: 'Bedroom',
                      roomResident: [],
                      house_id: ref.read(tempHouseProvider).id,
                    );
                    ref.read(tempHouseProvider.notifier).addRoom(newRoom);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _submitForm(context, ref),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text("${isEdit ? "Update House" : "Create House"}"),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
