import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/announcement.dart';
import '../services/announcement_service.dart';
import '../services/AR_Notification/notification_service.dart';

class AnnouncementController extends ChangeNotifier {
  final AnnouncementService _service = AnnouncementService();
  final NotificationService _notificationService = NotificationService();

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

      // Création automatique de notifications pour les cibles
      for (var role in announcement.targetRoles) {
        String targetType = '';
        if (role == 'étudiant') {
          targetType = 'student';
        } else if (role == 'enseignant') {
          targetType = 'teacher';
        }

        if (targetType.isNotEmpty) {
          // On crée une notification pour chaque filière/niveau ciblés
          // Si c'est "tous", on passe "tous" au service
          for (var filiere in announcement.targetFilieres) {
            for (var niveau in announcement.targetNiveaux) {
              await _notificationService.createNotification(
                targetType: targetType,
                filiere: filiere,
                niveau: niveau,
                title: "Nouvelle annonce : ${announcement.title}",
                message: announcement.message,
                adminMessage: "Publié par ${announcement.author}",
              );
            }
          }
        }
      }

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