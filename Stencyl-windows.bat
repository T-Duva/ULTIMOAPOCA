@echo off

:: the behavior of this launcher can be adjusted by uncommenting and modifying the following values
:: in the future, this will likely be replaced by an interface within Stencyl
:: set "_MAX_MEM_=4096"
:: set "_EXTRA_JVM_ARGS_="
:: set "_PRESERVE_TERMINAL_=false"

:: make sure the working directory is the Stencyl folder
cd /D %~dp0

:: ensure that System32 is included in the path
:: https://stackoverflow.com/a/18128797
set required=%SystemRoot%\System32
for %%p in ("%Path:;=" "%") do (
 for %%j in ("" \) do (
  if /i %%p=="%required%%%~j" goto :pathCheckFinished
 )
)
set "Path=%required%;%Path%"
:pathCheckFinished
set required=

:: https://stackoverflow.com/a/49305768
set "_ARCH_=unknown"
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "BuildLabEx" | >nul find /i ".x86fre."   && set "_ARCH_=x86"
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "BuildLabEx" | >nul find /i ".amd64fre." && set "_ARCH_=x86-64"

if "%_ARCH_%"=="x86-64" (
    if "%_MAX_MEM_%"=="" set "_MAX_MEM_=4096"
) else (
    echo Unsupported OS architecture
    pause
    exit /B 1
)

goto:main

:checkJdk
    (call )
    if exist "%~1\bin\java.exe" (
        "%~1\bin\java.exe" --version | >nul find /i "openjdk 21" && echo Found java at %~1 && set "JAVA_HOME=%~1"
    ) else (
        :: echo No JDK found at %~1 && exit /B 1
        exit /B 1
    )
exit /B %ERRORLEVEL%

:downloadFile
    (call )
    where curl >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        curl "%~1" --output "%~2" || exit /B 1
        exit /B 0
    )
    where powershell >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        powershell -noprofile -noninteractive -command "(New-Object Net.WebClient).DownloadFile('%~1', '%~2')"
        if exist "%~2" (exit /B 0) else (exit /B 1)
    )
    echo.
    echo Error: Java couldn't be downloaded automatically.
    echo Please download Java from the above URL and extract it to the above folder.
exit /B 1

:extractFile
    (call )
    if exist "%~2" rmdir /s /q "%~2"
    where tar >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        mkdir "%~2"
        tar -xf "%~1" -C "%~2" --strip-components=1 || exit /B 1
        exit /B 0
    )
    where powershell >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        if exist "%~2-extracted" rmdir /s /q "%~2-extracted"
        mkdir "%~2-extracted"
        powershell -noprofile -noninteractive -command "(new-object -com shell.application).NameSpace('%~2-extracted').CopyHere((new-object -com shell.application).NameSpace('%~1').Items())"
        if "%_ARCH_%"=="x86-64" (
            rename "%~2-extracted\stencyl-jre-win64" "%~nx2" || exit /B 1
        )
        move "%~2-extracted\%~nx2" "%~dp2" || exit /B 1
        rmdir /s /q "%~2-extracted"
        exit /B 0
    )
    echo.
    echo Error: Java couldn't be extracted automatically.
    echo Please extract Java from "%~1" to "%~2".
exit /B 1

:downloadCheckJdk
    (call )
    echo.
    echo Stencyl Java 21 runtime not found. It can be downloaded automatically.
    echo [From URL: https://www.stencyl.com/dl/static/runtimes/stencyl/stencyl-jdk/%~1]
    echo [To Folder: %LocalAppData%\Stencyl\runtimes\stencyl-jdk\%~2]
    echo.
    choice /C YN /N /M "Would you like to download Java? (y/n)"
    if not errorlevel 1 exit /B 1
    if errorlevel 2 exit /B 1
    if not exist "%LocalAppData%\Stencyl\temp\runtimes\stencyl-jdk" mkdir "%LocalAppData%\Stencyl\temp\runtimes\stencyl-jdk"
    if exist "%LocalAppData%\Stencyl\temp\runtimes\stencyl-jdk\%~2.zip" del "%LocalAppData%\Stencyl\temp\runtimes\stencyl-jdk\%~2.zip"
    echo Downloading Java runtime...
    call:downloadFile "https://www.stencyl.com/dl/static/runtimes/stencyl/stencyl-jdk/%~1" "%LocalAppData%\Stencyl\temp\runtimes\stencyl-jdk\%~2.zip" || exit /B 1
    echo Extracting Java runtime...
    call:extractFile "%LocalAppData%\Stencyl\temp\runtimes\stencyl-jdk\%~2.zip" "%LocalAppData%\Stencyl\runtimes\stencyl-jdk\%~2" || exit /B 1
    del "%LocalAppData%\Stencyl\temp\runtimes\stencyl-jdk\%~2.zip"
    echo Java is ready. Launching Stencyl.
    call:checkJdk "%LocalAppData%\Stencyl\runtimes\stencyl-jdk\%~2"
exit /B %ERRORLEVEL%

:main

if "%_ARCH_%"=="x86-64" (
    call:checkJdk "runtimes\jre-win64" && goto:launchStencyl
    call:checkJdk "%LocalAppData%\Stencyl\runtimes\stencyl-jdk\21.0.1+12-win64" && goto:launchStencyl
    call:downloadCheckJdk "21.0.1+12/stencyl-jdk-21.0.1+12-win64.zip" "21.0.1+12-win64" && goto:launchStencyl
)

echo.
echo Failed to launch Stencyl.
echo.
pause
exit /B 1

:launchStencyl

set FREETYPE_PROPERTIES=truetype:interpreter-version=35


if "%_PRESERVE_TERMINAL_%"=="true" goto:launchStencylInline

start "" /B "%JAVA_HOME%\bin\javaw.exe"^
 -Xmx%_MAX_MEM_%m^
 %_EXTRA_JVM_ARGS_%^
  --add-opens=java.desktop/com.sun.imageio.plugins.png=ALL-UNNAMED^
 --add-opens=java.desktop/com.sun.java.swing.plaf.windows=ALL-UNNAMED^
 --add-opens=java.desktop/java.awt=ALL-UNNAMED^
 --add-opens=java.desktop/javax.swing=ALL-UNNAMED^
 --enable-native-access=ALL-UNNAMED^
 --enable-preview^
 -Dsun.java2d.d3d=false^
 -XX:-OmitStackTraceInFastThrow^
 -Xms64m^
 -classpath "lib/*"^
 stencyl.sw.app.Launcher

if not %ERRORLEVEL%==0 pause
goto:eof

:launchStencylInline

"%JAVA_HOME%\bin\java.exe"^
 %_EXTRA_JVM_ARGS_%^
  --add-opens=java.desktop/com.sun.imageio.plugins.png=ALL-UNNAMED^
 --add-opens=java.desktop/com.sun.java.swing.plaf.windows=ALL-UNNAMED^
 --add-opens=java.desktop/java.awt=ALL-UNNAMED^
 --add-opens=java.desktop/javax.swing=ALL-UNNAMED^
 --enable-native-access=ALL-UNNAMED^
 --enable-preview^
 -Dsun.java2d.d3d=false^
 -XX:-OmitStackTraceInFastThrow^
 -Xms64m^
 -classpath "lib/*"^
 stencyl.sw.app.Launcher

if not %ERRORLEVEL%==0 pause

:eof