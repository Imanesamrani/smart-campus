import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _announcementsRef =>
      _firestore.collection('announcements');

  String _normalizeValue(String? value) {
    return (value ?? '').trim().toLowerCase();
  }

  String _normalizeRole(String? role) {
    final normalized = _normalizeValue(role);

    if (normalized == 'admin' || normalized == 'administrateur') {
      return 'admin';
    }
    if (normalized == 'enseignant' || normalized == 'teacher') {
      return 'enseignant';
    }
    if (normalized == 'etudiant' ||
        normalized == 'étudiant' ||
        normalized == 'student' ||
        normalized == 'utilisateur' ||
        normalized == 'user') {
      return 'étudiant';
    }

    return normalized;
  }

  bool _matchesValue(List<String> values, String? expected) {
    final normalizedValues = values.map(_normalizeValue).toList();

    return normalizedValues.contains('tous') ||
        (expected != null && normalizedValues.contains(_normalizeValue(expected)));
  }

  Future<List<Announcement>> getAllAnnouncementsAdmin(String adminId) async {
    final snapshot = await _announcementsRef
        .where('authorId', isEqualTo: adminId)
        .get();

    final list = snapshot.docs
        .map((doc) => Announcement.fromJson(doc.data(), doc.id))
        .toList();

    list.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return list;
  }

  Future<List<Announcement>> getAnnouncementsForUser({
    required String role,
    String? filiere,
    String? niveau,
  }) async {
    final snapshot = await _announcementsRef.get();
    final normalizedRole = _normalizeRole(role);

    final list = snapshot.docs
        .map((doc) => Announcement.fromJson(doc.data(), doc.id))
        .where((announcement) {
          if (!announcement.isActive) return false;

          final normalizedTargetRoles =
              announcement.targetRoles.map(_normalizeRole).toList();

          final roleMatch = normalizedTargetRoles.contains('tous') ||
              normalizedTargetRoles.contains(normalizedRole);

          if (!roleMatch) return false;

          if (normalizedRole == 'étudiant') {
            final filiereMatch =
                _matchesValue(announcement.targetFilieres, filiere);
            final niveauMatch =
                _matchesValue(announcement.targetNiveaux, niveau);

            return filiereMatch && niveauMatch;
          }

          return true;
        })
        .toList();

    list.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return list;
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    await _announcementsRef.add(announcement.toJson());
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    await _announcementsRef.doc(announcement.id).update(
          announcement.copyWith(updatedAt: DateTime.now()).toJson(),
        );
  }

  Future<void> deleteAnnouncement(String id) async {
    await _announcementsRef.doc(id).delete();
  }

  Future<void> toggleActiveStatus(String id, bool isActive) async {
    await _announcementsRef.doc(id).update({
      'isActive': isActive,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
