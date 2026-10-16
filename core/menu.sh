#!/usr/bin/env bash

pause_menu() {
  if [[ -t 0 ]]; then printf '\n%s' "${DIM}Entrée pour revenir au menu…${RESET}"; IFS= read -r _ || true; fi
}

menu() {
  local choice
  while true; do
    if [[ -t 1 ]]; then clear 2>/dev/null || true; fi
    printf '%s╭──────────────────────────────────────────╮%s\n' "$CYAN" "$RESET"
    printf '%s│%s  %sL U S T  -  D A R%s  %s[%s]%s\n' "$CYAN" "$RESET" "$BOLD$AQUA" "$RESET" "$APP_VERSION" "$CYAN" "$RESET"
    printf '%s│%s  %sDEFENSIVE SECURITY TERMINAL%s             %s│%s\n' "$CYAN" "$RESET" "$DIM" "$RESET" "$CYAN" "$RESET"
    printf '%s╰──────────────────────────────────────────╯%s\n\n' "$CYAN" "$RESET"
    printf '  %s[01]%s  Informations système\n' "$GREEN" "$RESET"
    printf '  %s[02]%s  Réseau local et routes\n' "$AQUA" "$RESET"
    printf '  %s[03]%s  Résolution DNS\n' "$BLUE" "$RESET"
    printf '  %s[04]%s  Empreinte SHA-256\n' "$PURPLE" "$RESET"
    printf '  %s[05]%s  Processus\n' "$YELLOW" "$RESET"
    printf '  %s[06]%s  Diagnostic des dépendances\n' "$CYAN" "$RESET"
    printf '  %s[07]%s  Verification TCP ciblee (ports explicites)\n' "$RED" "$RESET"
    printf '  %s[00]%s  Quitter\n\n' "$RED" "$RESET"
    printf '%s┌─[%s%s%s@termux%s]─[%s%s%s]\n└──╼ %s%s' "$DIM" "$GREEN" "$APP_NAME" "$RESET" "$DIM" "$CYAN" "$PWD" "$DIM" "$AQUA" "$RESET"
    IFS= read -r choice || return 0
    case "$choice" in
      1|01) system_info; pause_menu ;;
      2|02) network_info; pause_menu ;;
      3|03) local name; printf 'Domaine : '; IFS= read -r name || continue; dns_lookup "$name"; pause_menu ;;
      4|04) local path; printf 'Chemin du fichier : '; IFS= read -r path || continue; file_hash "$path"; pause_menu ;;
      5|05) process_view; pause_menu ;;
      6|06) doctor; pause_menu ;;
      7|07) local host ports; printf 'Hote autorise : '; IFS= read -r host || continue; printf 'Ports exacts (ex. 22,80,443) : '; IFS= read -r ports || continue; scan_target "$host" "$ports"; pause_menu ;;
      0|00|q|Q) printf '%sSession terminée.%s\n' "$CYAN" "$RESET"; return 0 ;;
      *) printf '%sChoix invalide.%s\n' "$RED" "$RESET"; sleep 1 ;;
    esac
  done
}
