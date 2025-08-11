@echo off
setlocal EnableDelayedExpansion

set TTERMPRO="C:\Program Files (x86)\teraterm\ttermpro.exe"
set /p PORTS="Enter COM port numbers separated by spaces (e.g., 1 2 3 4 5 6 7 8): "
set /p LOGDIR="Enter log save directory path: "

:: Fixed 1600x900 screen, 4x2 layout
set COLS=4
set ROWS=2
set WINDOW_WIDTH=400
set WINDOW_HEIGHT=450

set COUNT=0

if not exist "%LOGDIR%" (
    mkdir "%LOGDIR%"
)

for %%i in (%PORTS%) do (
    set /a COL = COUNT %% COLS
    set /a ROW = COUNT / COLS
    set /a X = COL * WINDOW_WIDTH
    set /a Y = ROW * WINDOW_HEIGHT

    :: 날짜/시간 포맷 생성
    for /f "tokens=1-4 delims=/ " %%a in ("%date%") do (
        for /f "tokens=1-2 delims=:." %%x in ("%time%") do (
            set "NOWDT=%%a%%b%%c_%%x%%y"
        )
    )

    set "LOGFILE=%LOGDIR%\COM%%i_!NOWDT!.log"

    echo [INFO] Launching COM%%i with log file "!LOGFILE!"
    start "" %TTERMPRO% /C=%%i /BAUD=115200 /L="!LOGFILE!"

    powershell -NoProfile -Command ^
        "$sig='[DllImport(\"user32.dll\")]public static extern bool MoveWindow(IntPtr hWnd,int X,int Y,int W,int H,bool Repaint);';" ^
        "Add-Type -MemberDefinition $sig -Name WinAPI -Namespace Native;" ^
        "$h=(Get-Process ttermpro | Sort-Object StartTime -Descending | Select-Object -First 1).MainWindowHandle;" ^
        "[Native.WinAPI]::MoveWindow($h,!X!,!Y!,%WINDOW_WIDTH%,%WINDOW_HEIGHT%,1);"

    set /a COUNT+=1
)

echo [INFO] All COM ports opened with logging enabled.
pause
