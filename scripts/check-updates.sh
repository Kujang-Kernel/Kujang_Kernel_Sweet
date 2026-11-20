#!/usr/bin/env bash
# Cek versi komponen Kujang Kernel vs upstream.
# Usage: bash scripts/check-updates.sh [root_repo]
# Bisa di-override: KSU_REPO, SUSFS_REPO, NOMOUNT_REPO

set -uo pipefail

ROOT="${1:-.}"
SUSFS_H="$ROOT/include/linux/susfs.h"
WF_DIR="$ROOT/.github/workflows"

KSU_REPO="${KSU_REPO:-manipvlator/KernelSU}"
SUSFS_REPO="${SUSFS_REPO:-LyraVoid/FinaSU}"
NOMOUNT_REPO="${NOMOUNT_REPO:-maxsteeel/nomount}"

latest_tag() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" 2>/dev/null \
    | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' \
    | head -1
}

echo "🔍 KUJANG UPDATE CHECK"
echo "────────────────────────────────"

# --- SUSFS ---
LOCAL_SUSFS="$(sed -n 's/.*SUSFS_VERSION[[:space:]]*"\([^"]*\)".*/\1/p' "$SUSFS_H" 2>/dev/null | head -1)"
UP_SUSFS="$(curl -fsSL "https://raw.githubusercontent.com/$SUSFS_REPO/master/kernel/Kconfig" 2>/dev/null \
  | grep -oE 'SUSFS v[0-9]+\.[0-9]+\.[0-9]+' | head -1 | awk '{print $2}')"

echo "SUSFS lokal     : ${LOCAL_SUSFS:-tidak ditemukan}"
echo "SUSFS upstream  : ${UP_SUSFS:-tidak bisa dicek} ($SUSFS_REPO)"
if [ -n "$LOCAL_SUSFS" ] && [ -n "$UP_SUSFS" ]; then
  if [ "$LOCAL_SUSFS" = "$UP_SUSFS" ]; then
    echo "Status          : ✅ sudah terbaru"
  else
    echo "Status          : 🟡 beda versi -> perlu tarik patch/source terbaru"
  fi
else
  echo "Status          : ⚪ tidak bisa dibandingkan"
fi

echo

# --- KernelSU driver ---
KSU_REF="$(grep -rhoE "raw\.githubusercontent\.com/[^/]+/KernelSU/refs/heads/[^/]+" "$WF_DIR" 2>/dev/null \
  | sed 's|.*/heads/||' | sort -u | paste -sd, -)"
KSU_TAG="$(latest_tag "$KSU_REPO")"
if [ -z "$KSU_TAG" ]; then
  KSU_TAG="$(curl -fsSL "https://api.github.com/repos/$KSU_REPO/commits/main" 2>/dev/null \
    | sed -n 's/.*"sha":[[:space:]]*"\([^"]*\)".*/\1/p' | head -1 | cut -c1-7)"
  [ -n "$KSU_TAG" ] && KSU_TAG="main@$KSU_TAG"
fi
echo "KSU ref workflow: ${KSU_REF:-tidak ditemukan} ($KSU_REPO)"
echo "KSU terbaru     : ${KSU_TAG:-tidak bisa dicek}"
if [ -n "$KSU_REF" ]; then
  echo "Status          : ℹ️  workflow mengikuti branch '$KSU_REF' (commit terbaru otomatis)"
else
  echo "Status          : ⚪ tidak bisa dicek"
fi

echo

# --- NoMount ---
NM_REF="$(grep -rhoE "raw\.githubusercontent\.com/[^/]+/nomount/refs/heads/[^/]+" "$WF_DIR" 2>/dev/null \
  | sed 's|.*/heads/||' | sort -u | paste -sd, -)"
NM_TAG="$(latest_tag "$NOMOUNT_REPO")"
echo "NoMount ref     : ${NM_REF:-tidak ditemukan} ($NOMOUNT_REPO)"
echo "NoMount rilis   : ${NM_TAG:-tidak bisa dicek}"

echo
echo "────────────────────────────────"
echo "Catatan: script ini hanya MEMBANDINGKAN, tidak mengubah apa pun."
