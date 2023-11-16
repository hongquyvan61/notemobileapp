import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  String? currentUser = FirebaseAuth.instance.currentUser?.email;

  Future<String> uploadImage(File file) async {
    final metadata = SettableMetadata(contentType: "image/jpeg");
    Reference storageReference = firebaseStorage
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}');
    // Tải lên hình ảnh lên Firebase Storage
    UploadTask uploadTask = storageReference.putFile(file, metadata);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => print('Image uploaded'));
    // Lấy URL của hình ảnh sau khi tải lên
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future<void> deleteImage(String urlImage) async {
    Reference storageReference = firebaseStorage.refFromURL(urlImage);
    await storageReference.delete();
  }

  Future<void> deleteListImage(List<dynamic> listUrlImage) async {
    List temp = listUrlImage;
    for(Map<String, dynamic> data in temp) {

        if (data.containsKey('image')) {
          Reference storageReference = firebaseStorage.refFromURL(data['image']);
          await storageReference.delete();
        }
        if (data.containsKey('local_image')) {
          if (data["local_image"] != "") {
            await File(data["local_image"]).delete();
          }
        }

    }
  }

  Future<void> deleteListOnlineImage(List<dynamic> listUrlImage) async{
    listUrlImage.forEach((element) async {
      Map<String, dynamic> a = element;
      if (a.containsKey('image')) {
        Reference storageReference = firebaseStorage.refFromURL(a['image']);
        await storageReference.delete();
      }
    });
  }

  Future<void> downloadImage(String url, String localUrl) async {
    final directory = await getApplicationDocumentsDirectory();
    String pathAppDoc = directory.path;

    String prefix = "/data/user/0/com.example.notemobileapp/app_flutter/";
    String name = localUrl.substring(prefix.length);
    String destinationPath = '$pathAppDoc/$name';

    final DefaultCacheManager cacheManager = DefaultCacheManager();
    final File file = await cacheManager.getSingleFile(url);

    // Lưu vào thư mục flutter của ứng dụng
    final File localFile = await file.copy(destinationPath);
    if (file.existsSync()) {
      file.delete();
    }
  }
}
