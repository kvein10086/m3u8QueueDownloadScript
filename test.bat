@echo off
REM ===============================
REM N_m3u8DL-RE ��������������ű�ʾ��
REM ˵����
REM   1. �뽫���д����ص� m3u8 ���Ӵ���� tasks.txt �ļ��У�ÿ��һ�����ӡ�
REM   2. �ű���������� N_m3u8DL-RE.exe �������أ����������ļ����浽ָ��Ŀ¼��
REM   3. �����س�������¼�� error.log �С�
REM ===============================

REM �����ӳٱ�����չ
setlocal enabledelayedexpansion

REM ���ò���
set "DOWNLOAD_TOOL=N_m3u8DL-RE.exe"

REM ��ʾ�û���������Ŀ¼�����û�����룬��ʹ��Ĭ�ϵ� Downloads Ŀ¼
set /p "DOWNLOAD_DIR=����������Ŀ¼��Ĭ�ϣ�Downloads����"
if "%DOWNLOAD_DIR%"=="" set "DOWNLOAD_DIR=Downloads"

REM �������Ŀ¼�����ڣ��򴴽�֮
if not exist "%DOWNLOAD_DIR%" (
    mkdir "%DOWNLOAD_DIR%"
)

REM ��������ļ��Ƿ����
if not exist tasks.txt (
    echo δ�ҵ������ļ� tasks.txt���봴�����ļ����������ص� m3u8 ��������д�����С�
    pause
    exit /b 1
)

echo ��ʼ��������...
echo ---------------------------------------

REM ѭ����ȡ tasks.txt��ÿ����Ϊһ�����񣨺��Կ��к��� # ��ͷ��ע���У�
for /f "usebackq delims=" %%A in ("tasks.txt") do (
    set "URL=%%A"
    if not "!URL!"=="" (
        if not "!URL:~0,1!"=="#" (
            echo �������أ�!URL!
            REM ���� N_m3u8DL-RE.exe ���أ�--save-dir ����ָ�����Ŀ¼��
            REM ���������������ڴ���ӣ����� --save-name �Զ����ļ���
            "%DOWNLOAD_TOOL%" "!URL!" --save-dir "%DOWNLOAD_DIR%"
            
            REM �жϷ���ֵ������ 0 ���¼����
            if errorlevel 1 (
                echo ����ʧ�ܣ�!URL!
                echo !URL! >> error.log
            ) else (
                echo ���سɹ���!URL!
            )
            REM ��ѡ����ӵȴ�ʱ�䣬�����������ù���
            timeout /t 2 /nobreak >nul
            echo ---------------------------------------
        )
    )
)
echo ��������ȫ����ɣ�
pause
