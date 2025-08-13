@echo off
setlocal EnableDelayedExpansion

:: Tera Term 실행 파일 경로
set "TTERMPRO=C:\Program Files (x86)\teraterm\ttermpro.exe"

:: 포트 번호 입력
set /p PORTS="Enter COM port numbers separated by spaces (e.g., 1 2 3 4 5 6 7 8): "

:: 로그 저장 경로 입력
set /p LOGDIR="Enter directory path to save logs: "

:: 디렉토리가 존재하지 않으면 생성
if not exist "%LOGDIR%" (
    echo [INFO] Directory "%LOGDIR%" does not exist. Creating...
    mkdir "%LOGDIR%"
)
:: 화면 배치 설정 (1600x900 기준 4x2)
set COLS=4
set ROWS=2
set WINDOW_WIDTH=400
set WINDOW_HEIGHT=450

set COUNT=0

:: 날짜/시간 형식: YYYYMMDD_HHMMSS
for /f "tokens=1-4 delims=/ " %%a in ("%date%") do (
    for /f "tokens=1-2 delims=:." %%x in ("%time: =0%") do (
        set "NOWDATE=%%a%%b%%c"
        set "NOWTIME=%%x%%y"
    )
)

set "DATETIME=!NOWDATE!_!NOWTIME!"

for %%i in (%PORTS%) do (
    :: 기존 해당 COM 포트로 실행 중인 Tera Term 종료
    echo [INFO] Checking if COM%%i is already running...
    tasklist /FI "IMAGENAME eq ttermpro.exe" /V | findstr /I "COM%%i" >nul
    if !errorlevel! EQU 0 (
        echo [INFO] Found running COM%%i session. Closing it...
        taskkill /FI "WINDOWTITLE eq COM%%i*" /F >nul 2>&1
        timeout /t 1 >nul
    )

    :: 창 위치 계산
    set /a COL = COUNT %% COLS
    set /a ROW = COUNT / COLS
    set /a X = COL * WINDOW_WIDTH
    set /a Y = ROW * WINDOW_HEIGHT

    :: 로그 파일 경로 설정
    set "LOGFILE=%LOGDIR%\COM%%i_!DATETIME!.log"

    echo [INFO] Launching COM%%i at X=!X!, Y=!Y!, logging to !LOGFILE!

    start "" "%TTERMPRO%" /C=%%i /BAUD=115200 /L="!LOGFILE!"

    :: 창 이동
    powershell -NoProfile -Command ^
        "$sig='[DllImport(\"user32.dll\")]public static extern bool MoveWindow(IntPtr hWnd,int X,int Y,int W,int H,bool Repaint);';" ^
        "Add-Type -MemberDefinition $sig -Name WinAPI -Namespace Native;" ^
        "$h=(Get-Process ttermpro | Sort-Object StartTime -Descending | Select-Object -First 1).MainWindowHandle;" ^
        "[Native.WinAPI]::MoveWindow($h,!X!,!Y!,%WINDOW_WIDTH%,%WINDOW_HEIGHT%,1);"

    set /a COUNT+=1
)

echo [INFO] All COM ports launched with logging enabled.
pause
