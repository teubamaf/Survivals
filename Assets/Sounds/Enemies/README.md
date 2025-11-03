# Sons des Ennemis

Ce dossier contient les fichiers audio pour les ennemis du jeu.

## Sons de zombies

### zombie_hit.wav ou zombie_hit.ogg
Son joué lorsqu'un zombie frappe le joueur.
- **Suggestion** : Son de coup sourd, grognement, impact charnel
- **Durée recommandée** : 0.2-0.4 secondes
- **Format** : WAV 16-bit ou OGG Vorbis
- **Exemples** : "punch impact", "zombie attack", "flesh hit"

## Où trouver des sons gratuits

- **[Freesound.org](https://freesound.org/)** - Cherchez "zombie attack", "punch impact", "flesh hit"
- **[OpenGameArt.org](https://opengameart.org/)** - Section Sound Effects > Monsters
- **[Zapsplat.com](https://www.zapsplat.com/)** - Catégorie Horror/Zombies

## Sons additionnels recommandés

Vous pouvez aussi ajouter d'autres sons de zombies :

### zombie_death.wav
Son joué quand un zombie meurt.
- Placez dans : `Assets/Sounds/Enemies/zombie_death.wav`
- Ajoutez dans `Enemy.gd` à la fonction `_die()`

### zombie_growl.wav
Grognement du zombie (idle ou poursuite).
- Placez dans : `Assets/Sounds/Enemies/zombie_growl.wav`
- Ajoutez dans `Enemy.gd` à `_update_target()` quand il détecte le joueur

### zombie_walk.wav
Son de pas du zombie.
- Placez dans : `Assets/Sounds/Enemies/zombie_walk.wav`
- Ajoutez dans `Enemy.gd` à `_handle_movement()`

## Configuration actuelle

Le système de son est déjà configuré dans `Enemy.gd` (ligne 166-181).
Le son `zombie_hit.wav` est automatiquement détecté et joué si le fichier existe.
Si le fichier n'existe pas, le jeu fonctionne normalement sans son.

## Paramètres du son d'impact

- **Volume** : -5 dB (ajustable ligne 176)
- **Pitch** : 0.9 à 1.1 (variation aléatoire pour plus de réalisme)
- **Position** : 2D (le son vient de la position du zombie)
