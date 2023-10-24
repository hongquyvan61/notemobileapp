import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  String? currentUser = FirebaseAuth.instance.currentUser?.email;

  Future<String> uploadImage(File file) async {
    Reference storageReference = firebaseStorage
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}');
    // Tải lên hình ảnh lên Firebase Storage
    UploadTask uploadTask = storageReference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    // Lấy URL của hình ảnh sau khi tải lên
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future<void> deleteImage(String urlImage) async {
    Reference storageReference = firebaseStorage.refFromURL(urlImage);
    await storageReference.delete();
  }

  void deleteListImage(List<dynamic> listUrlImage) {
    listUrlImage.forEach((element) async {
      Map<String, dynamic> a = element;
      if (a.containsKey('image')) {
        Reference storageReference = firebaseStorage.refFromURL(a['image']);
        await storageReference.delete();
      }
      if(a.containsKey('local_image')){
        if(a["local_image"] != ""){
          await File(a["local_image"]).delete();
        }
      }
    });
  }

  void deleteListOnlineImage(List<dynamic> listUrlImage){
    listUrlImage.forEach((element) async {
      Map<String, dynamic> a = element;
      if (a.containsKey('image')) {
        Reference storageReference = firebaseStorage.refFromURL(a['image']);
        await storageReference.delete();
      }
    });
  }
}
