import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadImage extends StatefulWidget {
  const UploadImage({super.key});
  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  File? imgPath;
  double? _deviceHeight, _deviceWidth;
  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () async {
        final result =
            await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null && result.files.isNotEmpty) {
          setState(() {
            imgPath = File(result.files.first.path!);
          });
        }
      },
      child: Center(
        child: Stack(
          children: [
            Container(
              height: _deviceWidth! * 0.42,
              width: _deviceWidth! * 0.42,
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                  ),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: imgPath != null
                          ? FileImage(imgPath!) as ImageProvider
                          : NetworkImage("https://i.pravatar.cc/300"))),
            ),
            // Icon add image
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_a_photo,
                  color: Colors.white,
                  size: 24,  // Kích thước icon
                ),
              ),
            )
          ]
        ),
      ),
    );
  }
}
