#!/usr/bin/env bash
set -euo pipefail

if [[ -z ${PREFIX:-} || ! -x ${PREFIX}/bin ]]; then
  printf 'Erreur : cet installateur doit être lancé dans Termux.\n' >&2
  printf 'Sous Linux, utilisez directement : bash ./lust-dar --help\n' >&2
  exit 1
fi
if ! command -v pkg >/dev/null 2>&1; then
  printf 'Erreur : commande pkg introuvable. Ouvrez Termux depuis une source officielle puis réessayez.\n' >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
INSTALL_DIR="${LUST_DAR_INSTALL_DIR:-${HOME:?HOME non défini}/.local/share/lust-dar}"
BIN_DIR="$PREFIX/bin"
case "$INSTALL_DIR" in
  /|"$HOME"|"$PREFIX"|"$PREFIX"/*)
    printf 'Erreur : chemin d installation refuse : %s\n' "$INSTALL_DIR" >&2
    exit 1
    ;;
esac

printf 'Mise à jour des dépôts Termux…\n'
pkg update -y
printf 'Installation des dépendances…\n'
pkg install -y bash coreutils iproute2 dnsutils procps

mkdir -p "$INSTALL_DIR" "$BIN_DIR"
rm -rf -- "${INSTALL_DIR:?}/config"
for item in lust-dar core modules config assets; do
  if [[ -e "$SCRIPT_DIR/$item" ]]; then
    rm -rf -- "${INSTALL_DIR:?}/$item"
    cp -R -- "$SCRIPT_DIR/$item" "$INSTALL_DIR/$item"
  fi
done
chmod 0755 "$INSTALL_DIR/lust-dar"

# Le wrapper garde un chemin absolu vers l'installation complète, contrairement
# à un simple lien vers un script qui cherche ses modules à côté de lui-même.
printf '#!/usr/bin/env bash\nexec bash %q "$@"\n' "$INSTALL_DIR/lust-dar" > "$BIN_DIR/lust-dar"
chmod 0755 "$BIN_DIR/lust-dar"

printf '\nInstallation terminée. Vérification :\n'
"$BIN_DIR/lust-dar" --version
"$BIN_DIR/lust-dar" doctor
printf '\nLancement : lust-dar\nAide : lust-dar --help\n'
