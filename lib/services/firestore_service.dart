import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/estoque_model.dart';
import '../models/lote_model.dart';
import '../models/beneficiamento_model.dart';
import '../models/tratamento_model.dart';

class FirestoreService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para buscar tratamento por lote
  Future<Tratamento?> getTratamentoPorLote(String lote) async {
    final snapshot =
        await _firestore
            .collection('tratamentos')
            .where('lote', isEqualTo: lote)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final produtos =
          List<Map<String, dynamic>>.from(doc['produtos'])
              .map(
                (produto) => {
                  'nome': produto['nome'].toString(),
                  'dosagem': produto['dosagem'].toString(),
                },
              )
              .toList();

      return Tratamento(
        id: doc.id,
        lote: doc['lote'],
        maquina: doc['maquina'],
        produtos: produtos,
        corEtiqueta: doc['corEtiqueta'],
        status: doc['status'],
      );
    }
    return null;
  }

  // Métodos para Lotes
  Stream<List<Lote>> getLotes() {
    return _firestore.collection('lotes').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Lote.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addLote(Lote lote) async {
    await _firestore.collection('lotes').add(lote.toMap());
  }

  Future<void> updateLote(Lote lote) async {
    await _firestore.collection('lotes').doc(lote.id).update(lote.toMap());
  }

  Future<void> deleteLote(String id) async {
    await _firestore.collection('lotes').doc(id).delete();
  }

  // Métodos para Beneficiamento
  Stream<List<Beneficiamento>> getBeneficiamentos() {
    return _firestore.collection('beneficiamentos').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Beneficiamento.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addBeneficiamento(Beneficiamento beneficiamento) async {
    await _firestore.collection('beneficiamentos').add({
      'lote': beneficiamento.lote,
      'cultivar': beneficiamento.cultivar,
      'campo': beneficiamento.campo,
      'qtdIdeal': beneficiamento.qtdIdeal,
      'qtdReal': beneficiamento.qtdReal,
      'categoria': beneficiamento.categoria,
      'peneira': beneficiamento.peneira,
      'cooperado': beneficiamento.cooperado,
      'qtdTotal': beneficiamento.qtdTotal,
      'qtdSementes': beneficiamento.qtdSementes,
      'data': beneficiamento.data,
      'repPms': beneficiamento.repPms,
      'pesoEnsaque': beneficiamento.pesoEnsaque,
      'pesoEtiqueta': beneficiamento.pesoEtiqueta,
      'status': beneficiamento.status,
      'safra': beneficiamento.safra,
      'danoMecanico': beneficiamento.danoMecanico,
      'retencao': beneficiamento.retencao,
      'umidade': beneficiamento.umidade,
    });
  }

  Future<void> addTratamento(Tratamento tratamento) async {
    try {
      final docRef = await _firestore.collection('tratamentos').add({
        'lote': tratamento.lote,
        'maquina': tratamento.maquina,
        'produtos': tratamento.produtos,
        'corEtiqueta': tratamento.corEtiqueta,
        'status': 'Soja Branca',
      });
      tratamento.id = docRef.id;
      print('Tratamento adicionado com sucesso! ID: ${tratamento.id}');
    } catch (e) {
      print('Erro ao adicionar Tratamento: $e');
    }
  }

  Future<void> updateTratamento(Tratamento tratamento) async {
    try {
      await _firestore.collection('tratamentos').doc(tratamento.id).update({
        'lote': tratamento.lote,
        'maquina': tratamento.maquina,
        'produtos': tratamento.produtos,
        'corEtiqueta': tratamento.corEtiqueta,
        'status': tratamento.status,
      });
      final estoqueSnapshot =
      await _firestore
          .collection('estoques')
          .where('lote', isEqualTo: tratamento.lote)
          .get();
      if (estoqueSnapshot.docs.isNotEmpty) {
        final estoqueId = estoqueSnapshot.docs.first.id;

        await _firestore.collection('estoques').doc(estoqueId).update({
          'status': tratamento.status,
          'corEtiqueta': tratamento.corEtiqueta,
        });
      }
      // Atualiza o estoque se o status for "Concluído"
      if (tratamento.status == 'Concluído') {
        await atualizarEstoque(tratamento.lote, true);
      }
      print('Tratamento atualizado com sucesso!');
    }catch(e){
      print('Erro ao atualizar tratamento: $e');

    }
  }

  Future<void> deleteTratamento(String id) async {
    try {
      await _firestore.collection('tratamentos').doc(id).delete();
      print('TRATAMENTO DELETADO COM SUCESSO!!!!');
    } catch (e) {
      print('Erro ao deletar tratamento');
    }
  }

  Stream<List<Tratamento>> getTratamentos() {
    return _firestore.collection('tratamentos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Convertendo os produtos para Map<String, String>
        final produtos =
            List<Map<String, dynamic>>.from(doc['produtos'])
                .map(
                  (produto) => {
                    'nome': produto['nome'].toString(),
                    'dosagem': produto['dosagem'].toString(),
                  },
                )
                .toList();

        return Tratamento(
          id: doc.id,
          lote: doc['lote'],
          maquina: doc['maquina'],
          produtos: produtos,
          corEtiqueta: doc['corEtiqueta'],
          status: doc['status'],
        );
      }).toList();
    });
  }

  // No FirestoreService
  Stream<List<Estoque>> getEstoques() {
    return _firestore.collection('estoques').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Estoque(
          id: doc.id,
          lote: doc['lote'],
          camaraFria: doc['camaraFria'],
          produtor: doc['produtor'],
          tratado:
              doc['tratado'] ?? false, // Adicione outros campos necessários
        );
      }).toList();
    });
  }

  Future<void> addEstoque(Estoque estoque) async {
    await _firestore.collection('estoques').add({
      'lote': estoque.lote,
      'camaraFria': estoque.camaraFria,
      'produtor': estoque.produtor,
      'tratado': estoque.tratado,
    });
  }

  Future<void> updateEstoque(Estoque estoque) async {
    await _firestore.collection('estoques').doc(estoque.id).update({
      'lote': estoque.lote,
      'camaraFria': estoque.camaraFria,
      'tratado': estoque.tratado,
    });
  }

  Future<void> deleteEstoque(String id) async {
    await _firestore.collection('estoques').doc(id).delete();
  }

  // Atualiza o estoque quando o tratamento é concluído
  Future<void> atualizarEstoque(String lote, bool tratado) async {
    final estoqueSnapshot =
        await _firestore
            .collection('estoques')
            .where('lote', isEqualTo: lote)
            .get();
    if (estoqueSnapshot.docs.isNotEmpty) {
      final estoqueId = estoqueSnapshot.docs.first.id;
      await _firestore.collection('estoques').doc(estoqueId).update({
        'tratado': tratado,
      });
    }
  }

  Future<bool> isAdmin(String userId) async {
    final doc = await _firestore.collection('usuarios').doc(userId).get();
    return doc['isAdmin'] ?? false;
  }

  Future<String?> getNomeUsuario(String userId) async {
    final doc = await _firestore.collection('usuarios').doc(userId).get();
    return doc['nome'] ?? 'Usuário';
  }

  Future<void> setAdmin(String userId, bool isAdmin) async {
    await _firestore.collection('usuarios').doc(userId).update({
      'isAdmin': isAdmin,
    });
  }




}
