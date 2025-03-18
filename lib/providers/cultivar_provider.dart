import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cultivar_model.dart';

class CultivarProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Cultivar> _cultivares = [];

  List<Cultivar> get cultivares => _cultivares;

  Future<void> fetchCultivares() async {
    final snapshot = await _firestore.collection('cultivares').get();
    _cultivares = snapshot.docs.map((doc) => Cultivar.fromMap(doc.data(), doc.id)).toList();
    notifyListeners();
  }

  Future<void> addCultivar(Cultivar cultivar) async {
    await _firestore.collection('cultivares').add(cultivar.toMap());
    fetchCultivares();
  }
}