# Plan professionnel — LUST-DAR

**Dépôt :** [LUST-DEV/LUST-DARv3](https://github.com/LUST-DEV/LUST-DARv3)
**Branche de travail :** `main`
**Version de développement :** `5.0.0-dev`

## Direction produit

Faire évoluer LUST-DAR en terminal d’inventaire et d’audit défensif : informations locales, contrôles en lecture seule, puis vérifications réseau autorisées et bornées. Le look néon « hacker » est esthétique. Il ne doit jamais laisser penser que le logiciel exploite une machine ou effectue des scans cachés.

## État actuel après les corrections

Le dépôt répare le démarrage en ancrant les chargements sur l’emplacement du programme, harmonise les noms de configuration, retire le démarrage animé et fournit une CLI ainsi qu’un installateur Termux.

Commandes actuellement implémentées :

- `lust-dar --help` et `lust-dar --version`;
- `lust-dar doctor` pour vérifier les commandes disponibles;
- `lust-dar system` pour le système, le stockage et la mémoire disponible;
- `lust-dar network` pour les interfaces et routes locales (`iproute2` requis pour cette commande);
- `lust-dar dns <nom>` avec validation d’entrée;
- `lust-dar hash <fichier>` avec prise en charge de chemins contenant des espaces;
- `lust-dar processes`;
- `lust-dar scan <hote> <ports>` pour un seul hôte, 1 à 32 ports TCP explicitement listés et un délai de 2 s par port;
- menu interactif néon, couleurs ANSI sur TTY et désactivation par `NO_COLOR`.

L’installateur `install-termux.sh` installe les paquets Termux nécessaires, copie le projet dans `~/.local/share/lust-dar` et crée un lanceur dans `$PREFIX/bin`. Il doit être exécuté dans Termux, à partir d’une copie complète du dépôt.

Le test TCP est limité et ne détecte pas les vulnérabilités. **Pas implémenté à ce stade :** audit de vulnérabilités, balayage de réseaux/plages, export JSON, correctifs automatiques et installation Linux globale. Ne pas présenter les fonctions existantes comme un scanner professionnel.

## Validation réalisée et portée

Les scripts ont passé `bash -n`, ShellCheck 0.9.0 et la suite `tests/test_cli.sh` dans le Sandbox Linux. Les tests couvrent le menu pseudo-terminal, les commandes CLI, le lancement hors du dépôt, les commandes réseau simulées, la validation des entrées, un test TCP sur loopback et l’installateur Termux avec `pkg` factice.

**Limite de validation :** la simulation vérifie la copie, le wrapper et l’interface d’installation, mais elle n’est pas une exécution sur téléphone Android/Termux réel. Avant d’annoncer le support Termux comme certifié, lancer les étapes de la section « Vérification physique Termux » ci-dessous sur une installation Termux propre.

## Choix de conception proposés

| Décision | Recommandation |
|---|---|
| Plateforme du MVP | Bash sur Linux et Termux, validation Termux réelle requise avant release. |
| Architecture | Bash modulaire; éviter toute réécriture tant que les fonctions simples restent maintenables. |
| Interface | Menu interactif et CLI commune; sorties terminal sobres hors TTY; codes d’erreur cohérents. |
| Premières fonctions de sécurité | Contrôles locaux, explicables et en lecture seule. |
| Scan distant | Déjà disponible sous forme de test TCP ciblé; conserver cible/ports explicites, limite stricte et délai par port. |
| Rapport | Texte lisible d’abord; format JSON versionné avant automatisation avancée. |
| Dépendances | Petites, optionnelles quand possible, avec détection et instructions d’installation. |

## Prochaines phases

### P0 — Validation Termux réelle et polish

- Tester l’installation depuis un clone neuf dans Termux, avec les commandes exactes du README.
- Confirmer les noms de paquets (`bash`, `coreutils`, `iproute2`, `dnsutils`, `procps`) dans les dépôts Termux actuels.
- Tester menu TTY, sorties sans TTY, chemins avec espaces, caractères Unicode, réseau mobile/Wi-Fi et les comportements lorsque certaines commandes sont absentes.
- Revoir l’installateur sur réexécution et permissions, puis documenter tout résultat réel.

**Porte de sortie :** installation propre sans édition manuelle du `PATH`, `lust-dar --help` et `doctor` réussis, menu utilisable, aucune erreur de chargement de module.

### P1 — CI et contrats stables

- GitHub Actions exécute syntaxe Bash, ShellCheck et la suite d’intégration à chaque push/PR.
- Enrichir les tests pour le menu interactif, les retours d’erreur, sorties redirigées, variables `NO_COLOR` et absence des dépendances facultatives.
- Définir des codes de retour constants et vérifier le texte des messages d’erreur.
- Ajouter une matrice Linux/Termux ou, au minimum, tests manuels documentés pour Android.

**Porte de sortie :** aucune erreur Bash/ShellCheck, CI verte, installation testée sur les environnements annoncés.

### P2 — Audit local défensif

Ajouter un petit ensemble de contrôles en lecture seule : permissions de fichiers choisis, état du pare-feu, services à l’écoute, configuration SSH locale, mises à jour disponibles selon la distribution. Aucun contrôle ne doit exiger `sudo` automatiquement ni corriger l’hôte.

Chaque résultat devra distinguer `pass`, `finding`, `unknown`, `error` et `skipped`, mentionner la preuve minimale, la sévérité, les limites et une remédiation prudente. Une vérification indisponible ne doit pas être rapportée comme une réussite.

### P3 — Étendre prudemment les vérifications réseau

La version actuelle teste un seul hôte et jusqu’à 32 ports listés explicitement. Les extensions possibles sont la vérification TLS/certificat et des rapports plus complets. Toute extension restera facultative, bornée et documentera les requêtes émises.

Aucun balayage implicite de réseau, furtivité, contournement, brute force, exploitation ou changement distant. Les tests automatisés doivent rester sur loopback ou en laboratoire isolé.

### P4 — Rapports et publication

- Ajouter un format JSON stable/versionné et tests de schéma.
- Éviter secrets, données personnelles inutiles et écrasement silencieux d’un rapport existant.
- Ajouter `SECURITY.md`, guide de contribution, changelog maintenu et fichier de licence choisi par le mainteneur.
- Vérifier les licences et conditions de redistribution des images, icônes et dépendances.
- Créer une release seulement après installation propre et validation de toutes les portes précédentes.

## Vérification physique Termux

Sur un appareil Termux propre :

```bash
pkg update -y
pkg install -y git
git clone https://github.com/LUST-DEV/LUST-DARv3.git
cd LUST-DARv3
bash install-termux.sh
lust-dar --help
lust-dar doctor
lust-dar system
lust-dar network
lust-dar dns example.org
lust-dar hash README.md
lust-dar processes
lust-dar scan 127.0.0.1 <port>
```

Vérifier aussi l’appel par chemin absolu depuis un autre répertoire :

```bash
cd "$HOME"
"$PREFIX/bin/lust-dar" --version
```

Consigner version Android/Termux, sortie de `doctor`, erreurs éventuelles et résultat des commandes. Ne pas intégrer au README de promesse de compatibilité basée uniquement sur une simulation Linux.

## Critère de qualité

Aucun projet ne peut garantir mathématiquement zéro bug. Le niveau professionnel consiste à faire échouer tôt les entrées invalides, montrer les erreurs de manière actionnable, tester les chemins normaux et les cas d’échec, bloquer les régressions en CI et ne jamais présenter une vérification non exécutée comme un résultat positif.
