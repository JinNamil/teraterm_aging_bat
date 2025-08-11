# Tera Term Multi-COM Launcher with Logging

This batch script automates the process of launching multiple **Tera Term** sessions for different COM ports, arranging them in a neat grid layout, and enabling real-time serial logging.

## Features
- Open multiple COM ports at once in Tera Term.
- Arrange Tera Term windows in a predefined grid layout (configurable via script variables).
- Prompt user for:
  - **COM port list** (space-separated).
  - **Log directory** to store serial data.
- Automatically create a timestamped log file for each COM port.
- Real-time serial data logging using Tera Term's `/L` option.
- Automatic window positioning via PowerShell + Windows API calls.

## Requirements
- Windows OS
- [Tera Term](https://ttssh2.osdn.jp/) installed (default path: `C:\Program Files (x86)\teraterm\ttermpro.exe`).
- PowerShell enabled on your system.

## Usage
1. Ensure Tera Term is installed.
2. Download and place the batch script on your PC.
3. Open Command Prompt and run:
   ```bash
   teraterm_aging.bat
