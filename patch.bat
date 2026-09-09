@echo off
rem ============================================================
rem  Zhihu ad-free patch without root (one click)
rem  Steps: fetch deps (cached) -> verify Zhihu APK MD5 ->
rem         LSPatch embeds Zhiliao module -> output patched APK
rem  Requires: Java 21+ on PATH
rem ============================================================
setlocal enabledelayedexpansion

rem ---- Versions and sources (edit these after Zhihu updates) ----
set "ZHIHU_URL=https://android-apps.pp.cn/fs08/2026/01/28/3/2_db8c28583f8a75c84674d27592c12564.apk?yingid=web_space^&packageid=801716983^&md5=08fb7728352bf31438456f22d73a86c4^&minSDK=21^&size=139546986^&shortMd5=ffcc58f7d14f7ada330284c452e10fba^&crc32=734276179^&did=2cb93bf76e59b7a8998cea2b8ae55a92^&nrd=0"
set "ZHIHU_MD5=08fb7728352bf31438456f22d73a86c4"
set "ZHIHU_VER=10.86.0"
set "ZHILIAO_VERSION=26.02.03"
set "LSPATCH_URL=https://github.com/JingMatrix/LSPatch/releases/download/v1.2/lspatch-v1.2-487-release.jar"
set "SIGBYPASS=2"

rem ---- Dirs: deps and cache live under the env root per workspace convention ----
set "ENV_ROOT=G:\nixang\huanjing"
set "TOOL_DIR=%ENV_ROOT%\lspatch"
set "CACHE_DIR=%ENV_ROOT%\installers"
set "PROJ_DIR=%~dp0"
set "OUT_DIR=%PROJ_DIR%output"
set "LSPATCH_JAR=%TOOL_DIR%\lspatch.jar"
set "ZHILIAO_APK=%TOOL_DIR%\Zhiliao_%ZHILIAO_VERSION%.apk"
set "ZHIHU_APK=%CACHE_DIR%\zhihu-%ZHIHU_VER%.apk"

echo ============================================
echo  Zhihu %ZHIHU_VER% + Zhiliao %ZHILIAO_VERSION% ad-free patch
echo ============================================

where java >nul 2>nul || (echo [ERROR] java not found on PATH & exit /b 1)

rem ---- 1. LSPatch jar ----
if exist "%LSPATCH_JAR%" (
    echo [1/4] LSPatch jar exists: %LSPATCH_JAR%
) else (
    echo [1/4] downloading LSPatch jar ...
    mkdir "%TOOL_DIR%" 2>nul
    curl -sL -o "%LSPATCH_JAR%" "%LSPATCH_URL%" || (echo [ERROR] LSPatch download failed & exit /b 1)
)

rem ---- 2. Zhiliao module ----
if exist "%ZHILIAO_APK%" (
    echo [2/4] Zhiliao module exists: %ZHILIAO_APK%
) else (
    echo [2/4] downloading Zhiliao %ZHILIAO_VERSION% ...
    curl -sL -o "%ZHILIAO_APK%" "https://github.com/shatyuka/Zhiliao/releases/download/%ZHILIAO_VERSION%/Zhiliao_%ZHILIAO_VERSION%.apk" || (echo [ERROR] Zhiliao download failed & exit /b 1)
)

rem ---- 3. Zhihu official APK + MD5 check ----
if exist "%ZHIHU_APK%" (
    echo [3/4] Zhihu APK exists: %ZHIHU_APK%
) else (
    echo [3/4] downloading Zhihu %ZHIHU_VER% from wandoujia archive ...
    curl -sL -o "%ZHIHU_APK%" "%ZHIHU_URL%" || (echo [ERROR] Zhihu APK download failed & exit /b 1)
)
for /f %%M in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm MD5 '%ZHIHU_APK%').Hash.ToLower()"') do set "ACTUAL_MD5=%%M"
if not "!ACTUAL_MD5!"=="%ZHIHU_MD5%" (
    echo [ERROR] Zhihu APK MD5 mismatch: expected %ZHIHU_MD5%, got !ACTUAL_MD5!
    echo         Download the official APK manually and place it at %ZHIHU_APK%
    exit /b 1
)
echo       MD5 OK

rem ---- 4. LSPatch embed patch ----
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"
echo [4/4] patching (sig bypass level %SIGBYPASS%, embedding Zhiliao) ...
java -jar "%LSPATCH_JAR%" -o "%OUT_DIR%" -m "%ZHILIAO_APK%" -l %SIGBYPASS% -f --injectdex "%ZHIHU_APK%"
if errorlevel 1 (echo [ERROR] LSPatch failed & exit /b 1)

echo.
echo ============================================
echo  Done! Patched APK is in %OUT_DIR%
echo  Install: uninstall stock Zhihu first, then install the
echo  patched APK, and disable auto-update for Zhihu.
echo ============================================
endlocal
