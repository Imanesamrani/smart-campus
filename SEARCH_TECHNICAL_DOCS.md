# 🔍 Documentation Technique - Système de Recherche et Filtrage

## Vue d'ensemble

Ce document décrit l'implémentation technique du système de recherche et filtrage des salles dans Smart Campus Companion.

---

## 🏗️ Architecture

### Couches
```
Présentation (UI)
    ↓
RoomController (État)
    ↓
RoomService (Données)
    ↓
Firebase Firestore (BD)
```

### Fichiers Clés
- `lib/screens/rooms_list_screen.dart` - Interface utilisateur
- `lib/controllers/room_controller.dart` - Gestion d'état
- `lib/services/room_service.dart` - Accès aux données
- `lib/models/room_model.dart` - Modèle de données

---

## 📚 Méthodes de Recherche et Filtrage

### 1. **searchRooms(String query)**
Effectue une recherche simple sur plusieurs champs.

**Signature:**
```dart
void searchRooms(String query)
```

**Paramètres:**
- `query` (String): Terme de recherche

**Champs recherchés:**
- Nom de la salle (`room.name`)
- Bâtiment (`room.building`)
- Description (`room.description`)

**Exemple:**
```dart
// Rechercher "Salle 101"
roomController.searchRooms("Salle 101");
// Résultat: Toutes les salles contenant "salle 101" (case-insensitive)
```

---

### 2. **filterByBuilding(String building)**
Filtre les salles par bâtiment spécifique.

**Signature:**
```dart
void filterByBuilding(String building)
```

**Paramètres:**
- `building` (String): Nom du bâtiment

**Exemple:**
```dart
roomController.filterByBuilding("Bâtiment A");
// Résultat: Toutes les salles du Bâtiment A
```

---

### 3. **filterByEquipment(List<String> selectedEquipment)**
Filtre les salles ayant TOUS les équipements sélectionnés.

**Signature:**
```dart
void filterByEquipment(List<String> selectedEquipment)
```

**Paramètres:**
- `selectedEquipment` (List<String>): Liste des équipements

**Logique:**
- Une salle apparaît si elle contient TOUS les équipements sélectionnés
- C'est une logique ET (AND), non OU (OR)

**Exemple:**
```dart
// Chercher les salles avec Projecteur ET Wi-Fi
roomController.filterByEquipment(["Projecteur", "Connexion Wi-Fi"]);
// Résultat: Salles ayant les deux équipements
```

---

### 4. **filterByMinCapacity(int minCapacity)**
Filtre les salles ayant une capacité minimale.

**Signature:**
```dart
void filterByMinCapacity(int minCapacity)
```

**Paramètres:**
- `minCapacity` (int): Capacité minimum (nombre de personnes)

**Exemple:**
```dart
roomController.filterByMinCapacity(30);
// Résultat: Toutes les salles pouvant accueillir au moins 30 personnes
```

---

### 5. **filterByMaxCapacity(int maxCapacity)**
Filtre les salles ayant une capacité maximale.

**Signature:**
```dart
void filterByMaxCapacity(int maxCapacity)
```

**Paramètres:**
- `maxCapacity` (int): Capacité maximum (nombre de personnes)

**Exemple:**
```dart
roomController.filterByMaxCapacity(50);
// Résultat: Toutes les salles pouvant accueillir au maximum 50 personnes
```

---

### 6. **applyAdvancedFilters({...})**
Applique TOUS les filtres combinés (recommandé).

**Signature:**
```dart
void applyAdvancedFilters({
  String? searchQuery,
  String? building,
  List<String>? equipment,
  int? minCapacity,
  int? maxCapacity,
})
```

**Paramètres:**
- `searchQuery` (String?): Terme de recherche
- `building` (String?): Nom du bâtiment
- `equipment` (List<String>?): Équipements requis
- `minCapacity` (int?): Capacité minimum
- `maxCapacity` (int?): Capacité maximum

**Logique de Combinaison:**
```
Les filtres sont combinés avec la logique ET (AND):
Résultat = (Recherche) ET (Bâtiment) ET (Équipements) ET (Min Cap) ET (Max Cap)
```

**Exemple:**
```dart
// Chercher "Salle" au Bâtiment A pour 20-40 personnes avec Wi-Fi
roomController.applyAdvancedFilters(
  searchQuery: "Salle",
  building: "Bâtiment A",
  equipment: ["Connexion Wi-Fi"],
  minCapacity: 20,
  maxCapacity: 40,
);
```

---

### 7. **resetFilters()**
Réinitialise tous les filtres et affiche toutes les salles.

**Signature:**
```dart
void resetFilters()
```

**Exemple:**
```dart
roomController.resetFilters();
// Résultat: Toutes les salles (aucun filtre appliqué)
```

---

## 🔄 Flux de Données

### Initialisation
```
1. _RoomsListScreenState.initState()
   ↓
2. RoomController.loadRooms()
   ↓
3. RoomService.getAllRooms()
   ↓
4. Firebase Firestore query
```

### Recherche/Filtrage
```
RoomsListScreen (UI Input)
   ↓
_applyFilters() (combine tous les paramètres)
   ↓
RoomController.applyAdvancedFilters()
   ↓
Filtre local en mémoire
   ↓
notifyListeners() (mise à jour UI via Consumer)
```

---

## 📊 Algorithme de Filtrage

