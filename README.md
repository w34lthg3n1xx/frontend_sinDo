# Application d'Analyse Juridique (MVP)

Cette application est un prototype fonctionnel (MVP) d'un client mobile Flutter pour un service d'analyse juridique. Elle permet aux utilisateurs de soumettre des informations via texte, fichier (PDF/image), ou URL de vidéo pour obtenir une analyse structurée d'un backend.

L'application est conçue pour garantir la confidentialité en ne stockant **aucune donnée localement** et en effaçant automatiquement les informations après une période d'inactivité.

## ✨ Fonctionnalités Principales

-   **Interface Unique et Épurée** : Toutes les fonctionnalités sont accessibles depuis un seul écran.
-   **Soumissions Multi-formats** :
    -   Saisie de texte libre (jusqu'à 3000 caractères).
    -   Upload de fichiers (PDF et images - JPG, PNG) avec une limite de 5 Mo.
    -   Soumission d'URL de vidéo.
-   **Analyse Backend** : Envoi des données à un endpoint sécurisé pour traitement.
-   **Affichage Structuré** : La réponse du backend est présentée de manière claire et organisée.
-   **Confidentialité Intégrée** :
    -   **Aucun stockage local** : N'utilise ni `SharedPreferences`, ni base de données locale.
    -   **Auto-Effacement** : Toutes les données (entrées et réponses) sont effacées après 10 minutes d'inactivité.
    -   **Effacement Manuel** : Un bouton permet de réinitialiser l'application à tout moment.
-   **Gestion des Erreurs** : Affiche des messages clairs en cas de problème (validation, réseau, serveur).
-   **Indicateur de Chargement** : Un indicateur visuel informe l'utilisateur qu'une requête est en cours.

## 🏗️ Architecture du Projet

Le projet suit une architecture simple et claire pour séparer les responsabilités. Tous les fichiers de code source se trouvent dans le dossier `lib/`.

```
lib/
 ├── main.dart             # Point d'entrée de l'application
 ├── models/
 │   └── api_response.dart # Modèle de données pour la réponse de l'API
 ├── screens/
 │   └── chat_screen.dart  # Écran principal de l'interface utilisateur (UI)
 ├── services/
 │   └── api_service.dart  # Logique de communication avec le backend
 └── utils/
     └── validators.dart   # Fonctions de validation des entrées utilisateur
```

-   **`main.dart`**: Initialise l'application et définit le thème Material 3.
-   **`screens/chat_screen.dart`**: `StatefulWidget` qui gère l'état de l'interface, les contrôleurs de texte, et la logique d'affichage.
-   **`services/api_service.dart`**: Contient la classe `ApiService` responsable de la construction et de l'envoi de la requête `http.MultipartRequest` au backend. Elle gère également les erreurs HTTP.
-   **`models/api_response.dart`**: Définit la classe `ApiResponse` pour parser la réponse JSON du serveur de manière typée.
-   **`utils/validators.dart`**: Fournit des méthodes statiques pour valider la taille du texte, la taille et le type MIME des fichiers.

## 🚀 Démarrage Rapide

### Prérequis

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) installé sur votre machine.
-   Un émulateur ou un appareil physique pour exécuter l'application.
-   Un endpoint backend fonctionnel prêt à recevoir les requêtes.

### Étapes d'Installation

1.  **Cloner le projet** (si applicable) ou utiliser les fichiers générés.

2.  **Installer les dépendances** :
    Ouvrez un terminal à la racine du projet et exécutez :
    ```sh
    flutter pub get
    ```

3.  **Configurer le Backend** :
    ‼️ **Action requise** : Ouvrez le fichier `lib/services/api_service.dart` et remplacez l'URL de placeholder par l'URL de votre backend.
    ```dart
    // lib/services/api_service.dart
    static const String _baseUrl = 'https://VOTRE_BACKEND_URL/analyze';
    ```

4.  **Lancer l'application** :
    ```sh
    flutter run
    ```

## ⚙️ Dépendances

-   `http`: Pour effectuer les requêtes HTTP vers le backend.
-   `file_picker`: Pour permettre à l'utilisateur de sélectionner des fichiers locaux (PDF, images).
-   `mime`: Pour vérifier le type MIME des fichiers uploadés.
-   `path`: Utilisé pour extraire le nom du fichier depuis son chemin.

## 🌐 Communication avec le Backend

-   **Endpoint** : `POST /analyze`
-   **Type de Requête** : `multipart/form-data`
-   **Champs possibles** :
    -   `text`: `String` (optionnel)
    -   `file`: Fichier (optionnel)
    -   `video_url`: `String` (optionnel)
-   **Réponse Attendue (JSON)** : L'application s'attend à recevoir un objet JSON avec la structure suivante, qui est ensuite parsé dans le modèle `ApiResponse`.
    ```json
    {
      "qualification": "Description de la qualification juridique...",
      "articles": "Articles de loi pertinents...",
      "risques": "Analyse des risques potentiels...",
      "conseils": "Conseils et prochaines étapes..."
    }
    ```

Ce `README.md` fournit une vue d'ensemble complète pour comprendre, utiliser et potentiellement étendre l'application.
