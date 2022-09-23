@ECHO OFF
TITLE "Build & Deploy for Itch"

FOR /F "tokens=1 delims= " %%i IN ('getPID') DO (
    set PID=%%i
)

"C:\Program Files\PowerToys\modules\Awake\PowerToys.Awake.exe" --pid %PID%

butler upgrade

ECHO "[Win] Building..."
lime build windows -clean -final
IF %ERRORLEVEL% == 0 GOTO DEPLOYW
ECHO "Build failed, exiting..."
PAUSE
EXIT /B %ERRORLEVEL%

:DEPLOYW
ECHO "[Win] Deploying to Itch..."

butler push export/windows/bin axolstudio/starmander:windows
IF %ERRORLEVEL% == 0 GOTO SUCCESSW
ECHO "Deploy failed, exiting..."
PAUSE
EXIT /B %ERRORLEVEL%
:SUCCESSW
ECHO "[Win] Success!"

ECHO "[HTML5] Building..."
lime build html5 -clean -final -nolaunch
IF %ERRORLEVEL% == 0 GOTO DEPLOYH
ECHO "Build failed, exiting..."
PAUSE
EXIT /B %ERRORLEVEL%

:DEPLOYH
ECHO "[HTML5] Deploying to Itch..."
butler push export/html5/bin axolstudio/starmander:html5
IF %ERRORLEVEL% == 0 GOTO SUCCESSH
ECHO "Deploy failed, exiting..."
PAUSE
EXIT /B %ERRORLEVEL%

:SUCCESSH
ECHO "[HTML5] Success!"

PAUSE
