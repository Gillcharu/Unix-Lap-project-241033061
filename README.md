# Unix Alarm Clock Script

A simple bash alarm clock for Unix/Linux lab project.

## Description
This script allows users to set an alarm for a specific time. When the alarm time is reached, it displays a "WAKE UP!" message with system beeps.

## Features
- 24-hour time format (HH:MM)
- Input validation
- Real-time clock display
- Color-coded terminal output
- System beep alerts
- Simple and easy to use

## Usage

1. Make the script executable:

chmod +x alarm_clock.sh

2. Run the script:
bash./alarm_clock.sh

Enter alarm time when prompted (e.g., 07:00 or 14:30)
Wait for the alarm or press Ctrl+C to cancel

3. Enter alarm time when prompted (e.g., 07:00 or 14:30)
4. Wait for the alarm or press Ctrl+C to cancel


## Requirements

1. Unix/Linux operating system
2. Bash shell


## Lab Project

**Course:** Unix Lab
**Project:** Alarm Clock Script  
**ID:** 241033061


## Author

Charu


## How It Works

1. User inputs desired alarm time in HH:MM format
2. Script validates the input format
3. Continuously checks system time every second
4. When current time matches alarm time, triggers alert
5. Displays colorful "WAKE UP!" message with system beeps
