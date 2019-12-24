import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AppMethods {
  Future<String> logginUser({String email, String password});
  Future<String> createUserAccount(
      {String fullname, String phone, String email, String password});
  Future<bool> logOutUser();

  Future<DocumentSnapshot> getUserInfo(String userid);
  Future<String> addNewProduct({Map newProduct});
  Future<List<String>> uploadProductImages ({List<File> imageList, String docID});
  Future<bool> updateProductImages ({List<String> data, String docID});
}