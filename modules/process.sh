#!/usr/bin/env bash

process_view() {
  if ! command -v ps >/dev/null 2>&1; then printf '%sCommande ps absente. Termux : pkg install procps%s\n' "$RED" "$RESET" >&2; return 1; fi
  printf '%s╭─ PROCESSUS VISIBLES ───────────────────────╮%s\n' "$PURPLE" "$RESET"
  if ps -A 2>/dev/null; then return 0; fi
  ps aux 2>/dev/null || { printf '%sImpossible de lire les processus.%s\n' "$RED" "$RESET" >&2; return 1; }
}
