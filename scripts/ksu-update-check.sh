#!/usr/bin/env bash
# Cek versi driver KSU vendored vs upstream manipvlator/KernelSU.
# Aman: read-only, tidak mengubah apa pun.
set -u
OWNER=Kujang-Kernel
REPO=Kujang_Kernel_Sweet
UP=manipvlator/KernelSU
BR=Kujang-KSU-Update

echo "=== KUJANG KSU DRIVER CHECK ==="
echo "-- lokal ($OWNER/$REPO @ $BR) --"
gh api "repos/$OWNER/$REPO/contents/drivers/kernelsu/Makefile?ref=$BR" --jq .content \
  | base64 -d | grep -E '^KSU_VERSION[[:space:]]*:?=|^KSU_VERSION_TAG' | head -3

echo "-- upstream ($UP @ main) --"
gh api "repos/$UP/contents/kernel/Makefile?ref=main" --jq .content \
  | base64 -d | grep -E '^KSU_VERSION[[:space:]]*:?=|^KSU_VERSION_TAG' | head -3

echo "-- head --"
printf 'lokal    : '; gh api "repos/$OWNER/$REPO/commits/$BR" --jq '.sha[0:12]'
printf 'upstream : '; gh api "repos/$UP/commits/main" --jq '.sha[0:12]'
echo "=== SELESAI ==="
