@echo off
REM ===============================
REM N_m3u8DL-RE ��������������ű�
REM ˵����
REM   1. ��m3u8���Ӵ����tasks.txt�У�ÿ�и�ʽ��[EP���$]URL
REM      ʾ����101$http://example.com/playlist.m3u8
REM      ��ʡ��EP��ţ����Զ�ʹ���кš�
REM   2. �����ļ�������Ϊ����������_EPxxx����ʽ��
REM   3. �������Ӽ�¼��error.log��
REM ===============================

setlocal enabledelayedexpansion

REM ���ù��ߺ�Ĭ��·��
set "DOWNLOAD_TOOL=N_m3u8DL-RE.exe"
set "DEFAULT_DIR=%~dp0Downloads"

REM �û���������Ŀ¼
set /p "DOWNLOAD_DIR=����Ŀ¼��Ĭ�ϣ�%DEFAULT_DIR%����"
if "%DOWNLOAD_DIR%"=="" set "DOWNLOAD_DIR=%DEFAULT_DIR%"

REM ��������Ŀ¼
if not exist "%DOWNLOAD_DIR%" (
    mkdir "%DOWNLOAD_DIR%"
    echo ����Ŀ¼: "%DOWNLOAD_DIR%"
)

REM ��������ļ�
if not exist tasks.txt (
    echo ����: δ�ҵ�tasks.txt
    pause
    exit /b 1
)

REM ��ȡ�����ļ���
set /p "BASE_NAME=�����ļ��������ƣ��磺�ҵ���Ƶ����"
if "%BASE_NAME%"=="" set "BASE_NAME=��Ƶ"

REM ͳ���������ͼ������λ��
set /a "total=0"
for /f "usebackq delims=" %%A in ("tasks.txt") do set /a "total+=1"
set /a "width=1", "temp=total"
:calc_width
set /a "temp/=10"
if %temp% gtr 0 (set /a "width+=1" & goto calc_width)

echo ��%total%���������λ����%width%
echo ========================================

set /a "line=0"
for /f "usebackq delims=" %%A in ("tasks.txt") do (
    set "url_line=%%A"
    set /a "line+=1"

    if not "!url_line!"=="" if not "!url_line:~0,1!"=="#" (
        REM ����EP��ź�URL
        set "ep=!line!"
        for /f "tokens=1* delims=$" %%B in ("!url_line!") do (
            set "ep=%%B"
            set "url=%%C"
        )
        if "!url!"=="" set "url=!url_line!"

        REM ��ʽ��EP���
        set "formatted_ep=00000!ep!"
        set "formatted_ep=!formatted_ep:~-%width%!"

        REM �����ļ���������
        set "filename=��!BASE_NAME!��_��EP!formatted_ep!��"
        echo �������� [!line!/%total%] !filename!
        "%DOWNLOAD_TOOL%" "!url!" --save-dir "%DOWNLOAD_DIR%" --save-name "!filename!"

        if errorlevel 1 (
            echo [ʧ��] !url!
            echo !url! >> error.log
        ) else (
            echo [�ɹ�] !filename!
        )
        timeout /t 2 >nul
        echo ---------------------------------------
    )
)

echo ȫ��������ɣ�
pause