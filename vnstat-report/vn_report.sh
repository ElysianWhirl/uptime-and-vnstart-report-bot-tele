#!/bin/sh

BOT_TOKEN="your_bot_token"
CHAT_ID="your_chat_id"

# Daftar interface yang ingin kamu monitor
INTERFACES="br-lan eth2 macvlan"

TMPDIR="/tmp/vnstati"
mkdir -p $TMPDIR

for IFACE in $INTERFACES; do
  # Grafik harian
  vnstati -d -i "$IFACE" -o "$TMPDIR/${IFACE}_daily.png"

  # Grafik bulanan
  vnstati -m -i "$IFACE" -o "$TMPDIR/${IFACE}_monthly.png"

  # Kirim Harian
  curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendPhoto" \
    -F chat_id="$CHAT_ID" \
    -F photo="@$TMPDIR/${IFACE}_daily.png" \
    -F caption="📊 *Grafik Harian* untuk interface \`$IFACE\`" \
    -F parse_mode="Markdown"

  # Kirim Bulanan
  curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendPhoto" \
    -F chat_id="$CHAT_ID" \
    -F photo="@$TMPDIR/${IFACE}_monthly.png" \
    -F caption="📆 *Grafik Bulanan* untuk interface \`$IFACE\`" \
    -F parse_mode="Markdown"
done

# Bersihkan
rm -rf $TMPDIR
