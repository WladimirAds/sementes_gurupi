import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lote_model.dart';

class LoteProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Lote> _lotes = [];

  List<Lote> get lotes => _lotes;

  Future<void> fetchLotes() async {
    final snapshot = await _firestore.collection('lotes').get();
    _lotes = snapshot.docs.map((doc) => Lote.fromMap(doc.data(), doc.id)).toList();
    notifyListeners();
  }

  Future<void> addLote(Lote lote) async {
    try {
      // Adiciona o lote localmente
      _lotes.add(lote);
      notifyListeners(); // Notifica os ouvintes para atualizar a UI

      // Adiciona o lote no Firestore
      final docRef = await _firestore.collection('lotes').add(lote.toMap());

      // Atualiza o ID do lote com o ID gerado pelo Firestore
      lote.id = docRef.id;
      notifyListeners(); // Notifica os ouvintes novamente

      // Atualiza a lista de lotes do Firestore
      await fetchLotes();
    } catch (e) {
      print('Erro ao adicionar lote: $e');
      // Remove o lote da lista local em caso de erro
      _lotes.remove(lote);
      notifyListeners();
    }
  }

  Future<void> updateLote(String id, Lote lote) async {
    try {
      await _firestore.collection('lotes').doc(id).update(lote.toMap());
      fetchLotes(); // Atualiza a lista de lotes após editar
    } catch (e) {
      print('Erro ao atualizar lote: $e');
    }
  }
}