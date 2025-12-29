// import 'dart:io';
// import 'package:cloudinary_public/cloudinary_public.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:path/path.dart' as p;

// class CloudinaryService {
//   // ⚠️ REPLACE with your actual credentials
//   static const String _cloudName = "jb-demo"; 
//   static const String _uploadPreset = "notes_preset";

//   final CloudinaryPublic _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

//   /// Compresses image and uploads to Cloudinary
//   Future<Map<String, String>> uploadFile(File file, String type) async {
//     try {
//       File fileToUpload = file;

//       // 1. Compress if Image
//       if (type == 'image') {
//         final targetPath = '${file.path}_compressed.jpg';
//         final compressedFile = await FlutterImageCompress.compressAndGetFile(
//           file.absolute.path,
//           targetPath,
//           quality: 70, 
//         );
//         if (compressedFile != null) {
//           fileToUpload = File(compressedFile.path);
//         }
//       }

//       // 2. Upload to Cloudinary
//       CloudinaryResponse response = await _cloudinary.uploadFile(
//         CloudinaryFile.fromFile(fileToUpload.path, resourceType: CloudinaryResourceType.Auto),
//       );

//       return {
//         'url': response.secureUrl,
//         'type': type, // 'image' or 'pdf'
//       };
//     } catch (e) {
//       throw Exception("Cloudinary Upload Failed: $e");
//     }
//   }
// }