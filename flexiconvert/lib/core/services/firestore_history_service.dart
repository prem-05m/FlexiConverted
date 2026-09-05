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

  Query<Map<String, dynamic>> get _historyQuery =>
      _firestore.collection('jobs').where('userId', isEqualTo: _uid);
      
  CollectionReference<Map<String, dynamic>> get _jobsCollection =>
      _firestore.collection('jobs');

  /// Watch all history items as a real-time stream, ordered by timestamp desc.
  Stream<List<HistoryItem>> watchHistory() {
    return _historyQuery
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_docToHistoryItem).toList());
  }

  /// Watch only successful history items as a real-time stream.
  Stream<List<HistoryItem>> watchSuccessfulHistory() {
    return _historyQuery
        .where('status', isEqualTo: 'success')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_docToHistoryItem).toList());
  }

  /// Fetch all history items once (optionally limited).
  Future<List<HistoryItem>> findAllHistory({int? limit}) async {
    Query<Map<String, dynamic>> query =
        _historyQuery.orderBy('createdAt', descending: true);
    if (limit != null) query = query.limit(limit);
    final snap = await query.get();
    return snap.docs.map(_docToHistoryItem).toList();
  }

  /// Save or update a history item in Firestore.
  Future<void> putHistory(HistoryItem item) async {
    final docId = item.id != 0
        ? item.id.toString()
        : _jobsCollection.doc().id;

    await _jobsCollection.doc(docId).set(_historyItemToMap(item), SetOptions(merge: true));
  }

  /// Delete a single history item by its Isar id (stored as docId).
  Future<bool> deleteHistory(int id) async {
    try {
      await _jobsCollection.doc(id.toString()).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Clear all history for this user.
  Future<void> clearHistory() async {
    final snap = await _historyQuery.get();
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
    
    // Check if it's a backend job or frontend history
    item.fileName = data['fileName'] as String? ?? 'Backend Job';
    item.toolType = data['toolType'] as String? ?? '';
    item.timestamp = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    
    // Convert backend status to frontend status
    String rawStatus = data['status'] as String? ?? 'success';
    if (rawStatus == 'completed') rawStatus = 'success';
    item.status = rawStatus;
    
    // Backend jobs have outputFiles array, local has outputPath
    if (data['outputFiles'] != null && (data['outputFiles'] as List).isNotEmpty) {
      item.cloudUrl = (data['outputFiles'] as List).first as String;
    } else {
      item.cloudUrl = data['cloudUrl'] as String?;
    }
    
    item.outputPath = data['outputPath'] as String? ?? '';
    item.durationMs = (data['durationMs'] as num?)?.toInt() ?? 0;
    item.fileSizeBytes = (data['fileSizeBytes'] as num?)?.toInt() ?? 0;
    item.deviceName = data['deviceName'] as String?;
    
    return item;
  }

  Map<String, dynamic> _historyItemToMap(HistoryItem item) {
    return {
      'userId': _uid,
      'fileName': item.fileName,
      'toolType': item.toolType,
      'createdAt': Timestamp.fromDate(item.timestamp),
      'updatedAt': Timestamp.fromDate(item.timestamp),
      'status': item.status == 'success' ? 'completed' : item.status,
      'outputPath': item.outputPath,
      'cloudUrl': item.cloudUrl,
      'durationMs': item.durationMs,
      'fileSizeBytes': item.fileSizeBytes,
      'deviceName': item.deviceName,
    };
  }
}
