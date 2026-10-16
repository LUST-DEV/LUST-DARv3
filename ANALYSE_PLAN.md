# Plan professionnel — LUST-DAR

**Dépôt examiné :** [LUST-DEV/LUST-DARv3](https://github.com/LUST-DEV/LUST-DARv3)  
**Branche de référence :** `main` — commit `40ae834`  
**Date :** 2026-10-16

## Recommandation de produit

Faire évoluer le dépôt vers un **terminal de diagnostic et d’audit défensif**, combinant l’inventaire d’informations, des vérifications locales, puis des scans réseau à portée explicite. L’esthétique « terminal hacker » doit rester une présentation visuelle, pas une promesse d’intrusion.

Le principe professionnel est de préférer des résultats vérifiables, limités et reproductibles aux fonctions spectaculaires mais risquées. Les actions à distance doivent être opt-in, sans cible implicite, sans furtivité, sans exploitation et sans modification des systèmes scannés.

## État initial vérifié

Le dépôt contient un menu Bash et cinq petits modules : information système, interfaces/routes réseau, requête DNS, hash SHA-256 et affichage de processus. Il s’agit de fonctions de base; elles ne forment pas un scan de vulnérabilités.

Défauts et manques identifiés :

- `lust-dar` source `core/config.sh`, mais le fichier commité s’appelle `core/Config.sh`. La casse des chemins est significative sur Linux et Termux.
- Les chemins de configuration sont relatifs au répertoire courant, et les shebangs absolus Termux contredisent la compatibilité Linux annoncée.
- Les dépendances et les erreurs d’exécution ne sont pas vérifiées systématiquement.
- L’entrée est interactive; pas de contrat stable de CLI, de codes de sortie ou de format JSON.
- Aucun test automatisé, workflow CI, `SECURITY.md` ou fichier de licence n’a été identifié dans les fichiers suivis.
- Le README précédent annonçait certaines fonctions plus largement que le code ne le justifie.

Le README a été réécrit pour distinguer clairement les fonctions présentes des objectifs futurs. L’image et les liens d’icône/badges ne doivent pas être interprétés comme une certification de sécurité.

## Choix produit recommandés

| Décision | Options réalistes | Recommandation | Motif |
|---|---|---|---|
| Positionnement | Terminal généraliste / suite d’audit défensif / scanner offensif | **Suite d’audit défensif** | Cohérent avec les fonctions actuelles et publiable avec des garde-fous clairs. |
| Plateformes | Termux / Linux / les deux | **Linux d’abord, Termux ensuite** | Réduire les écarts d’utilitaires et de chemins au MVP; ajouter Termux lorsque la CI ou les tests manuels le couvrent. |
| Architecture | Bash seul / Bash + cœur Python / réécriture Go | **Bash comme interface; cœur Python seulement si les rapports et contrôles deviennent complexes** | Corriger d’abord le socle existant. Éviter une réécriture lourde; isoler les fonctions pour pouvoir migrer sans casser l’interface. |
| Scanner réseau | Code maison / wrapper d’un outil existant / pas de scan distant | **Pas de scan de ports dans la première version stable; intégration d’outil reconnue plus tard, optionnelle** | Réduire les risques techniques et la portée avant d’avoir périmètre, tests et documentation. |
| Sorties | Texte / JSON / les deux | **Les deux** | Texte pour l’opérateur; JSON versionné pour automatisation et comparaison. |
| Contrôles initiaux | Vérifications locales / scans distants / mix immédiat | **Local en lecture seule d’abord, puis réseau explicite** | Ordre le plus sûr et le plus testable. |
| Dépendances | Aucune / outils système facultatifs / pile lourde | **Dépendances minimales et facultatives détectées par `doctor`** | Bon fonctionnement sous Linux et Termux, avec explication des fonctions indisponibles. |

Ces recommandations sont le choix de conception proposé pour démarrer. Elles n’impliquent pas que les fonctions listées sont déjà codées.

## Modules fonctionnels visés

### 1. Informations et inventaire

- Identité de l’hôte, système, noyau, architecture, stockage et mémoire.
- Interfaces, adresses locales, routes, DNS configuré et état de connectivité sur demande.
- Processus et services à l’écoute disponibles selon le système.
- Détection de dépendances et capacités avec `doctor`.

L’outil doit distinguer `indisponible`, `non pris en charge`, `échec` et `succès`; une donnée vide ne doit jamais être transformée en constat positif.

### 2. Contrôles locaux défensifs

Ajouter de façon incrémentale et sans privilèges par défaut : permissions de fichiers sensibles, configuration SSH, état du pare-feu, services exposés localement, mises à jour détectables via le gestionnaire de paquets, intégrité de fichiers choisie par l’utilisateur. Ne rien corriger automatiquement. Pour chaque contrôle, indiquer sa méthode, sa portée, ses limites et la preuve minimale utile.

### 3. Vérifications réseau autorisées

Commencer par des contrôles peu intrusifs sur une seule cible déclarée : résolution, test de connectivité explicitement demandé, vérification TLS/certificat pour un service fourni. Un futur contrôle de ports doit être opt-in, borné à des hôtes et ports déclarés, limité par des timeouts et une cadence prudente, et exécuté avec un outil reconnu si cela est nécessaire.

Pas de balayage par défaut d’un réseau entier, pas de découverte furtive, pas de brute force, pas de contournement, pas d’exploitation, pas de collecte de secrets et pas de modification distante. Une mention d’autorisation ne remplace pas les limites techniques de portée.

### 4. Rapports et historique

Format texte lisible et JSON versionné. Chaque constat devrait contenir :

```json
{
  "schema_version": "1.0",
  "check_id": "example.check",
  "status": "pass|finding|unknown|error|skipped",
  "severity": "info|low|medium|high|critical|none",
  "summary": "Résumé factuel",
  "evidence": [],
  "limitations": [],
  "remediation": null,
  "target": null,
  "timestamp": "ISO-8601"
}
```

Les rapports ne doivent pas contenir de secrets ni de données personnelles inutiles. Écrire vers un fichier ne doit pas écraser silencieusement un rapport existant.

## Architecture cible

Conserver l’organisation modulaire sans ajouter prématurément une abstraction compliquée :

```text
lust-dar                 point d’entrée stable, CLI et menu
core/                    configuration validée, diagnostic, rendu, codes de sortie
modules/inventory/       informations système et réseau
modules/local-audit/     contrôles locaux en lecture seule
modules/network-check/   contrôles réseau explicites et limités
reports/                 schémas et exemples de rapports
 tests/                  tests unitaires et intégration locale
.github/workflows/       lint, tests, contrôles de livraison
assets/                  bannière et ressources sous licence compatible
```

Le cœur doit être testable indépendamment de l’interface interactive. Le menu appelle les mêmes fonctions que les sous-commandes CLI. Les valeurs de configuration sont parsées/validées; aucun fichier de réglages utilisateur ne doit être sourcé comme du code shell.

## Feuille de route et portes de validation

### Étape 0 — Fiabilisation immédiate

- Corriger la casse de `Config.sh` et les chemins en les ancrant sur le chemin réel du script.
- Adopter un shebang compatible avec les environnements effectivement supportés.
- Gérer les erreurs de chargement et dépendances avec des messages clairs et des codes non nuls.
- Désactiver l’animation par défaut, notamment hors terminal interactif.
- Ajouter `--help`, `--version` et `doctor` en lecture seule.

**Porte de sortie :** lancement depuis le dépôt et un autre répertoire; chemins avec espaces; configuration absente/invalide; dépendance absente; aucun accès réseau au démarrage.

### Étape 1 — Contrats CLI et qualité

- Définir les sous-commandes et codes de retour; conserver un menu optionnel.
- Centraliser validation des entrées, journalisation, couleurs, détection TTY et gestion d’erreurs.
- Ajouter tests Bash unitaires et intégration avec faux binaires placés sur un `PATH` temporaire.
- Ajouter ShellCheck et tests sur chaque pull request via GitHub Actions.
- Fixer les conventions des rapports et leur schéma JSON.

**Porte de sortie :** les tests sont reproductibles hors réseau; sorties texte/JSON testées; erreurs prévisibles couvertes; aucun secret dans les logs.

### Étape 2 — Audit local MVP

- Ajouter une première sélection de contrôles en lecture seule.
- Indiquer clairement les permissions requises et ce que l’outil ne peut pas vérifier.
- Tester les résultats attendus sur fixtures et environnements contrôlés.
- Ne pas utiliser `sudo` implicitement et ne jamais modifier la machine.

**Porte de sortie :** chaque contrôle a une description, une limite, un test et un résultat JSON structuré; aucun faux « tout est sûr » en cas d’incertitude.

### Étape 3 — Vérifications réseau à faible impact

- Définir un schéma de portée : cible explicite, ports/protocoles ciblés, limites, délai et résolution.
- Commencer par DNS, connectivité demandée et vérification TLS; documenter les requêtes réellement émises.
- Ajouter seulement ensuite une intégration optionnelle de scan de ports, ciblée, limitée et testée sur loopback/lab.
- Inclure la cible et les paramètres effectifs dans les rapports; permettre l’arrêt propre.

**Porte de sortie :** aucune cible par défaut; tests CI uniquement sur loopback et services locaux; limites vérifiées; interruption testée; documentation claire des autorisations requises.

### Étape 4 — Préparation professionnelle de publication

- Ajouter licence choisie par le mainteneur, `SECURITY.md`, guide de contribution et changelog maintenu.
- Vérifier les droits de redistribution des icônes, polices et dépendances; conserver les attributions demandées.
- Ajouter contrôle de dépendances, détection de secrets, revue de changement et artefacts de release vérifiables.
- Documenter installation Linux/Termux réellement testée, exemples, limites, formats, faux positifs et procédure de rapport de vulnérabilité.

**Porte de sortie :** release construite en CI, installation vérifiée depuis un environnement propre, tests verts et documentation alignée sur le code livré.

## Vérification terminale

Les commandes suivantes sont des contrôles de base; elles ne remplacent pas les tests fonctionnels :

```bash
# Vérifier la syntaxe des scripts
find . -type f \( -name '*.sh' -o -name 'lust-dar' \) -print0 |
  xargs -0 -r -n1 bash -n

# Contrôles à rendre obligatoires dans la CI
shellcheck lust-dar core/*.sh modules/*.sh
bats tests/
git diff --check
```

Scénarios d’intégration à automatiser : lancement depuis `/tmp`, espace dans le chemin, TTY et absence de TTY, entrée vide/invalide, configuration et dépendances manquantes, fichier hash manquant, sortie JSON parseable, retour d’erreur cohérent, `Ctrl-C`, et vérifications réseau confinées à loopback/lab. Les tests ne doivent jamais toucher une cible publique.

## Critère « pas le droit à l’erreur »

Zéro erreur absolu n’est pas une garantie réaliste. Pour s’en approcher professionnellement : chaque fonction doit avoir un contrat, les entrées doivent être validées, les cas d’échec doivent être testés, la CI doit bloquer les régressions, les résultats doivent annoncer leurs limites et les changements doivent être relus avant release. Ne jamais afficher une réussite si la vérification n’a pas réellement été faite.

## Licence et marque

GitHub ne détectait pas de licence dans le dépôt analysé. Le mainteneur doit choisir la licence du code avant d’annoncer une réutilisation libre. L’icône [Font Awesome — Shield Halved](https://fontawesome.com/icons/shield-halved) et les badges [Shields.io](https://shields.io/) sont des références vers leurs sites officiels; vérifier les licences et conditions applicables avant d’incorporer des fichiers de tiers dans le dépôt. La bannière actuelle est un asset créé pour le README.

## Décision proposée pour le MVP

**MVP conseillé :** Linux d’abord; Bash conservé comme interface; correction du démarrage; `doctor`; inventaire enrichi; quelques contrôles locaux en lecture seule; texte + JSON; tests Bash, ShellCheck et CI; aucun scan distant dans la première release stable.

Une fois ce socle validé, décider si un scanner de ports optionnel est nécessaire, sur quels environnements et avec quel outil reconnu. Cette séquence associe les informations et la cybersécurité tout en gardant un périmètre professionnel et vérifiable.
