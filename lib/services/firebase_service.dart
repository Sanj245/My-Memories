import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/achievement.dart';

class FirebaseService {
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  //////////////////////////////////////////////////////
  /// LOAD
  //////////////////////////////////////////////////////

  static Future<List<Achievement>> load() async {
    final snapshot = await _db
        .collection("achievements")
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Achievement.fromMap(
        doc.data(),
        doc.id,
      );
    }).toList();
  }

  //////////////////////////////////////////////////////
  /// ADD
  //////////////////////////////////////////////////////

  static Future<Achievement> add(
    Achievement a, {
    List<Uint8List>? webImages,
  }) async {
    try {
      print("FIREBASE SERVICE: Starting add...");
      List<String> imageUrls = [];

      //////////////////////////////////////////////////////
      /// WEB IMAGE UPLOAD
      //////////////////////////////////////////////////////

      if (kIsWeb && webImages != null) {
        print("FIREBASE SERVICE: Web image upload...");
        final uploadTasks = webImages.map((bytes) async {
          final fileName = DateTime.now().microsecondsSinceEpoch.toString() + "_" + webImages.indexOf(bytes).toString();
          final ref = _storage.ref().child("images/$fileName");
          await ref.putData(bytes);
          return await ref.getDownloadURL();
        }).toList();

        imageUrls.addAll(await Future.wait(uploadTasks));
        print("FIREBASE SERVICE: Web image upload complete.");
      }

      //////////////////////////////////////////////////////
      /// MOBILE IMAGE UPLOAD
      //////////////////////////////////////////////////////

      if (!kIsWeb) {
        print("FIREBASE SERVICE: Mobile image upload...");
        final uploadTasks = a.images.where((path) => path.isNotEmpty).map((path) async {
          final file = File(path);
          final fileName = DateTime.now().microsecondsSinceEpoch.toString() + "_" + a.images.indexOf(path).toString();
          final ref = _storage.ref().child("images/$fileName");
          await ref.putFile(file);
          return await ref.getDownloadURL();
        }).toList();

        imageUrls.addAll(await Future.wait(uploadTasks));
        print("FIREBASE SERVICE: Mobile image upload complete.");
      }

      //////////////////////////////////////////////////////
      /// SAVE TO FIRESTORE (FIRE AND FORGET)
      //////////////////////////////////////////////////////

      print("FIREBASE SERVICE: Saving to Firestore...");
      
      final docRef = _db.collection("achievements").doc();
      a.id = docRef.id;
      a.images = imageUrls; // Update images to the uploaded URLs
      
      // Do not await the set operation to prevent hanging on Web
      docRef.set({
        "title": a.title,
        "description": a.description,
        "category": a.category,
        "date": a.date,
        "location": a.location,
        "images": imageUrls,
        "coverImage": a.coverImage,
        "impact": a.impact,
        "tags": a.tags,
        "createdAt": Timestamp.now(),
      }).catchError((e) {
        print("Firestore background set error: $e");
      });

      print("✅ Firebase add success (local)");
      return a;
    } catch (e, stacktrace) {
      print("❌ Firebase error: $e");
      print("Stacktrace: $stacktrace");
      rethrow;
    }
  }

  //////////////////////////////////////////////////////
  /// UPDATE
  //////////////////////////////////////////////////////

  static Future<void> update(String id, Achievement a) async {
    try {
      await _db.collection("achievements").doc(id).update({
        "title": a.title,
        "description": a.description,
        "category": a.category,
        "date": a.date,
        "location": a.location,
        "coverImage": a.coverImage,
        "impact": a.impact,
        "tags": a.tags,
      });
      print("✅ Firebase update success");
    } catch (e) {
      print("❌ Firebase error: $e");
      rethrow;
    }
  }

  //////////////////////////////////////////////////////
  /// DELETE
  //////////////////////////////////////////////////////

  static Future<void> delete(String id) async {
    await _db.collection("achievements").doc(id).delete();
  }
}