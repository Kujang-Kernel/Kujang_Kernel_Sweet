#!/usr/bin/env bash
# One live Telegram message for both Kujang-Beta builds.
# Usage: tg-live.sh init | set <KEY> <STATUS> | finish | fail
# Env from workflow: TG_TOKEN, TG_CHAT, BRANCH, VERSION, NOMOR, RUN_URL, GITHUB_ACTOR

set -u

API="https://api.telegram.org/bot${TG_TOKEN:-}"
CHAT="${TG_CHAT:-}"
MSGID_FILE="${RUNNER_TEMP:-/tmp}/kujang_tg_msgid"
STATE_FILE="${RUNNER_TEMP:-/tmp}/kujang_tg_state"
KEYBOARD='{"inline_keyboard":[[{"text":"⬇️ Unduh ZIP","url":"'"${RUN_URL:-}"'"},{"text":"💬 Channel","url":"https://t.me/kujang_project"}]]}'

[ -n "${TG_TOKEN:-}" ] && [ -n "$CHAT" ] || exit 0

get() { grep "^$1=" "$STATE_FILE" 2>/dev/null | cut -d= -f2-; }

set_state() {
  local key="$1" val="$2"
  if grep -q "^${key}=" "$STATE_FILE" 2>/dev/null; then
    sed -i "s|^${key}=.*|${key}=${val}|" "$STATE_FILE"
  else
    echo "${key}=${val}" >> "$STATE_FILE"
  fi
}

render() {
  local ksu nonksu status
  ksu="$(get KSU)"; nonksu="$(get NONKSU)"; status="$(get STATUS)"
  TEXT="⚡ <b>KUJANG-BETA · LIVE BUILD</b>${NL}"
  TEXT+="🔥 <b>Kujang Kernel</b>${NL}${NL}"
  TEXT+="<pre>┌──────────────┬────────────┐${NL}"
  TEXT+="│ KSU-AOSP     │ ${ksu} │${NL}"
  TEXT+="│ Non-KSU      │ ${nonksu} │${NL}"
  TEXT+="├──────────────┼────────────┤${NL}"
  TEXT+="│ Status       │ ${status} │${NL}"
  TEXT+="└──────────────┴────────────┘</pre>${NL}${NL}"
  TEXT+="Cabang: <code>${BRANCH:-unknown}</code>${NL}"
  TEXT+="Versi: <code>#${VERSION:-unknown}</code>${NL}"
  TEXT+="Nomor: <code>#${NOMOR:-unknown}</code>${NL}"
  TEXT+="👤 <code>${GITHUB_ACTOR:-unknown}</code>${NL}${NL}"
  TEXT+="<a href=\"${RUN_URL:-}\">📄 Lihat log build</a>"
}

send() {
  local method="$1" extra=()
  [ "$method" = "editMessageText" ] && extra=(-d "message_id=$(cat "$MSGID_FILE")")
  RESP=$(curl -sS -X POST "${API}/${method}" \
    -d "chat_id=${CHAT}" \
    -d parse_mode=HTML \
    -d disable_web_page_preview=true \
    "${extra[@]}" \
    --data-urlencode "text=$TEXT" \
    --data-urlencode "reply_markup=$KEYBOARD" 2>&1)
  case "$RESP" in
    *'"ok":true'*) echo "::notice::Telegram ${method} OK";;
    *) echo "::warning::Telegram ${method} gagal: $RESP";;
  esac
}

CMD="${1:-}"
case "$CMD" in
  init)
    NL=$'\n'
    : > "$STATE_FILE"
    echo "KSU=⏳ Menunggu" >> "$STATE_FILE"
    echo "NONKSU=⏳ Menunggu" >> "$STATE_FILE"
    echo "STATUS=🔄 Berjalan" >> "$STATE_FILE"
    render
    RESP=$(curl -sS -X POST "${API}/sendMessage" \
      -d "chat_id=${CHAT}" \
      -d parse_mode=HTML \
      -d disable_web_page_preview=true \
      --data-urlencode "text=$TEXT" \
      --data-urlencode "reply_markup=$KEYBOARD" 2>&1)
    MID=$(printf '%s' "$RESP" | sed -n 's/.*"message_id":[[:space:]]*\([0-9]*\).*/\1/p')
    if [ -n "$MID" ]; then echo "$MID" > "$MSGID_FILE"; echo "::notice::Telegram message_id=$MID"; else echo "::warning::Telegram init gagal: $RESP"; fi
    ;;
  set)
    NL=$'\n'
    set_state "$2" "$3"
    render
    send editMessageText
    ;;
  finish)
    NL=$'\n'
    set_state STATUS '✅ Selesai'
    render
    send editMessageText
    ;;
  fail)
    NL=$'\n'
    set_state STATUS '❌ Gagal'
    [ -n "${CURRENT_BUILD:-}" ] && set_state "$CURRENT_BUILD" '❌ Gagal'
    render
    send editMessageText
    ;;
esac
