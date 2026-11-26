# NGoma — Linux (Qt 6 / QML + TModeler C++)

Projet de départ Foundation. Module QML / package : `ai.tambo.foundation.ngoma`. Charte rouge (`#E0262D`, `qml/Theme.qml`).

## Prérequis
Qt 6.8+ (Core, Quick, QuickControls2), CMake 3.16+, un compilateur C++20, git (FetchContent).
Au lancement, Qt 6.5+ demande `libxcb-cursor0` (Ubuntu/WSL : `sudo apt install libxcb-cursor0`).

## Construire et lancer
```
cmake -S . -B build -DCMAKE_PREFIX_PATH=<chemin Qt>
cmake --build build
./build/appNGoma
```
TModeler C++ est récupéré par FetchContent (`https://github.com/TTT-GH/TModeler.git`, branche `main`, sous-dossier `cpp`), comme dans `cpp/tests/qtcreator`.

## Écrans (de quoi réaliser le Module 1 SI)
Barre d'onglets à gauche : **Messages**, **Vidéos**, **Personnes**, **Profil**.
1. **Gestion des utilisateurs** : inscription / connexion, **Personnes** (liste, recherche, profil d'une personne, écrire un message), **Profil** (modifier son nom et sa description, voir ses vidéos, se déconnecter, supprimer son compte).
2. **Conversations et messages** : liste des conversations (recherche, filtres, épingler, sourdine, archiver), conversation (envoi, réponse, modification, suppression, réactions).
3. **Publications vidéo et interactions**, façon TikTok : **Vidéos** (fil à défilement vertical page par page), publier (photo ou vidéo, facultatives, + légende ; une légende seule est acceptée), modifier la légende, supprimer, j'aime, commentaires et réponses (aimer, modifier, supprimer les siens), publications des autres, onglet « Mes vidéos ». La lecture de la vidéo n'est pas incluse : à ajouter avec Qt Multimedia (`MediaPlayer` / `VideoOutput`) sur `mediaPath`.

## Mocks (niveau ui-bridge-TModeler)
`qml/MockBridge.qml` : singleton QML (compte + messagerie, tout identifiant est accepté). Toute l'UI passe par lui.
Pour passer à TModeler : fournir un pont avec les mêmes propriétés et fonctions, adossé aux `TViewModel`.

Les écrans ne changent pas : votre travail est de **concevoir vos modèles TModeler** (utilisateur, conversation, message, publication, commentaire, j'aime) puis de fournir un pont (mêmes propriétés et fonctions que `MockBridge.qml`) adossé à ces modèles. Les photos et vidéos choisies dans l'interface sont des fichiers : à enregistrer comme médias TModeler.

## TModeler
- Init et modèle d'exemple : `src/models.h` / `src/models.cpp` (`Note`, `initTModeler()`).
- ViewModel QML d'exemple : `src/viewmodels.hpp` (`NoteViewModel`, enregistré dans `main.cpp` : `import models 1.0`).
- `NGOMA_DB_VERSION` : l'incrémenter repart d'une base vide.
