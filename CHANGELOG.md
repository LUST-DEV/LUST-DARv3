# Changelog

## Unreleased — 5.0.0-dev

- Réparé le chargement des modules : les chemins sont résolus depuis le script, pas depuis le répertoire courant.
- Ajouté une CLI non interactive (`--help`, `--version`, `doctor`, `system`, `network`, `dns`, `hash`, `processes`).
- Ajouté un test TCP limité à une cible explicite et à une liste maximale de 32 ports, avec délai par port et avertissement d'autorisation.
- Ajouté un installateur Termux avec dépendances et wrapper dans `$PREFIX/bin`.
- Rendu les modules tolérants aux utilitaires absents ou spécifiques à Linux/Termux.
- Ajouté la validation du nom DNS et la prise en charge des chemins contenant des espaces pour le hash.
- Remplacé l’animation de démarrage par un menu néon non bloquant; respect de `NO_COLOR` et des sorties non-TTY.
- Ajouté les tests d’intégration, ShellCheck et le workflow GitHub Actions.
- Réécrit le README avec installation et commandes testables; mis à jour le plan et supprimé les anciens fichiers de configuration/amorçage inutilisés.
