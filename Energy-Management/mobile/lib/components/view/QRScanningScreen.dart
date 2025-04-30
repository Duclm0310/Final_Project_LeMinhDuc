import 'package:energymanagement/components/viewmodel/device_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanningScreen extends ConsumerStatefulWidget   {
  const QrScanningScreen({super.key});

  @override
  ConsumerState<QrScanningScreen> createState() => _QrScanningScreenState();
}

class _QrScanningScreenState extends ConsumerState<QrScanningScreen> {
  bool isProcessing = false;

  Future<void> _handleScan(BuildContext context, WidgetRef ref, String qrData) async {
    if (isProcessing) return;
    isProcessing = true;
    if (qrData.startsWith("http")) {
      final success = await ref.read(deviceViewModelProvider).getDeviceByQr(qrData);
      if (success) {
        Navigator.pop(context); // Đóng màn hình quét nếu lấy được dữ liệu
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi khi lấy dữ liệu thiết bị")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("QR Code không hợp lệ")),
      );
    }
    Future.delayed(const Duration(seconds: 1), () {
      isProcessing = false; // Cho phép quét lại sau 1 giây
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                String qrData = barcode.rawValue!;
                if (qrData.startsWith("http")) {
                  _handleScan(context, ref, qrData);
                }
              }
            }
          },
        ),
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}
