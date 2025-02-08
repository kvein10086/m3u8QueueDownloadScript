@echo off
REM ===============================
REM N_m3u8DL-RE 队列下载批处理脚本
REM 说明：
REM   1. 将m3u8链接存放在tasks.txt中，每行格式：[EP编号$]URL
REM      示例：101$http://example.com/playlist.m3u8
REM      若省略EP编号，则自动使用行号。
REM   2. 下载文件将保存为【基本名称_EPxxx】格式。
REM   3. 错误链接记录到error.log。
REM ===============================

setlocal enabledelayedexpansion

REM 配置工具和默认路径
set "DOWNLOAD_TOOL=N_m3u8DL-RE.exe"
set "DEFAULT_DIR=%~dp0Downloads"

REM 用户输入下载目录
set /p "DOWNLOAD_DIR=下载目录（默认：%DEFAULT_DIR%）："
if "%DOWNLOAD_DIR%"=="" set "DOWNLOAD_DIR=%DEFAULT_DIR%"

REM 创建下载目录
if not exist "%DOWNLOAD_DIR%" (
    mkdir "%DOWNLOAD_DIR%"
    echo 创建目录: "%DOWNLOAD_DIR%"
)

REM 检查任务文件
if not exist tasks.txt (
    echo 错误: 未找到tasks.txt
    pause
    exit /b 1
)

REM 获取基本文件名
set /p "BASE_NAME=输入文件基本名称（如：我的视频）："
if "%BASE_NAME%"=="" set "BASE_NAME=视频"

REM 统计任务数和计算序号位数
set /a "total=0"
for /f "usebackq delims=" %%A in ("tasks.txt") do set /a "total+=1"
set /a "width=1", "temp=total"
:calc_width
set /a "temp/=10"
if %temp% gtr 0 (set /a "width+=1" & goto calc_width)

echo 共%total%个任务，序号位数：%width%
echo ========================================

set /a "line=0"
for /f "usebackq delims=" %%A in ("tasks.txt") do (
    set "url_line=%%A"
    set /a "line+=1"

    if not "!url_line!"=="" if not "!url_line:~0,1!"=="#" (
        REM 解析EP编号和URL
        set "ep=!line!"
        for /f "tokens=1* delims=$" %%B in ("!url_line!") do (
            set "ep=%%B"
            set "url=%%C"
        )
        if "!url!"=="" set "url=!url_line!"

        REM 格式化EP序号
        set "formatted_ep=00000!ep!"
        set "formatted_ep=!formatted_ep:~-%width%!"

        REM 生成文件名并下载
        set "filename=【!BASE_NAME!】_【EP!formatted_ep!】"
        echo 正在下载 [!line!/%total%] !filename!
        "%DOWNLOAD_TOOL%" "!url!" --save-dir "%DOWNLOAD_DIR%" --save-name "!filename!"

        if errorlevel 1 (
            echo [失败] !url!
            echo !url! >> error.log
        ) else (
            echo [成功] !filename!
        )
        timeout /t 2 >nul
        echo ---------------------------------------
    )
)

echo 全部任务完成！
pause