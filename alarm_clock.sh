#!/bin/bash

# Alarm Clock Script
# Author: Unix Lab Project
# Description: Sets an alarm for a specific time and displays a wake-up message

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Function to display current time
display_current_time() {
    echo -e "${BLUE}Current time: $(date '+%H:%M:%S')${NC}"
}

# Function to validate time format
validate_time() {
    if [[ $1 =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to beep (system beep)
beep_sound() {
    for i in {1..5}; do
        echo -e "\a"
        sleep 0.3
    done
}

# Clear screen for better presentation
clear

# Display header
echo -e "${BOLD}=====================================${NC}"
echo -e "${BOLD}        ALARM CLOCK SCRIPT${NC}"
echo -e "${BOLD}=====================================${NC}"
echo ""

# Display current time
display_current_time
echo ""

# Ask user for alarm time
echo -e "${YELLOW}Enter alarm time in 24-hour format (HH:MM):${NC}"
read -p "Alarm time: " alarm_time

# Validate input
if ! validate_time "$alarm_time"; then
    echo -e "${RED}Error: Invalid time format. Please use HH:MM (24-hour format)${NC}"
    echo "Example: 07:00 or 14:30"
    exit 1
fi

# Extract hours and minutes
alarm_hour=$(echo $alarm_time | cut -d: -f1)
alarm_minute=$(echo $alarm_time | cut -d: -f2)

# Remove leading zeros for comparison
alarm_hour=$((10#$alarm_hour))
alarm_minute=$((10#$alarm_minute))

echo ""
echo -e "${GREEN}Alarm set for $alarm_time${NC}"
echo -e "${BLUE}Waiting for alarm time...${NC}"
echo -e "${YELLOW}Press Ctrl+C to cancel${NC}"
echo ""

# Main alarm loop
while true; do
    # Get current hour and minute
    current_hour=$(date '+%H')
    current_minute=$(date '+%M')
    current_second=$(date '+%S')
    
    # Remove leading zeros
    current_hour=$((10#$current_hour))
    current_minute=$((10#$current_minute))
    
    # Display current time every 10 seconds
    if [ $((10#$current_second % 10)) -eq 0 ]; then
        echo -e "Current: $(date '+%H:%M:%S') | Alarm: $alarm_time"
    fi
    
    # Check if current time matches alarm time
    if [ $current_hour -eq $alarm_hour ] && [ $current_minute -eq $alarm_minute ]; then
        clear
        echo ""
        echo -e "${RED}${BOLD}=====================================${NC}"
        echo -e "${RED}${BOLD}           WAKE UP!${NC}"
        echo -e "${RED}${BOLD}=====================================${NC}"
        echo ""
        echo -e "${GREEN}Alarm time reached: $(date '+%H:%M:%S')${NC}"
        echo ""
        
        # Beep sound
        beep_sound
        
        # Display wake up message multiple times for emphasis
        for i in {1..3}; do
            echo -e "${RED}${BOLD}>>> WAKE UP! IT IS TIME! <<<${NC}"
            sleep 1
        done
        
        echo ""
        echo -e "${YELLOW}Alarm completed. Have a great day!${NC}"
        exit 0
    fi
    
    # Sleep for 1 second before checking again
    sleep 1
done
