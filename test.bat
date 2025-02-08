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

REM ����Ĭ������Ŀ¼Ϊ�ű���ǰ·���� Downloads �ļ���
set "DEFAULT_DIR=%~dp0Downloads"

REM ��ʾ�û���������Ŀ¼�����û�����룬��ʹ��Ĭ�ϵ� Downloads Ŀ¼
set /p "DOWNLOAD_DIR=����������Ŀ¼��Ĭ�ϣ�%DEFAULT_DIR%����"
if "%DOWNLOAD_DIR%"=="" set "DOWNLOAD_DIR=%DEFAULT_DIR%"

REM ���Ŀ¼�Ƿ���ڣ���������ڲŴ���Ŀ¼
if not exist "%DOWNLOAD_DIR%" (
    mkdir "%DOWNLOAD_DIR%"
    echo ����Ŀ¼ "%DOWNLOAD_DIR%" �Ѵ�����
) else (
    echo ����Ŀ¼ "%DOWNLOAD_DIR%" �Ѵ��ڣ�������������...
)

REM ��������ļ��Ƿ����
if not exist tasks.txt (
    echo δ�ҵ������ļ� tasks.txt���봴�����ļ����������ص� m3u8 ��������д�����С�
    pause
    exit /b 1
)

REM ��ȡ��������������������������кŵ�λ��
set /a "max_lines=0"
for /f %%A in (tasks.txt) do (
    set /a "max_lines+=1"
)
set /a "max_width=0"
set /a "temp=max_lines"
REM ��������кŵ�λ��
:calculate_width
set /a "temp/=10"
if %temp% gtr 0 (
    set /a "max_width+=1"
    goto calculate_width
)
set /a "max_width+=1"

echo ����кŵ�λ��Ϊ��%max_width%
echo ---------------------------------------

REM ��ʼ���к�
set /a "line=0"

REM ѭ����ȡ tasks.txt��ÿ����Ϊһ�����񣨺��Կ��к��� # ��ͷ��ע���У�
for /f "usebackq delims=" %%A in ("tasks.txt") do (
    set "URL=%%A"
    set /a "line+=1"  REM �����к�

    if not "!URL!"=="" (
        if not "!URL:~0,1!"=="#" (
            REM ��ȡ����ǰ�����֣��������$���ţ�������ʹ���к�
            set "EP_NUMBER="
            for /f "tokens=1 delims=$" %%B in ("!URL!") do (
                REM ����Ƿ���ȡ����$����ǰ������
                set "EP_NUMBER=%%B"
            )

            REM ���EP_NUMBERΪ�գ�˵��û��$���ţ���ʹ���к�
            if "!EP_NUMBER!"=="" (
                set "EP_NUMBER=!line!"
            )

            REM ��ʽ���кţ�ȷ��λ��һ��
            set "FORMATTED_EP_NUMBER="
            call :format_number "!EP_NUMBER!" "!max_width!" "FORMATTED_EP_NUMBER"
            
            REM ��ʾ�û������ļ��������û��������ʹ��Ĭ�ϵ��ļ���
            set /p "CUSTOM_NAME=�������ļ�����Ĭ�ϣ�%DOWNLOAD_DIR%\�ļ�������"
            
            REM ���û�������ļ�����ʹ��Ĭ�ϵ��ļ�����ͨ�� N_m3u8DL-RE.exe �Զ����ɣ�
            if "!CUSTOM_NAME!"=="" (
                set "CUSTOM_NAME=default_filename"
            )

            REM ��� EP ��׺
            set "FINAL_NAME=��!CUSTOM_NAME!��_��EP!FORMATTED_EP_NUMBER!��"

            echo �������أ�!URL! �� !FINAL_NAME!
            REM ���� N_m3u8DL-RE.exe ���أ�--save-dir ����ָ�����Ŀ¼��--save-name ����ָ���ļ���
            "%DOWNLOAD_TOOL%" "!URL!" --save-dir "%DOWNLOAD_DIR%" --save-name "!FINAL_NAME!"
            
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

REM ��ʽ�����֣�ȷ��λ��һ��
:format_number
setlocal
set "num=%1"
set "width=%2"
set "result="
for /l %%i in (1,1,%width%) do (
    set "result=0!result!"
)
set "result=!result!!num!"
set "result=!result:~-!width!!"
endlocal & set "%3=!result!"
exit /b
