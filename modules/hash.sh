#!/usr/bin/env bash

file_hash() {
  local path=${1:-}
  if [[ -z $path ]]; then printf '%sIndiquez un chemin de fichier.%s\n' "$RED" "$RESET" >&2; return 2; fi
  if [[ ! -f $path || ! -r $path ]]; then printf '%sFichier absent ou illisible : %s%s\n' "$RED" "$path" "$RESET" >&2; return 1; fi
  printf '%s╭─ EMPREINTE SHA-256 ────────────────────────╮%s\n' "$YELLOW" "$RESET"
  if command -v sha256sum >/dev/null 2>&1; then sha256sum -- "$path"
  elif command -v shasum >/dev/null 2>&1; then shasum -a 256 -- "$path"
  elif command -v openssl >/dev/null 2>&1; then openssl dgst -sha256 "$path"
  else printf '%sSHA-256 absent. Termux : pkg install coreutils%s\n' "$RED" "$RESET" >&2; return 1
  fi
}
