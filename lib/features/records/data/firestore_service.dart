import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirestoreService {
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;

  FirestoreService({
    this.firestore,
    this.auth,
  });

  String? get currentUserId => auth?.currentUser?.uid;

  Future<void> recordSolvedPlate(String plate, int currentScore) async {
    final uid = currentUserId;
    final db = firestore;
    if (uid == null || db == null) return;

    try {
      final userDoc = db.collection('users').doc(uid);
      await userDoc.set({
        'lastScore': currentScore,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await userDoc.collection('solved_plates').doc(plate).set({
        'plate': plate,
        'solvedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Graceful fallback for mock or offline environment
    }
  }

  Future<void> recordFinalScore(int score) async {
    final uid = currentUserId;
    final db = firestore;
    if (uid == null || db == null) return;

    try {
      final userDoc = db.collection('users').doc(uid);
      await userDoc.set({
        'highScore': FieldValue.increment(0),
        'lastScore': score,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<List<String>> getSolvedPlates() async {
    final uid = currentUserId;
    final db = firestore;
    if (uid == null || db == null) return [];

    try {
      final snapshot = await db
          .collection('users')
          .doc(uid)
          .collection('solved_plates')
          .get();

      return snapshot.docs.map((d) => d.id).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final uid = currentUserId;
    final db = firestore;
    if (uid == null || db == null) {
      return {'email': 'convidado@superweber.com', 'highScore': 0};
    }

    try {
      final doc = await db.collection('users').doc(uid).get();
      return doc.data() ?? {'email': auth?.currentUser?.email, 'highScore': 0};
    } catch (_) {
      return {'email': auth?.currentUser?.email ?? 'Usuário', 'highScore': 0};
    }
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  try {
    return FirestoreService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
  } catch (_) {
    return FirestoreService();
  }
});
