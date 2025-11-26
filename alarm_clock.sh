#!/bin/bash

# ===================== Colors =====================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'
BOLD='\033[1m'; NC='\033[0m'

SNOOZE_MINUTES=5
LOG_FILE="alarm_log.txt"

# ===================== Cleanup =====================
cleanup() { 
    echo -e "\n${RED}Alarm canceled. Goodbye!${NC}"; 
    exit 0 
}
trap cleanup SIGINT

# ===================== Functions =====================
display_time() { 
    echo -e "${BLUE}Current time: $(date '+%H:%M:%S')${NC}"; 
}

validate_time() { 
    [[ "$1" =~ ^([01]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; 
}

beep() { 
    for i in {1..5}; do printf "\a"; sleep 0.2; done; 
}

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
    local target_h="$1" target_m="$2"
    curr_h=$(date '+%H'); curr_m=$(date '+%M')

    # force base-10
    curr_h=$((10#$curr_h)); curr_m=$((10#$curr_m))
    target_h=$((10#$target_h)); target_m=$((10#$target_m))

    now=$((curr_h*60 + curr_m))
    target=$((target_h*60 + target_m))

    ((target < now)) && target=$((target + 1440))

    diff=$((target - now))
    printf "%02dh %02dm" $((diff/60)) $((diff%60))
}

log_alarm() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | Alarm set for $1 | Label: ${3:-None} | Msg: ${2:-None}" >>"$LOG_FILE"
}

add_snooze() {
    local h=$((10#$1)) 
    local m=$((10#$2))
    local snooze="$3"

    m=$((m + snooze))
    if (( m >= 60 )); then 
        h=$((h + m/60))
        m=$((m % 60))
    fi
    (( h >= 24 )) && h=$((h % 24))

    printf "%02d:%02d" "$h" "$m"
}

ring_alarm() {
    local time="$1" msg="$2" label="$3"
    clear

    echo -e "\n${RED}${BOLD}========== WAKE UP! ==========${NC}"
    echo -e "${GREEN}Alarm time reached: $(date '+%H:%M:%S')${NC}"
    [[ -n "$label" ]] && echo -e "${CYAN}Label: $label${NC}"
    [[ -n "$msg" ]] && echo -e "${YELLOW}Message: $msg${NC}"

    play_sound

    for i in {1..3}; do
        echo -e "${RED}${BOLD}>>> WAKE UP! <<<${NC}"
        sleep 1
    done

    echo -e "${YELLOW}Press 's' to snooze (${SNOOZE_MINUTES} min) or any key to dismiss...${NC}"
    read -r -n 1 -t 30 key 2>/dev/null; echo ""

    if [[ $key =~ [sS] ]]; then
        echo -e "${MAGENTA}Snoozing for ${SNOOZE_MINUTES} minutes...${NC}"
        return 1
    else
        echo -e "${GREEN}Alarm dismissed. Have a great day!${NC}"
        return 0
    fi
}

view_alarms() {
    if [[ ! -f "$LOG_FILE" ]]; then
        echo -e "${YELLOW}No alarms logged yet.${NC}"
        return
    fi
    echo -e "${BOLD}==== Logged Alarms ====${NC}"
    tail -n 10 "$LOG_FILE"
}

# ===================== Menu Loop =====================
while true; do
    clear
    echo -e "${BOLD}=====================================${NC}"
    echo -e "${BOLD}           ALARM CLOCK MENU${NC}"
    echo -e "${BOLD}=====================================${NC}\n"

    display_time

    echo -e "\n${CYAN}Choose an option:${NC}"
    echo "1. Set a new alarm"
    echo "2. View time until next alarm"
    echo "3. View last 10 logged alarms"
    echo "4. Exit"

    read -rp "Enter choice (1-4): " choice

    case "$choice" in
    1)
        echo -e "\n${CYAN}Alarm mode:${NC}"
        echo "1. Specific time (HH:MM)"
        echo "2. After N minutes"
        read -rp "Choice (1-2): " mode

        case "$mode" in
        1)
            read -rp "Enter alarm time (HH:MM): " alarm_time
            if ! validate_time "$alarm_time"; then
                echo -e "${RED}Invalid time format.${NC}"
                sleep 2
                continue
            fi
            ;;
        2)
            read -rp "Enter minutes from now: " mins
            if ! [[ "$mins" =~ ^[0-9]+$ ]]; then 
                echo -e "${RED}Invalid number.${NC}"
                sleep 2
                continue
            fi
            if date -v+"${mins}M" "+%H:%M" >/dev/null 2>&1; then
                alarm_time=$(date -v+"${mins}M" "+%H:%M")
            else
                alarm_time=$(date -d "+$mins minutes" "+%H:%M")
            fi
            ;;
        *)
            echo -e "${RED}Invalid mode.${NC}"
            sleep 2
            continue
            ;;
        esac

        # FIX: force base-10
        alarm_hour=$((10#${alarm_time%:*}))
        alarm_min=$((10#${alarm_time#*:}))

        read -rp "Enter label (optional): " label
        read -rp "Enter message (optional): " msg

        until_time=$(time_diff "$alarm_hour" "$alarm_min")
        log_alarm "$alarm_time" "$msg" "$label"

        echo -e "${GREEN}Alarm set for ${BOLD}$alarm_time${NC} | Time until alarm: $until_time"
        sleep 2

        # Alarm monitoring loop
        while true; do
            curr_h=$(date '+%H')
            curr_m=$(date '+%M')

            curr_h=$((10#$curr_h))
            curr_m=$((10#$curr_m))

            if (( curr_h == alarm_hour && curr_m == alarm_min )); then
                ring_alarm "$alarm_time" "$msg" "$label"
                if (( $? == 1 )); then
                    new_time=$(add_snooze "$alarm_hour" "$alarm_min" "$SNOOZE_MINUTES")
                    alarm_hour=$((10#${new_time%:*}))
                    alarm_min=$((10#${new_time#*:}))
                    alarm_time="$new_time"
                    sleep 60
                else
                    break
                fi
            fi
            sleep 1
        done
        ;;

    2)
        if [[ -z "$alarm_time" ]]; then
            echo -e "${YELLOW}No alarm set currently.${NC}"
        else
            until_time=$(time_diff "$alarm_hour" "$alarm_min")
            echo -e "${GREEN}Time until next alarm (${alarm_time}): $until_time${NC}"
        fi
        read -rp "Press Enter to continue..." _
        ;;

    3)
        view_alarms
        read -rp "Press Enter to continue..." _
        ;;

    4)
        echo -e "${GREEN}Exiting Alarm Clock. Goodbye!${NC}"
        exit 0
        ;;

    *)
        echo -e "${RED}Invalid choice.${NC}"
        sleep 2
        ;;
    esac
done
