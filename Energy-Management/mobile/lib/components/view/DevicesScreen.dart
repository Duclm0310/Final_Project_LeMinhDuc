import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Ultilities/ToggleSwitch.dart';
import '../../riverpod/device_data_provider.dart';
import '../viewmodel/device_viewmodel.dart';

class DeviceScreen extends ConsumerWidget {
  double? _deviceWidth, _deviceHeight;


// TODO: Change UI color base on Statistics screen // Login Screen
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    //final deviceProp = ref.read(deviceViewModelProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            //await deviceProp.getAllDevice();
            Navigator.pushNamed(context, "qr-scan");
          },
          backgroundColor: const Color.fromRGBO(107, 118, 242, 1),
          child: const Icon(Icons.add, color: Colors.white)),
      body: SingleChildScrollView(
        child: SizedBox(
          height: _deviceHeight! * 0.85,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TotalStats(),
              SizedBox(height: 20),
              Expanded(child: DeviceGrid()),
            ],
          ),
        ),
      ),
    );
  }
}

class TotalStats extends ConsumerWidget {
  const TotalStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesLength = ref.watch(deviceProvider).length;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E6F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              children: [
                 Text(
                  "Total Devices",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  devicesLength.toString(),
                  style: const TextStyle(
                    color: Color(0xFF6B76F2),
                    fontSize: 22,
                    fontFamily: 'Asul',
                    fontWeight: FontWeight.w700,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 3,
            height: 81,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Text("Total Energy Uses",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  )),
                Text("${devicesLength * 10} kWh",
                    style: const TextStyle(
                      color: Color(0xFF6B76F2),
                      fontSize: 22,
                      fontFamily: 'Asul',
                      fontWeight: FontWeight.w700,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class DeviceGrid extends ConsumerWidget {
  const DeviceGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesTypeList = ref.watch(deviceTypeProvider);
    final theme = Theme.of(context);
    return devicesTypeList.isEmpty
        ? const Center(child: Text("No device available"))
        : GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            // Padding same size with stats margin
            itemCount: devicesTypeList.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final device = devicesTypeList[index];
              return CardBuilder(
                  icon: device['icon']!,
                  title: device['type']!,
                  subtitle:
                      device['quantity']! > 1 ? "${device['quantity']!} device" : "${device['quantity']!} devices");
            },
          );
  }
}

class CardBuilder extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const CardBuilder({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E6F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(child: Image.asset(icon, width: 40, height: 40))),
              const ToggleSwitch(),
            ],
          ),
          const Spacer(),
          Text(title, style: _deviceTextStyle(fontSize: 16, isBold: true)),
          const SizedBox(height: 11),
          Text(subtitle, style: _deviceTextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  TextStyle _deviceTextStyle({required double fontSize, bool isBold = false}) {
    return TextStyle(
      color: Colors.black,
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontFamily: 'Inter',
    );
  }
}
