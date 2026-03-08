# 📚 Système de Gestion des Salles - Smart Campus Companion

## 📋 Vue d'ensemble

Un système complet de gestion des salles du campus a été implémenté avec Firebase Firestore, permettant une gestion centralisée et dynamique de toutes les salles disponibles.

### 🎯 Fonctionnalités principales

#### **Pour les administrateurs:**
- ✅ **Ajouter des salles** - Créer de nouvelles salles avec informations complètes
- ✏️ **Modifier des salles** - Mettre à jour les données des salles existantes
- 🗑️ **Supprimer des salles** - Supprimer les salles obsolètes
- 🔴 **Gérer la disponibilité** - Marquer les salles comme disponibles/indisponibles
- 📊 **Dashboard administratif** - Interface dédiée à la gestion complète

#### **Pour les étudiants et enseignants:**
- 📋 **Consulter la liste des salles** - Voir toutes les salles disponibles
- 🔍 **Rechercher une salle** - Chercher par nom ou bâtiment
- 🏗️ **Filtrer par bâtiment** - Afficher les salles d'un bâtiment spécifique
- 🎛️ **Filtrer par équipement** - Trouver les salles avec équipements spécifiques
- 👁️ **Voir les détails** - Afficher toutes les informations d'une salle
- ⚡ **Synchronisation en temps réel** - Les données se mettent à jour automatiquement

---

## 🏗️ Architecture

### **1. Modèle de données (RoomModel)**

```dart
class RoomModel {
  final String id;              // ID unique Firestore
  final String name;            // Nom de la salle (ex: Amphi 1)
  final String building;        // Bâtiment (ex: Bâtiment A)
  final int floor;              // Étage
  final int capacity;           // Capacité d'accueil
  final List<String> equipment; // Équipements disponibles
  final String description;     // Description additionnelle
  final bool isAvailable;       // Disponibilité
  final DateTime createdAt;     // Date de création
  final DateTime updatedAt;     // Date de dernière modification
}
```

### **2. Service Firestore (RoomService)**

Le service gère toutes les opérations Firestore :
- `createRoom()` - Ajouter une salle
- `getRoomById()` - Récupérer une salle par ID
- `getAllRooms()` - Récupérer toutes les salles
- `updateRoom()` - Modifier une salle
- `deleteRoom()` - Supprimer une salle
- `searchRooms()` - Rechercher des salles
- `getRoomsByBuilding()` - Filtrer par bâtiment
- `toggleRoomAvailability()` - Basculer la disponibilité
- `getRoomsStream()` - Stream en temps réel pour toutes les salles
- `getRoomStream()` - Stream en temps réel pour une salle spécifique

### **3. Contrôleur (RoomController)**

Gère l'état de l'application avec Provider :
- État des salles chargées
- Filtrage et recherche
- Gestion des options (bâtiments, équipements)
- Gestion des erreurs et du chargement

### **4. Écrans UI**

#### **AdminDashboardScreen**
- Affiche toutes les salles sous forme de cartes
- Boutons pour ajouter, modifier, supprimer
- Toggle pour gérer la disponibilité
- Dialogue de confirmation avant suppression

#### **RoomsListScreen**
- Affiche la liste des salles avec recherche en temps réel
- Filtre avancé par bâtiment et équipement
- Barre de recherche
- Navigation vers les détails

#### **RoomDetailsScreen**
- Affiche les détails complets d'une salle
- Information de localisation
- Liste des équipements avec icônes
- Dates de création et modification
- Design moderne avec sections colorées

#### **RoomFormDialog**
- Formulaire pour ajouter/modifier une salle
- Validation des champs obligatoires
- Sélection multiple des équipements
- Toggle pour la disponibilité

---

## 🗄️ Structure Firestore

**Collection: `rooms`**

```
rooms/
├── doc_id_1/
│   ├── name: "Amphi 1"
│   ├── building: "Bâtiment A"
│   ├── floor: 0
│   ├── capacity: 150
│   ├── equipment: ["Projecteur", "Vidéoprojecteur", "Système audio"]
│   ├── description: "Grand amphithéâtre pour les cours magistraux"
│   ├── isAvailable: true
│   ├── createdAt: Timestamp
│   └── updatedAt: Timestamp
├── doc_id_2/
│   └── ...
```

---

## 🚀 Guide d'utilisation

### **Pour les administrateurs:**

1. **Accès au dashboard**
   - Dans l'écran d'accueil, cliquez sur "Admin Dashboard"
   - Vous devez avoir le rôle `admin`

