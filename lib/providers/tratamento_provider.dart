import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tratamento_model.dart';

class TratamentoProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Tratamento> _tratamentos = [];

  List<Tratamento> get tratamentos => _tratamentos;

  Future<void> fetchTratamentos() async {
    final snapshot = await _firestore.collection('tratamentos').get();
    _tratamentos = snapshot.docs.map((doc) => Tratamento.fromMap(doc.data(), doc.id)).toList();
    notifyListeners();
  }

  Future<void> addTratamento(Tratamento tratamento) async {
    await _firestore.collection('tratamentos').add(tratamento.toMap());
    fetchTratamentos();
  }

  Future<void> updateTratamento(String id, Tratamento tratamento) async {
    await _firestore.collection('tratamentos').doc(id).update(tratamento.toMap());
    fetchTratamentos();
  }
}