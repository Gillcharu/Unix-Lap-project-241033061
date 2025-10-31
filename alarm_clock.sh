#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'
SNOOZE_MINUTES=5
LOG_FILE="alarm_log.txt"
cleanup() { echo -e "\n${RED}Alarm canceled. Goodbye!${NC}"; exit 0; }
trap cleanup SIGINT
display_time() { echo -e "${BLUE}Current time: $(date '+%H:%M:%S')${NC}"; }
validate_time() { [[ $1 =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]; }
beep() { for _ in {1..5}; do echo -e "\a"; sleep 0.2; done; }
play_sound() {
    if command -v afplay >/dev/null 2>&1; then
        afplay /System/Library/Sounds/Glass.aiff &
    elif command -v paplay >/dev/null 2>&1; then
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga &
    else
        beep
    fi
}
time_diff() {
    local target_h=$1 target_m=$2
    local curr_h curr_m
    curr_h=$(date '+%H'); curr_m=$(date '+%M')
    curr_h=$((10#$curr_h)); curr_m=$((10#$curr_m))
    target_h=$((10#$target_h)); target_m=$((10#$target_m))
    local now=$((curr_h * 60 + curr_m))
    local target=$((target_h * 60 + target_m))
    (( target < now )) && target=$((target + 1440))
    local diff=$((target - now))
    printf "%02dh %02dm" $((diff / 60)) $((diff % 60))
}
log_alarm() { echo "$(date '+%Y-%m-%d %H:%M:%S') | Alarm set for $1 | Label: ${3:-None} | Msg: ${2:-None}" >>"$LOG_FILE"; }
add_snooze() {
    local h=$1 m=$2 snooze=$3
    m=$((m + snooze))
    (( m >= 60 )) && { h=$((h + m / 60)); m=$((m % 60)); }
    (( h >= 24 )) && h=$((h % 24))
    printf "%02d:%02d" "$h" "$m"
}
ring_alarm() {
    local time=$1 msg=$2 label=$3
    clear
    echo -e "\n${RED}${BOLD}========== WAKE UP! ==========${NC}"
    echo -e "${GREEN}Alarm time reached: $(date '+%H:%M:%S')${NC}"
    [[ -n $label ]] && echo -e "${CYAN}Label: $label${NC}"
    [[ -n $msg ]] && echo -e "${YELLOW}Message: $msg${NC}"
    echo ""
    play_sound
    for _ in {1..3}; do echo -e "${RED}${BOLD}>>> WAKE UP! <<<${NC}"; sleep 1; done
    echo -e "${YELLOW}Press 's' to snooze (${SNOOZE_MINUTES} min) or any other key to dismiss...${NC}"
    read -n 1 -t 30 key; echo ""
    if [[ $key =~ [sS] ]]; then
        echo -e "${MAGENTA}Snoozing for ${SNOOZE_MINUTES} minutes...${NC}"; return 1
    else
        echo -e "${GREEN}Alarm dismissed. Have a great day!${NC}"; return 0
    fi
}
clear
echo -e "${BOLD}=====================================${NC}"
echo -e "${BOLD}           ALARM CLOCK${NC}"
echo -e "${BOLD}=====================================${NC}\n"
display_time
echo ""
echo -e "${CYAN}Choose alarm mode:${NC}"
echo "1. Specific time (HH:MM)"
echo "2. After N minutes"
read -rp "Choice (1-2): " mode
case $mode in
1)
    read -rp "Enter alarm time (HH:MM): " alarm_time
    if ! validate_time "$alarm_time"; then echo -e "${RED}Invalid time format.${NC}"; exit 1; fi ;;
2)
    read -rp "Enter minutes from now: " mins
    [[ ! $mins =~ ^[0-9]+$ ]] && { echo -e "${RED}Invalid number.${NC}"; exit 1; }
    target=$(date -d "+$mins minutes" '+%H:%M' 2>/dev/null || date -v+"${mins}M" '+%H:%M')
    alarm_time=$target ;;
*) echo -e "${RED}Invalid choice.${NC}"; exit 1 ;;
esac
alarm_hour=${alarm_time%:*}
alarm_min=${alarm_time#*:}
read -rp "Enter label (optional): " label
read -rp "Enter custom message (optional): " msg
until_time=$(time_diff "$alarm_hour" "$alarm_min")
log_alarm "$alarm_time" "$msg" "$label"
echo ""
echo -e "${GREEN}Alarm set for ${BOLD}$alarm_time${NC}"
[[ -n $label ]] && echo -e "${CYAN}Label: $label${NC}"
echo -e "${BLUE}Time until alarm: $until_time${NC}"
echo -e "${YELLOW}Press Ctrl+C to cancel.${NC}\n"
while true; do
    curr_h=$(date '+%H'); curr_m=$(date '+%M'); curr_s=$(date '+%S')
    curr_h=$((10#$curr_h)); curr_m=$((10#$curr_m))
    if (( curr_h == 10#$alarm_hour && curr_m == 10#$alarm_min )); then
        ring_alarm "$alarm_time" "$msg" "$label"
        if [[ $? -eq 1 ]]; then
            new_time=$(add_snooze "$alarm_hour" "$alarm_min" "$SNOOZE_MINUTES")
            alarm_hour=${new_time%:*}; alarm_min=${new_time#*:}; alarm_time=$new_time; sleep 60
        else exit 0; fi
    fi
    if (( curr_s % 30 == 0 )); then
        echo -e "Current: $(date '+%H:%M:%S') | Alarm: $alarm_time | Left: $(time_diff "$alarm_hour" "$alarm_min")"
    fi
    sleep 1
done