2. **Ajouter une salle**
   - Cliquez sur le bouton FAB (+"
   - Remplissez les informations
   - Sélectionnez les équipements
   - Cliquez "Ajouter"

3. **Modifier une salle**
   - Cliquez sur le bouton ✏️ sur la carte de la salle
   - Modifiez les informations
   - Cliquez "Modifier"

4. **Supprimer une salle**
   - Cliquez sur le bouton 🗑️ sur la carte
   - Confirmez la suppression

5. **Gérer la disponibilité**
   - Utilisez le toggle "Disponible" sur la carte
   - Les changements sont sauvegardés immédiatement

### **Pour les utilisateurs (étudiants/enseignants):**

1. **Consulter la liste des salles**
   - Cliquez sur "Liste des salles" dans l'accueil
   - Voyez toutes les salles avec leurs informations

2. **Rechercher une salle**
   - Utilisez la barre de recherche
   - Écrivez le nom de la salle ou du bâtiment

3. **Filtrer les salles**
   - Cliquez sur l'icône entonnoir
   - Sélectionnez un bâtiment ou des équipements
   - Cliquez "Appliquer les filtres"

4. **Voir les détails**
   - Cliquez sur une salle dans la liste
   - Voyez les informations complètes

---

## 📱 Équipements disponibles

Les équipements par défaut proposés sont :
- Projecteur
- Ordinateur
- Connexion Wi-Fi
- Tableau blanc
- Vidéoprojecteur
- Système audio
- Climatisation
- Tableau noir

Ces équipements peuvent être étendus en modifiant la liste `_availableEquipmentOptions` dans [room_form_dialog.dart](room_form_dialog.dart#L25).

---

## 🔐 Contrôle d'accès

### **Rôles autorisés:**

| Rôle | Accès | Permissions |
|------|-------|------------|
| **admin** | Admin Dashboard + Liste des salles | CRUD complet |
| **enseignant** | Liste des salles | Lecture seule |
| **étudiant** | Liste des salles | Lecture seule |

Le contrôle d'accès est vérifiée dans [AdminDashboardScreen](admin_dashboard_screen.dart#L112) qui affiche un message d'accès refusé pour les non-admins.

---

## 🔄 Synchronisation en temps réel

Les données sont synchronisées automatiquement via les Streams Firestore :
- Quand un administrateur ajoute/modifie/supprime une salle
- Les changements apparaissent immédiatement chez tous les utilisateurs
- Pas besoin de recharger l'application

---

## 📊 État et Provider

Le `RoomController` est fourni via Provider dans [main.dart](main.dart#L26) :

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthController()),
    ChangeNotifierProvider(create: (_) => RoomController()),  // ← Ajouté
  ],
  child: MaterialApp(...)
)
```

Cela permet à tous les écrans d'accéder à l'état des salles.

---

## 🛠️ Dépendances ajoutées

```yaml
intl: ^0.19.0  # Pour le formatage des dates
```

---

## 📝 Fichiers créés/modifiés

### **Fichiers créés:**
- `lib/models/room_model.dart` - Modèle de salle
- `lib/services/room_service.dart` - Service Firestore
- `lib/controllers/room_controller.dart` - Contrôleur d'état
- `lib/screens/admin_dashboard_screen.dart` - Dashboard admin
- `lib/screens/room_form_dialog.dart` - Formulaire de salle
- `lib/screens/rooms_list_screen.dart` - Liste des salles
- `lib/screens/room_details_screen.dart` - Détails de salle

### **Fichiers modifiés:**
- `lib/main.dart` - Ajout du RoomController au Provider
- `lib/screens/home_screen.dart` - Ajout de la navigation
- `pubspec.yaml` - Ajout de la dépendance `intl`

---

## 🐛 Gestion des erreurs

Tous les services incluent la gestion des erreurs :
- Messages d'erreur clairs pour l'utilisateur
- Affichage via SnackBar
- Logging des erreurs

---

## 💡 Améliorations possibles

1. **Réservation de salles** - Permettre aux utilisateurs de réserver les salles
2. **Emploi du temps** - Afficher la disponibilité par heure/jour
3. **Notifications** - Notifier quand une salle devient indisponible
4. **Photos** - Ajouter des photos des salles
5. **Historique** - Tracer les modifications apportées aux salles
6. **Export** - Exporter la liste des salles (PDF, Excel)
7. **Map** - Afficher les salles sur une carte du campus

---

## 📞 Support

Pour toute question ou problème :
1. Vérifiez que Firestore est bien configuré
2. Assurez-vous d'avoir les permissions Firebase appropriées
3. Vérifiez les logs dans la console Flutter

---

**Version:** 1.0.0  
**Dernière mise à jour:** 2026-03-08
