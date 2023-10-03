import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CustomImageCache extends StatefulWidget {
  final String imageUrl;

  CustomImageCache({required this.imageUrl});

  @override
  _CustomImageCacheState createState() => _CustomImageCacheState();
}

class _CustomImageCacheState extends State<CustomImageCache> {
  late File _imageFile;

  @override
  void initState() {
    super.initState();
    // Initialize _imageFile with a default value to avoid LateInitializationError.
    _imageFile = File(
        'default_image_path'); // You can provide a placeholder image path here.
    _loadImage();
  }

  Future<void> _loadImage() async {
    final response = await http.get(Uri.parse(widget.imageUrl));

    if (response.statusCode == 200) {
      final appDir = await getApplicationDocumentsDirectory();
      final file =
          File('${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.png');

      final completer = Completer<void>();

      final List<Future<void>> futures = [];

      futures.add(file.writeAsBytes(response.bodyBytes));

      Future.wait(futures).then((_) {
        if (mounted) {
          setState(() {
            _imageFile = file;
          });
          completer.complete();
        }
      });

      await completer.future;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageFile != null) {
      return Image.file(
        _imageFile,
        fit: BoxFit.cover,
        width: 188,
        height: 188,
      );
    } else {
      return CircularProgressIndicator(); // Show a loading indicator while image is being fetched.
    }
  }
}
