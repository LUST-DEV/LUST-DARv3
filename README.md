<div align="center">
  <img src="assets/lust-dar-banner.jpg" alt="Bannière LUST-DAR fournie par le mainteneur" width="500">

  <h1>LUST-DAR</h1>
  <p><strong>Terminal néon pour inventaire et diagnostics locaux</strong></p>
  <p>Interface sombre, accents cyan/violet et commandes Bash adaptées à Termux et Linux.</p>

  <a href="https://github.com/LUST-DEV/LUST-DARv3"><img alt="Dépôt GitHub" src="https://img.shields.io/badge/GitHub-LUST--DAR-181717?logo=github&logoColor=white"></a>
  <a href="https://www.gnu.org/software/bash/"><img alt="GNU Bash" src="https://img.shields.io/badge/GNU-Bash-121011?logo=gnubash&logoColor=white"></a>
  <a href="https://termux.dev/"><img alt="Termux" src="https://img.shields.io/badge/Android-Termux-2ea44f?logo=android&logoColor=white"></a>
  <a href="https://fontawesome.com/icons/shield-halved"><img alt="Icône bouclier Font Awesome" src="https://img.shields.io/badge/Icon-Shield%20Halved-528DD7?logo=fontawesome&logoColor=white"></a>
  <br><br>
  <a href="#installation-termux">Installation</a> ·
  <a href="#commandes">Commandes</a> ·
  <a href="#état-actuel">État actuel</a> ·
  <a href="ANALYSE_PLAN.md">Plan professionnel</a>
</div>

> **Important — projet en développement.** L’outil propose des informations système et des diagnostics locaux simples. Il ne réalise pas encore d’audit de vulnérabilités ni de scan de ports. Aucun scan distant n’est lancé par défaut.

## État actuel

Cette version corrige l’échec du lancement initial : les fichiers sont maintenant chargés depuis le répertoire du script et le nom du module de configuration est cohérent. L’interface interactive et les commandes documentées appellent les modules communs. Le menu ne lance plus d’animation d’attente. L’installateur a été testé sous Linux avec un `pkg` simulé; l’exécution sur un appareil Termux réel reste à confirmer.

Fonctions implémentées :

- informations système et stockage, avec lecture mémoire selon les capacités du système;
- interfaces réseau et routes locales, si `iproute2` est installé;
- résolution DNS via `nslookup` ou `getent`;
- hash SHA-256 via `sha256sum`, `shasum` ou OpenSSL;
- liste de processus via `ps`;
- diagnostic `doctor` des dépendances;
- interface à couleurs néon, désactivée automatiquement hors terminal ou avec `NO_COLOR`.

La commande `scan` offre maintenant un **test TCP ciblé** sur un hôte et une liste explicites de 1 à 32 ports. Ce n’est ni un scanner de vulnérabilités ni un scan de plages.

**Pas encore implémenté :** scanner de vulnérabilités, balayage de sous-réseau, export JSON, correctifs automatiques. Les sorties de ce projet ne valent pas certification ni audit professionnel.

## Installation Termux

