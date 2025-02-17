@echo off
echo ================================
echo Detalles del Sistema y Red
echo ================================

:: Habilitar expansión retardada de variables
setlocal enabledelayedexpansion

:: Cambiar la codificación a UTF-8 para evitar problemas de caracteres
chcp 65001

:: Obtener el nombre del equipo
echo Nombre del equipo:
hostname

:: Obtener el nombre del dominio
echo Nombre del dominio:
echo %USERDOMAIN%

:: Obtener la hora del equipo en formato de 12 horas (AM/PM)
for /f "tokens=1,2 delims=:" %%a in ("%TIME%") do (
    set horas=%%a
    set minutos=%%b
)

:: Ajustar la hora para formato de 12 horas
set /a horas12=%horas%
if %horas12% lss 12 (
    set AMPM=AM
) else (
    if %horas12% geq 12 (
        if %horas12% gtr 12 (
            set /a horas12=%horas12%-12
        )
        set AMPM=PM
    )
)

:: Mostrar la hora en formato de 12 horas
if %horas12% lss 10 set horas12=0%horas12%
echo Hora del equipo: %horas12%:%minutos% %AMPM%

:: Obtener la zona horaria y UTC usando PowerShell
for /f "delims=" %%i in ('powershell -Command "(Get-TimeZone).Id"') do set ZONA_HORARIA=%%i
for /f "delims=" %%i in ('powershell -Command "(Get-TimeZone).BaseUtcOffset.ToString()"') do set UTC_OFFSET=%%i

:: Limpiar el texto para mostrar solo el formato UTC correcto (por ejemplo, "UTC-06:00")
set UTC_OFFSET=%UTC_OFFSET: =%

:: Mostrar la zona horaria con el UTC
echo Zona horaria: !ZONA_HORARIA! !UTC_OFFSET!

:: Obtener la IP local
echo Obteniendo la IP local...
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do set IP_LOCAL=%%i
:: Limpiar espacios alrededor de la IP local
set IP_LOCAL=!IP_LOCAL: =!
echo Tu IP local es: !IP_LOCAL!

:: Obtener la IP pública usando PowerShell (sin mostrar página de código)
echo Obteniendo la IP pública...
for /f "tokens=*" %%i in ('powershell -command "(Invoke-WebRequest -Uri https://ifconfig.me).Content"') do set IP_PUBLICA=%%i
echo Tu IP pública es: !IP_PUBLICA!

:: Obtener el servidor DHCP
echo Servidor DHCP:
for /f "tokens=2 delims=:" %%a in ('ipconfig /all ^| findstr /C:"Servidor DHCP"') do set DHCP_SERVER=%%a
echo !DHCP_SERVER!

:: Mostrar opciones para copiar IPs
:MENU
echo ================================
echo Opciones:
echo 1. Copiar IP Local al portapapeles
echo 2. Copiar IP Pública al portapapeles
echo 3. Ver puertos abiertos
echo 4. Regresar para copiar otra IP
echo 5. Salir
echo ================================
set /p option=Elige una opción (1/2/3/4/5): 

:: Ejecutar según la opción seleccionada
if "%option%"=="1" (
    echo !IP_LOCAL! | clip
    echo La IP local ha sido copiada al portapapeles.
    goto MENU
) else if "%option%"=="2" (
    echo !IP_PUBLICA! | clip
    echo La IP pública ha sido copiada al portapapeles.
    goto MENU
) else if "%option%"=="3" (
    :: Ver puertos abiertos usando netstat
    echo Mostrando puertos abiertos...
    netstat -ano
    echo ================================
    echo Regresando al menú de opciones...
    pause
    goto MENU
) else if "%option%"=="4" (
    goto MENU
) else if "%option%"=="5" (
    echo Saliendo...
    exit
) else (
    echo Opción no válida, saliendo...
    exit
)

