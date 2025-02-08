@echo off
REM ===============================
REM N_m3u8DL-RE 队列下载批处理脚本示例
REM 说明：
REM   1. 请将所有待下载的 m3u8 链接存放在 tasks.txt 文件中，每行一个链接。
REM   2. 脚本会逐个调用 N_m3u8DL-RE.exe 进行下载，并将下载文件保存到指定目录。
REM   3. 如下载出错，则会记录到 error.log 中。
REM ===============================

REM 启用延迟变量扩展
setlocal enabledelayedexpansion

REM 配置部分
set "DOWNLOAD_TOOL=N_m3u8DL-RE.exe"

REM 提示用户输入下载目录，如果没有输入，则使用默认的 Downloads 目录
set /p "DOWNLOAD_DIR=请输入下载目录（默认：Downloads）："
if "%DOWNLOAD_DIR%"=="" set "DOWNLOAD_DIR=Downloads"

REM 如果保存目录不存在，则创建之
if not exist "%DOWNLOAD_DIR%" (
    mkdir "%DOWNLOAD_DIR%"
)

REM 检查任务文件是否存在
if not exist tasks.txt (
    echo 未找到任务文件 tasks.txt，请创建此文件并将待下载的 m3u8 链接逐行写入其中。
    pause
    exit /b 1
)

echo 开始队列下载...
echo ---------------------------------------

REM 循环读取 tasks.txt，每行作为一个任务（忽略空行和以 # 开头的注释行）
for /f "usebackq delims=" %%A in ("tasks.txt") do (
    set "URL=%%A"
    if not "!URL!"=="" (
        if not "!URL:~0,1!"=="#" (
            REM 提示用户输入文件名，如果没有输入则使用默认的文件名
            set /p "CUSTOM_NAME=请输入文件名（默认：%DOWNLOAD_DIR%\文件名）："
            
            REM 如果没有输入文件名，使用默认的文件名（通过 N_m3u8DL-RE.exe 自动生成）
            if "!CUSTOM_NAME!"=="" (
                set "CUSTOM_NAME=default_filename"
            )

            echo 正在下载：!URL! 到 !CUSTOM_NAME!
            REM 调用 N_m3u8DL-RE.exe 下载，--save-dir 参数指定输出目录，--save-name 参数指定文件名
            "%DOWNLOAD_TOOL%" "!URL!" --save-dir "%DOWNLOAD_DIR%" --save-name "!CUSTOM_NAME!"
            
            REM 判断返回值，若非 0 则记录错误
            if errorlevel 1 (
                echo 下载失败：!URL!
                echo !URL! >> error.log
            ) else (
                echo 下载成功：!URL!
            )
            REM 可选择添加等待时间，避免连续调用过快
            timeout /t 2 /nobreak >nul
            echo ---------------------------------------
        )
    )
)
echo 队列下载全部完成！
pause
