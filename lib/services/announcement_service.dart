import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _announcementsRef =>
      _firestore.collection('announcements');

  Future<List<Announcement>> getAllAnnouncementsAdmin() async {
    final snapshot = await _announcementsRef.get();

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

    final list = snapshot.docs
        .map((doc) => Announcement.fromJson(doc.data(), doc.id))
        .where((announcement) {
          if (!announcement.isActive) return false;

          final roleMatch = announcement.targetRoles.contains('tous') ||
              announcement.targetRoles.contains(role);

          if (!roleMatch) return false;

          if (role == 'étudiant') {
            final filiereMatch =
                announcement.targetFilieres.contains('tous') ||
                    (filiere != null &&
                        announcement.targetFilieres.contains(filiere));

            final niveauMatch = announcement.targetNiveaux.contains('tous') ||
                (niveau != null &&
                    announcement.targetNiveaux.contains(niveau));

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