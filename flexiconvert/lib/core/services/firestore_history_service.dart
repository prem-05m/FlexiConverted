import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/models/history_model.dart';

/// Firestore-backed history service that syncs conversion history
/// per user account across all devices.
class FirestoreHistoryService {
  final FirebaseFirestore _firestore;
  final String _uid;

  FirestoreHistoryService({required String uid, FirebaseFirestore? firestore})
      : _uid = uid,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _historyCollection =>
      _firestore.collection('users').doc(_uid).collection('history');

  /// Watch all history items as a real-time stream, ordered by timestamp desc.
  Stream<List<HistoryItem>> watchHistory() {
    return _historyCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_docToHistoryItem).toList());
  }

  /// Watch only successful history items as a real-time stream.
  Stream<List<HistoryItem>> watchSuccessfulHistory() {
    return _historyCollection
        .where('status', isEqualTo: 'success')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_docToHistoryItem).toList());
  }

  /// Fetch all history items once (optionally limited).
  Future<List<HistoryItem>> findAllHistory({int? limit}) async {
    Query<Map<String, dynamic>> query =
        _historyCollection.orderBy('timestamp', descending: true);
    if (limit != null) query = query.limit(limit);
    final snap = await query.get();
    return snap.docs.map(_docToHistoryItem).toList();
  }

  /// Save or update a history item in Firestore.
  Future<void> putHistory(HistoryItem item) async {
    final docId = item.id != 0
        ? item.id.toString()
        : _historyCollection.doc().id;

    await _historyCollection.doc(docId).set(_historyItemToMap(item));
  }

  /// Delete a single history item by its Isar id (stored as docId).
  Future<bool> deleteHistory(int id) async {
    try {
      await _historyCollection.doc(id.toString()).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Clear all history for this user.
  Future<void> clearHistory() async {
    final snap = await _historyCollection.get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ---- Converters ----

  HistoryItem _docToHistoryItem(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final item = HistoryItem();
    item.id = int.tryParse(doc.id) ?? 0;
    item.fileName = data['fileName'] as String? ?? '';
    item.toolType = data['toolType'] as String? ?? '';
    item.timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    item.status = data['status'] as String? ?? 'success';
    item.outputPath = data['outputPath'] as String? ?? '';
    item.durationMs = (data['durationMs'] as num?)?.toInt() ?? 0;
    item.fileSizeBytes = (data['fileSizeBytes'] as num?)?.toInt() ?? 0;
    return item;
  }

  Map<String, dynamic> _historyItemToMap(HistoryItem item) {
    return {
      'fileName': item.fileName,
      'toolType': item.toolType,
      'timestamp': Timestamp.fromDate(item.timestamp),
      'status': item.status,
      'outputPath': item.outputPath,
      'durationMs': item.durationMs,
      'fileSizeBytes': item.fileSizeBytes,
    };
  }
}
