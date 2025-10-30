# Sons du jeu

Ce dossier contient les fichiers audio pour le jeu de survie.

## Sons de construction

Pour activer les sons de construction, ajoutez les fichiers suivants dans ce dossier :

### build_place.wav ou build_place.ogg
Son joué lorsqu'un mur est placé avec succès.
- Suggestion : Son de marteau sur bois, "clac" sec
- Durée recommandée : 0.3-0.5 secondes
- Format : WAV 16-bit ou OGG Vorbis

### build_error.wav ou build_error.ogg
Son joué lorsque le placement échoue (trop loin, collision, etc.)
- Suggestion : Bip d'erreur, son "négatif"
- Durée recommandée : 0.2-0.4 secondes
- Format : WAV 16-bit ou OGG Vorbis

## Sites pour trouver des sons gratuits

- [Freesound.org](https://freesound.org/) - Sons gratuits sous licence Creative Commons
- [OpenGameArt.org](https://opengameart.org/) - Assets audio pour jeux
- [Zapsplat.com](https://www.zapsplat.com/) - Bibliothèque de sons gratuits

## Notes techniques

Le système audio est déjà configuré dans `BuildingPlacer.gd` (lignes 272-300).
Les sons sont automatiquement détectés et joués s'ils existent.
Si les fichiers n'existent pas, le jeu fonctionne normalement sans son.
