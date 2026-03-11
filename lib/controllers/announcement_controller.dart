import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/announcement.dart';
import '../services/announcement_service.dart';

class AnnouncementController extends ChangeNotifier {
  final AnnouncementService _service = AnnouncementService();

  List<Announcement> announcements = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadAllAnnouncementsAdmin() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      announcements = await _service.getAllAnnouncementsAdmin();
    } catch (e, stackTrace) {
      errorMessage = "Erreur lors du chargement des annonces : $e";
      debugPrint("loadAllAnnouncementsAdmin ERROR: $e");
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAnnouncementsForUser({
    required String role,
    String? filiere,
    String? niveau,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      announcements = await _service.getAnnouncementsForUser(
        role: role,
        filiere: filiere,
        niveau: niveau,
      );
    } catch (e, stackTrace) {
      errorMessage = "Erreur lors du chargement des annonces : $e";
      debugPrint("loadAnnouncementsForUser ERROR: $e");
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAnnouncement(Announcement announcement) async {
    try {
      await _service.addAnnouncement(announcement);
      await loadAllAnnouncementsAdmin();
      return true;
    } catch (e, stackTrace) {
      errorMessage = "Erreur lors de l'ajout : $e";
      debugPrint("addAnnouncement ERROR: $e");
      debugPrintStack(stackTrace: stackTrace);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAnnouncement(Announcement announcement) async {
    try {
      await _service.updateAnnouncement(announcement);
      await loadAllAnnouncementsAdmin();
      return true;
    } catch (e, stackTrace) {
      errorMessage = "Erreur lors de la modification : $e";
      debugPrint("updateAnnouncement ERROR: $e");
      debugPrintStack(stackTrace: stackTrace);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAnnouncement(String id) async {
    try {
      await _service.deleteAnnouncement(id);
      await loadAllAnnouncementsAdmin();
      return true;
    } catch (e, stackTrace) {
      errorMessage = "Erreur lors de la suppression : $e";
      debugPrint("deleteAnnouncement ERROR: $e");
      debugPrintStack(stackTrace: stackTrace);
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleActiveStatus(String id, bool isActive) async {
    try {
      await _service.toggleActiveStatus(id, isActive);
      await loadAllAnnouncementsAdmin();
      return true;
    } catch (e, stackTrace) {
      errorMessage = "Erreur lors du changement de statut : $e";
      debugPrint("toggleActiveStatus ERROR: $e");
      debugPrintStack(stackTrace: stackTrace);
      notifyListeners();
      return false;
    }
  }
}