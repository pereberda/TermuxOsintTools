#!/data/data/com.termux/files/usr/bin/bash
# OSINT‑TUI для Termux

set -e
TMPDIR="$(mktemp -d)"
cleanup(){ rm -rf "$TMPDIR"; }
trap cleanup EXIT

while true; do
  CH=$(whiptail --title "Termux OSINT Toolkit" --menu "Режимы:" 20 60 10 \
    "1" "Username (соцсети)" \
    "2" "Email" \
    "3" "Домен" \
    "4" "Телефон" \
    "5" "Выход" 3>&1 1>&2 2>&3)
  [ $? -ne 0 ] && break

  case "$CH" in
    1)
      SEL=$(whiptail --title "Соцсети" --checklist "Выберите:" 20 60 10 \
        "Instagram" "" ON \
        "Twitter"   "" ON \
        "GitHub"    "" ON \
        "YouTube"   "" ON \
        "Telegram"  "" ON 3>&1 1>&2 2>&3)
      for NET in $SEL; do
        NET=${NET//\"/}
        U=$(whiptail --inputbox "Username для $NET:" 8 48 "" 3>&1 1>&2 2>&3)
        [ -z "$U" ] && continue
        case "$NET" in
          Instagram)
            whiptail --infobox "Instaloader $U…" 5 40
            instaloader --no-videos --no-captions --fast-update --quiet "$U" \
              2>&1 | tee "$TMPDIR/ig.txt"
            whiptail --scrolltext --textbox "$TMPDIR/ig.txt" 20 70 ;;
          Twitter)
            whiptail --infobox "snscrape $U…" 5 40
            snscrape twitter-user "$U" | head -n50 | tee "$TMPDIR/tw.txt"
            whiptail --scrolltext --textbox "$TMPDIR/tw.txt" 20 70 ;;
          GitHub)
            whiptail --infobox "GitHub API $U…" 5 40
            curl -s https://api.github.com/users/"$U" | jq . \
              | tee "$TMPDIR/gh.txt"
            whiptail --scrolltext --textbox "$TMPDIR/gh.txt" 20 70 ;;
          YouTube)
            whiptail --infobox "yt-dlp $U…" 5 40
            yt-dlp "ytsearch:$U" --skip-download \
              --print "%(title)s — %(channel)s\n%(webpage_url)s\n" \
              | tee "$TMPDIR/yt.txt"
            whiptail --scrolltext --textbox "$TMPDIR/yt.txt" 20 70 ;;
          Telegram)
            whiptail --infobox "Telegram $U…" 5 40
            for p in t.me telegram.me tg://resolve?domain=; do
              echo "$p$U"
            done | tee "$TMPDIR/tg.txt"
            whiptail --scrolltext --textbox "$TMPDIR/tg.txt" 20 70 ;;
        esac
      done
      ;;
    2)
      E=$(whiptail --inputbox "Email:" 8 48 "" 3>&1 1>&2 2>&3)
      theHarvester -d "${E#*@}" -l50 -b all 2>&1 | tee "$TMPDIR/email.txt"
      whiptail --scrolltext --textbox "$TMPDIR/email.txt" 20 70 ;;
    3)
      D=$(whiptail --inputbox "Домен:" 8 48 "" 3>&1 1>&2 2>&3)
      whois "$D" > "$TMPDIR/whois.txt"
      sublist3r -d "$D" -o "$TMPDIR/subs.txt"
      cat "$TMPDIR/"*.txt | tee "$TMPDIR/domain.txt"
      whiptail --scrolltext --textbox "$TMPDIR/domain.txt" 20 70 ;;
    4)
      P=$(whiptail --inputbox "Телефон (+…):" 8 48 "" 3>&1 1>&2 2>&3)
      python3 - <<EOF | tee "$TMPDIR/phone.txt"
import phonenumbers
from phonenumbers import geocoder, carrier
n=phonenumbers.parse("$P", None)
print("Valid:", phonenumbers.is_valid_number(n))
print("Region:", geocoder.description_for_number(n,"ru"))
print("Carrier:", carrier.name_for_number(n,"ru"))
EOF
      whiptail --scrolltext --textbox "$TMPDIR/phone.txt" 12 60

      whiptail --infobox "OK.ru поиск…" 5 40
      googler --noprompt "site:ok.ru $P" | tee "$TMPDIR/ok.txt"
      whiptail --scrolltext --textbox "$TMPDIR/ok.txt" 20 70 ;;
    5) break ;;
  esac
done
