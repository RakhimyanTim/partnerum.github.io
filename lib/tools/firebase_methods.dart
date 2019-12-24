import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:partnerum/tools/app_methods.dart';
import 'app_data.dart';
import 'app_tools.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseMethods implements AppMethods {
  Firestore firestore = Firestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Future<String> createUserAccount(
      {String fullname, String phone, String email, String password}) async {
    // TODO: implement createUserAccount
    FirebaseUser user;

    try {
      user = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on PlatformException catch (e) {
      //print(e.details);
      return errorMSG(e.details);
    }

    try {
      if (user != null) {
        await firestore.collection(usersData).document(user.uid).setData({
          userId: user.uid,
          userName: fullname,
          userEmail: email,
          userPhone: phone
        });

        writeDataLocally(key: userId, value: user.uid);
        writeDataLocally(key: fullname, value: fullname);
        writeDataLocally(key: userEmail, value: userEmail);
      }
    } on PlatformException catch (e) {
      //print(e.details);
      return errorMSG(e.details);
    }

    return user == null ? errorMSG("Error") : successfulMSG();
  }

  @override
  Future<String> logginUser({String email, String password}) async {
    // TODO: implement logginUser

    FirebaseUser user;
    try {
      user = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (user != null) {
        DocumentSnapshot userInfo = await getUserInfo(user.uid);
        await writeDataLocally(key: userId, value: userInfo[userId]);
        await writeDataLocally(
            key: userName, value: userInfo[userName]);
        await writeDataLocally(key: userEmail, value: userInfo[userEmail]);
        await writeDataLocally(key: userPhone, value: userInfo[userPhone]);
        await writeDataLocally(key: userImage, value: userInfo[userImage]);
        await writeBoolDataLocally(key: 'loggedIN', value: true);

        print(userInfo[userEmail]);
      }
    } on PlatformException catch (e) {
      //print(e.details);
      return errorMSG(e.details);
    }

    return user == null ? errorMSG("Error") : successfulMSG();
  }

  Future<bool> complete() async {
    return true;
  }

  Future<bool> notComplete() async {
    return false;
  }

  Future<String> successfulMSG() async {
    return successful;
  }

  Future<String> errorMSG(String e) async {
    return e;
  }

  @override
  Future<bool> logOutUser() async {
    // TODO: implement logOutUser
    await auth.signOut();
    await clearDataLocally();

    return complete();
  }

  @override
  Future<DocumentSnapshot> getUserInfo(String userid) async {
    // TODO: implement getUserInfo
    return await firestore.collection(usersData).document(userid).get();
  }

  @override
  Future<String> addNewProduct({Map newProduct}) async {
    // TODO: implement addNewProduct
    String offerId;

    await firestore.collection(offers).add(newProduct).then((documentRef) {
      offerId = documentRef.documentID;
      Firestore.instance.collection(offers).document(offerId).updateData({"offerId": offerId});
    });


    return offerId;
  }

  @override
  Future<List<String>> uploadProductImages({List<File> imageList, String docID}) async{
    // TODO: implement uploadProductImages
    List<String> imagesUrl = new List();

    try {
      for (int s = 0; s < imageList.length; s++) {
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child(offers)
            .child(docID)
            .child(docID + '$s.jpg');
        StorageUploadTask uploadTask = storageReference.putFile(imageList[s]);
        String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
        imagesUrl.add(downloadUrl);
      }

    } on PlatformException catch (e) {
      imagesUrl.add(error);
      print(e.details);
    }
    return imagesUrl;
  }

  @override
  Future<bool> updateProductImages({List<String> data, String docID}) async {
    // TODO: implement updateProductImages

    bool msg;

    await firestore.collection(offers)
        .document(docID)
        .updateData({offerImages: data})
        .whenComplete(() {
      msg = true;
    });

    return msg;
  }
}