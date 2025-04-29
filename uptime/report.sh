#!/bin/sh

# Konfigurasi
LOGFILE="/root/uptime/httping.log"
TOKEN="your_bot_token"
CHAT_ID="your_chat_id"

# Fungsi untuk ambil statistik berdasarkan rentang waktu
get_stats() {
    local from=$1
    local label="$2"
    local NOW=$(date +%s)  # Dihitung ulang setiap pemanggilan

    # Memastikan data yang dihitung adalah yang valid dan ada dalam rentang waktu yang diminta
    awk -F"|" -v now=$NOW -v from=$from -v label="$label" '
    BEGIN {
        count=0; up=0;
        sum_min=0; sum_avg=0; sum_max=0;
        min=999999; max=0;
        min_found=0; max_found=0; avg_found=0;
    }
    {
        if ($1 >= now - from) {
            count++;
            if ($3 == 1) {
                split($2, parts, "/");
                min_val = parts[1] + 0;
                avg_val = parts[2] + 0;
                max_val = parts[3] + 0;

                # Update per baris
                sum_min += min_val;
                sum_avg += avg_val;
                sum_max += max_val;

                if (min_val < min) { min = min_val; min_found = 1; }
                if (max_val > max) { max = max_val; max_found = 1; }
                avg_found++;
                up++;
            }
        }
    }
    END {
        if (count > 0 && avg_found > 0) {
            avg_min = sum_min / avg_found;
            avg_avg = sum_avg / avg_found;
            avg_max = sum_max / avg_found;
            uptime = (up / count) * 100;

            # Output result with min, max, avg values
            printf "*%s*\nAvg: %.2f ms\nMin: %.2f ms\nMax: %.2f ms\nUptime: %.2f%%\n", label, avg_avg, avg_min, avg_max, uptime;
        } else {
            printf "*%s*\nNo data available for the specified period.\n", label;
        }
    }' "$LOGFILE"
}

# Buat pesan laporan
MSG=$(cat <<EOF
📡 *Monitoring Report Response Time* (one.one.one.one)

$(get_stats $((1*86400)) "Uptime 24 Jam")

$(get_stats $((2*86400)) "Last 2 Hari")

$(get_stats $((7*86400)) "Uptime 7 Hari")

$(get_stats $((30*86400)) "Uptime 30 Hari")

$(get_stats $((90*86400)) "Uptime 90 Hari")
EOF
)

# Kirim ke Telegram
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
  -d "chat_id=$CHAT_ID" \
  --data-urlencode "text=$MSG" \
  -d "parse_mode=Markdown"
