import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/building.dart';

class BuildingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Building>> getAllBuildings() async {
    final snapshot = await _firestore.collection('buildings').get();

    return snapshot.docs.map((doc) {
      return Building.fromMap(doc.data(), doc.id);
    }).toList();
  }
}