Installez Termux depuis [F-Droid](https://f-droid.org/packages/com.termux/) ou sa [page officielle](https://termux.dev/). Ouvrez ensuite Termux et exécutez :

```bash
pkg update -y
pkg install -y git

git clone https://github.com/LUST-DEV/LUST-DARv3.git
cd LUST-DARv3
bash install-termux.sh
```

L’installateur vérifie qu’il tourne dans Termux, installe `bash`, `coreutils`, `iproute2`, `dnsutils` et `procps`, copie les modules dans `~/.local/share/lust-dar`, crée la commande `lust-dar` dans `$PREFIX/bin`, puis lance `--version` et `doctor`.

Pour démarrer l’interface :

```bash
lust-dar
```

Si la commande n’est pas trouvée après l’installation, vérifiez le préfixe et le `PATH` Termux :

```bash
printf 'PREFIX=%s\nPATH=%s\n' "$PREFIX" "$PATH"
"$PREFIX/bin/lust-dar" --help
```

L’installateur doit être relancé depuis une copie complète du dépôt. Il remplace les fichiers de l’installation LUST-DAR sous `~/.local/share/lust-dar` et le lanceur `$PREFIX/bin/lust-dar`; il ne modifie pas vos autres fichiers. L’installation de paquets nécessite une connexion Internet et l’accès normal au gestionnaire `pkg`.

## Installation Linux

Prérequis : Bash 4+, `uname`, `df` et `ps`. Les outils réseau et DNS sont facultatifs et détectés par `doctor`.

```bash
git clone https://github.com/LUST-DEV/LUST-DARv3.git
cd LUST-DARv3
bash ./lust-dar --help
bash ./lust-dar doctor
```

L’exécution directe est également possible après `chmod +x lust-dar` :

```bash
./lust-dar
```

## Commandes

```bash
bash ./lust-dar --help
bash ./lust-dar --version
bash ./lust-dar doctor
bash ./lust-dar system
bash ./lust-dar network
bash ./lust-dar dns example.org
bash ./lust-dar hash ./chemin/vers/fichier
bash ./lust-dar processes
bash ./lust-dar scan 127.0.0.1 22,80,443
```

Pour une installation Termux, remplacez `bash ./lust-dar` par `lust-dar`. Sans arguments dans un terminal interactif, l’application ouvre le menu. Sans arguments et sans terminal, elle affiche l’aide et sort avec un code non nul.

Pour désactiver les couleurs :

```bash
NO_COLOR=1 bash ./lust-dar system
```

La commande `scan` tente une connexion TCP par port fourni, avec un délai de 2 secondes par port. Elle accepte un seul hôte explicite et au maximum 32 ports séparés par des virgules; elle ne balaye ni plage d’hôtes ni plage de ports. Les ports non accessibles peuvent être fermés, filtrés ou simplement trop lents : le programme ne peut pas distinguer ces cas.

## Interface néon

L’interface utilise des séquences ANSI 256 couleurs lorsqu’elle détecte un terminal interactif. Les sorties redirigées restent sans code couleur; `NO_COLOR=1` permet aussi une sortie sobre. Le style est « glass-inspired » par sa palette sombre/cyan, mais le terminal n’offre pas de transparence graphique réelle.

## Dépannage Termux

- **`pkg: command not found`** : l’installateur n’a pas été lancé dans Termux. Ne lancez pas `install-termux.sh` sous Linux.
- **`lust-dar: command not found`** : utilisez `"$PREFIX/bin/lust-dar" --help` et vérifiez que `$PREFIX/bin` figure dans `PATH`.
- **`ip: commande introuvable`** : `pkg install iproute2`.
- **Pas de `nslookup`** : `pkg install dnsutils`.
- **Pas de `ps` ou de `sha256sum`** : `pkg install procps coreutils`.
- **Commande `timeout` absente pour `scan`** : `pkg install coreutils`.
- **Menu peu lisible** : utilisez un terminal compatible ANSI 256 couleurs; pour supprimer les couleurs, définissez `NO_COLOR=1`.

## Sécurité et périmètre

N’effectuez des vérifications que sur des systèmes dont vous êtes propriétaire ou pour lesquels vous avez une autorisation. `scan` est une fonction distante limitée : cible et ports sont obligatoires et le nombre de ports est plafonné à 32. Elle ne réalise aucun exploit. Les futurs contrôles devront également exiger une portée explicite et des limites raisonnables.

## Vérifications pour les contributeurs

```bash
find . -type f \( -name '*.sh' -o -name 'lust-dar' -o -name 'install-termux.sh' \) -print0 |
  xargs -0 -r -n1 bash -n
```

Les tests d’intégration sont dans `tests/test_cli.sh`; la CI GitHub Actions exécute la syntaxe Bash, ShellCheck et ces tests. L’installateur Termux est simulé dans la suite; il reste à le valider sur un appareil Android. Les futurs tests réseau devront être confinés à loopback/lab.

## Icônes officielles et ressources

- [Dépôt GitHub officiel](https://github.com/LUST-DEV/LUST-DARv3) — badge GitHub avec logo officiel fourni par Shields.io.
- [GNU Bash](https://www.gnu.org/software/bash/) — badge Bash.
- [Termux](https://termux.dev/) et [F-Droid](https://f-droid.org/packages/com.termux/) — téléchargement et documentation Termux.
- [Font Awesome — Shield Halved](https://fontawesome.com/icons/shield-halved) — fiche officielle de l’icône bouclier; vérifier ses conditions avant toute redistribution du fichier d’icône.
- [Shields.io](https://shields.io/) — service des badges affichés dans ce README.

La bannière a été fournie par le mainteneur. Les droits de réutilisation doivent être vérifiés avant redistribution.

## Licence

Aucun fichier `LICENSE` n’est présent à ce jour. En l’absence de licence, ne présumez pas que le code peut être réutilisé ou redistribué librement. Le mainteneur doit choisir et ajouter une licence.
