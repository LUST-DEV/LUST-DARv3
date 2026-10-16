<div align="center">

![Bannière LUST-DAR](assets/lust-dar-banner.jpg)

# LUST-DAR

### Terminal d’inventaire, de diagnostic et d’audit défensif

**Une base claire pour réunir l’information système, les contrôles locaux et les vérifications réseau autorisées.**

[![Shell](https://img.shields.io/badge/Shell-Bash-121011?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Plateformes](https://img.shields.io/badge/Plateformes-Linux%20%7C%20Termux-2ea44f)](#plateformes)
[![Statut](https://img.shields.io/badge/Statut-prototype%20en%20évolution-orange)](#état-du-projet)
[![Licence](https://img.shields.io/badge/Licence-à%20définir-lightgrey)](#licence)

[Vue d’ensemble](#vue-densemble) · [Fonctions](#fonctions) · [Installation](#installation) · [Sécurité](#sécurité-et-usage-autorisé) · [Feuille de route](ANALYSE_PLAN.md)

</div>

> **État actuel : prototype.** Le dépôt contient des fonctions de base et nécessite une remise à niveau avant de pouvoir être considéré comme un outil professionnel. Les scans réseau décrits dans la feuille de route ne sont pas encore implémentés. N’utilisez pas ce projet comme preuve d’un audit de sécurité terminé.

## Vue d’ensemble

LUST-DAR est un projet de terminal modulaire pour rassembler des informations utiles à l’administration et à l’audit défensif. L’objectif produit est de combiner, dans une interface terminal lisible, l’inventaire local, les diagnostics système et réseau, les contrôles de sécurité à faible impact, puis des vérifications réseau explicitement autorisées.

Le style « terminal hacker » désigne ici une interface sombre et technique. Il ne signifie ni accès non autorisé, ni exploitation, ni contournement. Le produit visé est un outil de diagnostic transparent, contrôlable et documenté.

## Fonctions présentes dans le dépôt

Les scripts actuels comprennent les fonctions suivantes, sous réserve des problèmes de démarrage décrits ci-dessous :

- affichage d’informations système;
- affichage des interfaces et routes réseau;
- résolution DNS simple;
- calcul d’empreinte SHA-256 d’un fichier;
- affichage des processus actifs;
- menu terminal modulaire.

**Ces fonctions ne constituent pas un scanner de vulnérabilités.** La version du dépôt examinée a notamment une incohérence de casse entre `core/config.sh` et le fichier réellement présent `core/Config.sh`. La configuration et les chemins doivent aussi être rendus indépendants du répertoire courant. Consultez [ANALYSE_PLAN.md](ANALYSE_PLAN.md) avant de vous fier à un lancement ou à un résultat.

## Fonctions envisagées

La feuille de route propose de développer progressivement :

1. **Inventaire et diagnostic** — système, interfaces, routes, DNS, processus et dépendances, en distinguant clairement les données indisponibles.
2. **Audit local en lecture seule** — contrôles explicables sur les permissions, services, pare-feu et configuration locale, sans appliquer de changements automatiquement.
3. **Vérifications réseau autorisées** — cible et périmètre fournis explicitement, contrôles prudents, délais et limites définis, aucun scan implicite.
4. **Rapports reproductibles** — sorties texte et JSON versionnées avec horodatage, sévérité, preuve minimale, limites et recommandations.
5. **Mode automatisable** — interface en sous-commandes, codes de sortie stables, tests et intégration continue.

Ces éléments sont des **objectifs**, pas des fonctions déjà disponibles.

## Installation

Dépôt officiel : [github.com/LUST-DEV/LUST-DARv3](https://github.com/LUST-DEV/LUST-DARv3)

```bash
git clone https://github.com/LUST-DEV/LUST-DARv3.git
cd LUST-DARv3
chmod +x lust-dar
```

Le code est en cours de stabilisation. Tant que les tests de lancement et les dépendances ne sont pas documentés et validés, considérez l’exécution comme expérimentale. N’exécutez pas de fonctions sur une cible distante sans avoir vérifié le périmètre et obtenu l’autorisation requise.

### Dépendances annoncées

Le README historique annonce Bash, `iproute2`, `dnsutils` et `curl`. La liste doit être réconciliée avec les appels réels et le contrôle des dépendances n’est pas encore systématique. Les contrôles de hash et de processus peuvent aussi dépendre des utilitaires présents dans le système.

Sur Termux, les paquets de base annoncés sont installables avec :

```bash
pkg install bash iproute2 dnsutils curl
```

## Interface visée

La feuille de route recommande de conserver le menu et d’ajouter une CLI non interactive utilisant les mêmes fonctions. Exemple d’interface **proposée**, non encore garantie comme disponible :

```text
lust-dar --help
lust-dar doctor
lust-dar system info --format text
lust-dar network info --format json
lust-dar dns check example.org
lust-dar file hash ./fichier
lust-dar audit local --format json
lust-dar audit target <cible-explicite> --scope <portée-déclarée>
```

Les sous-commandes `doctor` et `audit` ne doivent être considérées comme disponibles qu’après leur implémentation et validation dans le dépôt.

## Sécurité et usage autorisé

- N’effectuez des vérifications réseau que sur des systèmes que vous possédez ou pour lesquels vous avez une autorisation explicite.
- Toute future commande distante devra exiger une cible et un périmètre explicites; aucune cible ne sera scannée par défaut.
- Les valeurs saisies doivent être validées, les commandes shell correctement citées et les erreurs remontées sans exécuter de configuration arbitraire.
- Les contrôles proposés sont défensifs et à faible impact. Le projet ne vise pas la furtivité, le contournement, l’exploitation de vulnérabilités ou la modification distante de systèmes.
- Les rapports devront indiquer leurs limites et distinguer un fait observé d’une hypothèse.

## Qualité et objectif de fiabilité

Aucun logiciel ne peut promettre « zéro erreur ». L’objectif professionnel est de rendre les erreurs détectables, compréhensibles et bloquantes avant diffusion : syntaxe vérifiée, analyse statique, tests automatisés, tests de lancement hors du dossier du dépôt, tests de dépendances manquantes et tests réseau confinés à des environnements locaux. La CI et ces critères d’acceptation sont détaillés dans [le plan professionnel](ANALYSE_PLAN.md).

Pour les contributeurs, les premières vérifications prévues sont :

```bash
# Vérifier la syntaxe Bash
find . -type f \( -name '*.sh' -o -name 'lust-dar' \) -print0 |
  xargs -0 -r -n1 bash -n

# À activer après l’ajout des outils de test
shellcheck lust-dar core/*.sh modules/*.sh
bats tests/
```

## Plateformes

Le projet annonce Linux et Termux. Cette compatibilité doit encore être réellement vérifiée, en particulier les chemins d’exécutables et les différences entre utilitaires GNU et Android/Termux. Les versions prises en charge seront précisées une fois la matrice de tests en place.

## Icône et badges

- Icône bouclier officielle : [Font Awesome — Shield Halved](https://fontawesome.com/icons/shield-halved). Consultez la licence de l’icône avant de l’intégrer ou de la redistribuer comme fichier du projet.
- Badges de README : [Shields.io](https://shields.io/). Les badges ci-dessus indiquent la technologie et le statut du projet; ils ne prétendent pas que les tests ou audits sont déjà passés.
- Image du README : fichier fourni par le mainteneur et conservé dans [`assets/lust-dar-banner.jpg`](assets/lust-dar-banner.jpg). Vérifiez les droits de réutilisation avant redistribution.

## Contribution

Les contributions sont bienvenues une fois les règles de contribution et la CI ajoutées. Pour une proposition, veuillez inclure le problème résolu, les plateformes concernées, les tests exécutés et tout effet sur la portée ou les dépendances. Les fonctions réseau doivent préciser le périmètre requis, le niveau d’impact et les comportements de sécurité par défaut.

## Licence

Aucun fichier de licence n’a été détecté dans le dépôt lors de l’analyse. **Le code n’est pas à considérer comme librement réutilisable tant que le mainteneur n’a pas choisi et ajouté une licence.**

## Références

- [Dépôt GitHub officiel](https://github.com/LUST-DEV/LUST-DARv3)
- [Documentation GNU Bash](https://www.gnu.org/software/bash/manual/)
- [Shields.io](https://shields.io/)
- [Icône Font Awesome — Shield Halved](https://fontawesome.com/icons/shield-halved)
