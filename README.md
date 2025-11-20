# Unix Alarm Clock Script

A simple bash alarm clock for Unix/Linux lab project.

## Description
This script allows users to set an alarm for a specific time. When the alarm time is reached, it displays a "WAKE UP!" message with system beeps.

## Features
- Supports 24 hour time format (HH:MM)
- Input validation for correct time format
- Real time clock display
- Color coded terminal output
- System beep / alarm sound
- User-friendly and easy to use
- Graceful exit with Ctrl + C

## Usage

1. Make the script executable:

chmod +x alarm_clock.sh

2. Run the script:
bash./alarm_clock.sh

3. Enter alarm time when prompted (e.g., 07:00 or 14:30)
4. Wait for the alarm or press Ctrl+C to cancel


## Requirements

1. Unix/Linux operating system
2. Bash shell
3. Optional: afplay (macOS) or paplay (Linux) for audio playback
(Script automatically falls back to terminal beep)


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

<img width="469" height="607" alt="Screenshot 2025-11-20 at 10 03 48 PM" src="https://github.com/user-attachments/assets/d743bd2e-c2fd-457e-b2f7-15cfa58bc8b7" />
