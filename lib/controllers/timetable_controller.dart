import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/timetable_model.dart';
import '../services/timetable_service.dart';

class TimetableController extends ChangeNotifier {
  final TimetableService _service = TimetableService();

  bool isLoading = false;

  File? selectedFile;
  Uint8List? selectedFileBytes;
  String? selectedFileName;

  String? selectedFiliere;
  String? selectedNiveau;
  UserModel? selectedTeacher;

  final TextEditingController adminMessageController = TextEditingController();

  List<UserModel> teachers = [];

  final List<String> filieres = ['MGSI', 'IL', 'SDBDIA', 'SITCN'];
  final List<String> niveaux = ['1ère année', '2ème année', '3ème année'];

  Stream<List<TimetableModel>> get studentTimetablesStream =>
      _service.getStudentTimetablesAdmin();

  Stream<List<TimetableModel>> get teacherTimetablesStream =>
      _service.getTeacherTimetablesAdmin();

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final pickedFile = result.files.single;

      selectedFileName = pickedFile.name;

      if (kIsWeb) {
        selectedFileBytes = pickedFile.bytes;
        selectedFile = null;
      } else {
        if (pickedFile.path != null) {
          selectedFile = File(pickedFile.path!);
          selectedFileBytes = null;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur pickFile: $e');
    }
  }

  Future<void> loadTeachers() async {
    isLoading = true;
    notifyListeners();

    try {
      teachers = await _service.getTeachers();
    } catch (e) {
      debugPrint('Erreur loadTeachers: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void setFiliere(String? value) {
    selectedFiliere = value;
    notifyListeners();
  }

  void setNiveau(String? value) {
    selectedNiveau = value;
    notifyListeners();
  }

  void setTeacher(UserModel? value) {
    selectedTeacher = value;
    notifyListeners();
  }

  Future<String?> uploadStudentTimetable(String adminUid) async {
    if (selectedFileName == null ||
        selectedFiliere == null ||
        selectedNiveau == null ||
        (!kIsWeb && selectedFile == null) ||
        (kIsWeb && selectedFileBytes == null)) {
      return 'Merci de remplir tous les champs et choisir un fichier';
    }

    isLoading = true;
    notifyListeners();

    try {
      await _service.uploadStudentTimetable(
        file: selectedFile,
        fileBytes: selectedFileBytes,
        fileName: selectedFileName!,
        filiere: selectedFiliere!,
        niveau: selectedNiveau!,
        adminMessage: adminMessageController.text.trim(),
        uploadedBy: adminUid,
      );
      clearForm();
      return null;
    } catch (e) {
      return 'Erreur import étudiant: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadTeacherTimetable(String adminUid) async {
    if (selectedFileName == null ||
        selectedTeacher == null ||
        (!kIsWeb && selectedFile == null) ||
        (kIsWeb && selectedFileBytes == null)) {
      return 'Merci de remplir tous les champs et choisir un fichier';
    }

    isLoading = true;
    notifyListeners();

    try {
      await _service.uploadTeacherTimetable(
        file: selectedFile,
        fileBytes: selectedFileBytes,
        fileName: selectedFileName!,
        teacher: selectedTeacher!,
        adminMessage: adminMessageController.text.trim(),
        uploadedBy: adminUid,
      );
      clearForm();
      return null;
    } catch (e) {
      return 'Erreur import enseignant: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTimetable(TimetableModel timetable) async {
    isLoading = true;
    notifyListeners();
    try {
      await _service.deleteTimetable(timetable);
    } catch (e) {
      debugPrint('Erreur suppression: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  void clearForm() {
    selectedFile = null;
    selectedFileBytes = null;
    selectedFileName = null;
    selectedFiliere = null;
    selectedNiveau = null;
    selectedTeacher = null;
    adminMessageController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    adminMessageController.dispose();
    super.dispose();
  }
}