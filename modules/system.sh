#!/usr/bin/env bash

system_info() {
  printf '%s╭─ INFORMATIONS SYSTÈME ─────────────────────╮%s\n' "$GREEN" "$RESET"
  printf '%s Système :%s ' "$AQUA" "$RESET"; uname -s 2>/dev/null || printf 'indisponible\n'
  printf '%s Noyau   :%s ' "$AQUA" "$RESET"; uname -r 2>/dev/null || printf 'indisponible\n'
  printf '%s Machine :%s ' "$AQUA" "$RESET"; uname -m 2>/dev/null || printf 'indisponible\n'
  printf '%s Shell   :%s Bash %s\n' "$AQUA" "$RESET" "${BASH_VERSION:-inconnu}"
  if command -v df >/dev/null 2>&1; then
    printf '\n%sStockage%s\n' "$CYAN" "$RESET"
    df -h "${HOME:-/}" 2>/dev/null || df -h 2>/dev/null || printf 'Informations de stockage indisponibles.\n'
  else
    printf '\n%sCommande df absente; installez coreutils.%s\n' "$YELLOW" "$RESET"
  fi
  if command -v free >/dev/null 2>&1; then
    printf '\n%sMémoire%s\n' "$CYAN" "$RESET"; free -h 2>/dev/null || true
  elif [[ -r /proc/meminfo ]]; then
    printf '\n%sMémoire (/proc/meminfo)%s\n' "$CYAN" "$RESET"; sed -n '1,5p' /proc/meminfo
  else
    printf '\n%sDétail mémoire indisponible sur cet environnement.%s\n' "$YELLOW" "$RESET"
  fi
}

doctor() {
  local failures=0 cmd
  printf '%s╭─ DIAGNOSTIC DES PRÉREQUIS ─────────────────╮%s\n' "$CYAN" "$RESET"
  printf '  %sOK%s Bash %s\n' "$GREEN" "$RESET" "${BASH_VERSION:-inconnu}"
  for cmd in uname df ps; do
    if command -v "$cmd" >/dev/null 2>&1; then printf '  %sOK%s %s\n' "$GREEN" "$RESET" "$cmd"; else printf '  %sMANQUANT%s %s\n' "$RED" "$RESET" "$cmd"; failures=$((failures+1)); fi
  done
  for cmd in ip nslookup getent sha256sum shasum free timeout; do
    if command -v "$cmd" >/dev/null 2>&1; then printf '  %sDISPONIBLE%s %s\n' "$GREEN" "$RESET" "$cmd"; else printf '  %sOPTIONNEL%s %s\n' "$YELLOW" "$RESET" "$cmd"; fi
  done
  if [[ -n ${PREFIX:-} ]]; then printf '  Environnement : Termux (%s)\n' "$PREFIX"; else printf '  Environnement : Linux/Unix (Termux non détecté)\n'; fi
  printf '\nCe diagnostic ne lance aucun scan distant.\n'
  if (( failures )); then printf '%sDiagnostic incomplet : %d commande(s) requise(s) absente(s).%s\n' "$RED" "$failures" "$RESET"; return 1; fi
  printf '%sPrérequis essentiels présents.%s\n' "$GREEN" "$RESET"
}