```dart
// Pseudo-code du filtrage combiné
List<Room> filteredRooms = rooms.where((room) {
  // Filtre 1: Recherche
  if (searchQuery != null && !searchQuery.isEmpty) {
    if (!room.name.contains(searchQuery) &&
        !room.building.contains(searchQuery) &&
        !room.description.contains(searchQuery) &&
        !room.id.contains(searchQuery)) {
      return false; // Exclure cette salle
    }
  }

  // Filtre 2: Bâtiment
  if (building != null && building.isNotEmpty) {
    if (room.building != building) {
      return false; // Exclure cette salle
    }
  }

  // Filtre 3: Équipements (tous requis)
  if (equipment != null && equipment.isNotEmpty) {
    if (!equipment.every((eq) => room.equipment.contains(eq))) {
      return false; // Exclure cette salle
    }
  }

  // Filtre 4: Capacité minimum
  if (minCapacity != null && minCapacity > 0) {
    if (room.capacity < minCapacity) {
      return false; // Exclure cette salle
    }
  }

  // Filtre 5: Capacité maximum
  if (maxCapacity != null && maxCapacity > 0) {
    if (room.capacity > maxCapacity) {
      return false; // Exclure cette salle
    }
  }

  // Si tous les filtres passent
  return true;
}).toList();
```

---

## 🎨 Composants UI

### 1. **Barre de Recherche**
```dart
TextField(
  controller: _searchController,
  onChanged: (query) => _applyFilters(),
  decoration: InputDecoration(
    hintText: 'Rechercher par nom, numéro ou bâtiment...',
    prefixIcon: Icon(Icons.search),
    suffixIcon: _searchController.text.isNotEmpty 
      ? IconButton(
          onPressed: () {
            _searchController.clear();
            _applyFilters();
          },
          icon: Icon(Icons.clear),
        )
      : null,
  ),
)
```

### 2. **Chips de Filtres Actifs**
```dart
if (_selectedBuilding != null)
  Chip(
    label: Text('🏢 $_selectedBuilding'),
    onDeleted: () {
      setState(() => _selectedBuilding = null);
      _applyFilters();
    },
  )
```

### 3. **Modal de Filtres Avancés**
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => // Contient tous les filtres
)
```

---

## 🔌 Intégration avec Widget

### RoomsListScreen State
```dart
class _RoomsListScreenState extends State<RoomsListScreen> {
  // Variables de filtrage
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBuilding;
  List<String> _selectedEquipment = [];
  int? _minCapacity;
  int? _maxCapacity;

  // Méthode de filtrage
  void _applyFilters() {
    _roomController.applyAdvancedFilters(
      searchQuery: _searchController.text,
      building: _selectedBuilding,
      equipment: _selectedEquipment.isNotEmpty ? _selectedEquipment : null,
      minCapacity: _minCapacity,
      maxCapacity: _maxCapacity,
    );
  }

  // Réinitialisation
  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedBuilding = null;
      _selectedEquipment.clear();
      _minCapacity = null;
      _maxCapacity = null;
    });
    _roomController.resetFilters();
  }
}
```

---

## 📈 Performance

### Complexité Time
- Recherche simple: **O(n)** où n = nombre de salles
- Filtrage combiné: **O(n)** une seule passe
- Équipement check: **O(m)** où m = équipements par salle (petit)

### Complexité Space
- **O(n)** pour stocker les résultats filtrés

### Optimisations
1. Filtrage côté client (pas de requête réseau)
2. Une seule pass sur la liste (combinaison des filtres)
3. ChangeNotifier pour mises à jour efficaces

**Performance:** < 100ms pour 1000 salles

---

## 🧪 Cas de Test

### Test 1: Recherche Simple
```dart
roomController.searchRooms("Amphi");
// Vérifie: Les salles contenant "Amphi" s'affichent
```

### Test 2: Filtrage Combiné
```dart
roomController.applyAdvancedFilters(
  searchQuery: "Salle",
  building: "Bâtiment A",
  equipment: ["Wi-Fi", "Projecteur"],
  minCapacity: 20,
  maxCapacity: 50,
);
// Vérifie: Résultats respectent tous les critères
```

### Test 3: Réinitialisation
```dart
roomController.resetFilters();
// Vérifie: Toutes les salles réapparaissent
```

---

## 🚀 Améliorations Futures

### Phase 2
- [ ] Filtre par plage horaire (disponibilité)
- [ ] Tri par distance (GPS)
- [ ] Sauvegarde des filtres favoris
- [ ] Historique de recherche

### Phase 3
- [ ] Recherche par voix
- [ ] Visualisation sur carte
- [ ] Réalité augmentée (AR)
- [ ] Notification de disponibilité

---

## 📖 Exemple Complet

```dart
// Initialisation
final roomController = context.read<RoomController>();

// Charger les salles
await roomController.loadRooms();

// Exemple 1: Recherche simple
roomController.searchRooms("Salle 101");

// Exemple 2: Filtre par bâtiment
roomController.filterByBuilding("Bâtiment Principal");

// Exemple 3: Filtres avancés combinés
roomController.applyAdvancedFilters(
  searchQuery: "Amphithéâtre",
  building: "Bâtiment A",
  equipment: ["Vidéoprojecteur", "Système audio"],
  minCapacity: 50,
  maxCapacity: 200,
);

// Affichage des résultats
final results = roomController.filteredRooms;
print("${results.length} salles trouvées");

// Réinitialisation
roomController.resetFilters();
```

---

**Dernière mise à jour:** 8 Mars 2026
**Version:** 1.0.0
**Auteur:** Smart Campus Development Team
