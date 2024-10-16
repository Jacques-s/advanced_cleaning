import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<String>> uploadImages(
      String folderName, String objectId, List<PlatformFile> files) async {
    List<String> imageUrls = [];

    try {
      for (var file in files) {
        final String fileName = file.name;
        final Reference ref =
            _storage.ref().child('$folderName/$objectId/$fileName');

        final UploadTask uploadTask = ref.putFile(File(file.path!));
        final TaskSnapshot taskSnapshot = await uploadTask;

        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      return imageUrls;
    } catch (e) {
      print('Error uploading images: $e');
      throw Exception('Failed to upload images');
    }
  }

  Future<void> deleteImages(String folderName, String objectId,
      {String? fileName}) async {
    try {
      if (fileName != null) {
        print('Deleting image: $folderName/$objectId/$fileName');
        await _storage.ref().child('$folderName/$objectId/$fileName').delete();
      } else {
        final Reference ref = _storage.ref().child('$folderName/$objectId');
        final ListResult result = await ref.listAll();

        for (var item in result.items) {
          await item.delete();
        }
      }
    } catch (e) {
      print('Error deleting images: $e');
      throw Exception('Failed to delete images');
    }
  }
}
