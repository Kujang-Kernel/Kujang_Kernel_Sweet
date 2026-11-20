#!/usr/bin/env bash
# Telegram notifier for Kujang-Beta builds (GitHub Actions).
# Set repo secrets TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID; they arrive as
# TG_TOKEN / TG_CHAT via the job-level env block in Kujang_Beta.yml.
# If either is missing the script exits quietly so builds still succeed.

set -u

[ -n "${TG_TOKEN:-}" ] || exit 0
[ -n "${TG_CHAT:-}" ] || exit 0

STAGE="${1:-info}"
BUILD_TYPE="${BUILD_TYPE:-unknown}"
BRANCH="${BRANCH:-unknown}"
COMMIT="${COMMIT:-unknown}"
RUN_URL="${RUN_URL:-}"

NL=$'\n'

case "$STAGE" in
  start)
    TEXT="🚀 <b>Kujang-Beta build dimulai</b>${NL}"
    TEXT+="👤 ${GITHUB_ACTOR:-unknown}${NL}"
    TEXT+="🌿 ${BRANCH}${NL}"
    TEXT+="🔀 ${BUILD_TYPE}${NL}"
    TEXT+="📌 <code>${COMMIT:0:7}</code>"
    ;;
  toolchain)
    TEXT="🛠️ <b>Toolchain siap</b>${NL}Clang 17 (ZyCromerZ) + GCC greenforce${NL}🔀 ${BUILD_TYPE}"
    ;;
  kernel)
    TEXT="✅ <b>Kernel selesai dikompilasi</b>${NL}🔀 ${BUILD_TYPE}"
    ;;
  dtbo)
    TEXT="✅ <b>DTBO 90Hz selesai</b>${NL}🔀 ${BUILD_TYPE}"
    ;;
  success)
    TEXT="🎉 <b>Build selesai</b>${NL}🔀 ${BUILD_TYPE}${NL}📦 Flashable ZIP sudah di-upload${NL}${RUN_URL}"
    ;;
  fail)
    TEXT="❌ <b>Build gagal</b>${NL}🔀 ${BUILD_TYPE}${NL}${RUN_URL}"
    ;;
  *)
    TEXT="ℹ️ ${STAGE}${NL}🔀 ${BUILD_TYPE}"
    ;;
esac

RESP=$(curl -sS -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
  -d chat_id="$TG_CHAT" \
  -d parse_mode=HTML \
  -d disable_web_page_preview=true \
  --data-urlencode "text=$TEXT" 2>&1)

case "$RESP" in
  *'"ok":true'*)
    echo "Telegram notified: $STAGE ($BUILD_TYPE)"
    ;;
  *)
    echo "::warning::Telegram notify failed ($STAGE): $RESP"
    ;;
esac
