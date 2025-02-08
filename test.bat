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

REM 设置默认下载目录为脚本当前路径的 Downloads 文件夹
set "DEFAULT_DIR=%~dp0Downloads"

REM 提示用户输入下载目录，如果没有输入，则使用默认的 Downloads 目录
set /p "DOWNLOAD_DIR=请输入下载目录（默认：%DEFAULT_DIR%）："
if "%DOWNLOAD_DIR%"=="" set "DOWNLOAD_DIR=%DEFAULT_DIR%"

REM 检查目录是否存在，如果不存在才创建目录
if not exist "%DOWNLOAD_DIR%" (
    mkdir "%DOWNLOAD_DIR%"
    echo 下载目录 "%DOWNLOAD_DIR%" 已创建。
) else (
    echo 下载目录 "%DOWNLOAD_DIR%" 已存在，继续下载任务...
)

REM 检查任务文件是否存在
if not exist tasks.txt (
    echo 未找到任务文件 tasks.txt，请创建此文件并将待下载的 m3u8 链接逐行写入其中。
    pause
    exit /b 1
)

REM 获取总行数（任务数）并计算最大行号的位数
set /a "max_lines=0"
for /f %%A in (tasks.txt) do (
    set /a "max_lines+=1"
)
set /a "max_width=0"
set /a "temp=max_lines"
REM 计算最大行号的位数
:calculate_width
set /a "temp/=10"
if %temp% gtr 0 (
    set /a "max_width+=1"
    goto calculate_width
)
set /a "max_width+=1"

echo 最大行号的位数为：%max_width%
echo ---------------------------------------

REM 初始化行号
set /a "line=0"

REM 循环读取 tasks.txt，每行作为一个任务（忽略空行和以 # 开头的注释行）
for /f "usebackq delims=" %%A in ("tasks.txt") do (
    set "URL=%%A"
    set /a "line+=1"  REM 增加行号

    if not "!URL!"=="" (
        if not "!URL:~0,1!"=="#" (
            REM 提取链接前的数字（如果存在$符号），否则使用行号
            set "EP_NUMBER="
            for /f "tokens=1 delims=$" %%B in ("!URL!") do (
                REM 检查是否提取到了$符号前的数字
                set "EP_NUMBER=%%B"
            )

            REM 如果EP_NUMBER为空，说明没有$符号，则使用行号
            if "!EP_NUMBER!"=="" (
                set "EP_NUMBER=!line!"
            )

            REM 格式化行号，确保位数一致
            set "FORMATTED_EP_NUMBER="
            call :format_number "!EP_NUMBER!" "!max_width!" "FORMATTED_EP_NUMBER"
            
            REM 提示用户输入文件名，如果没有输入则使用默认的文件名
            set /p "CUSTOM_NAME=请输入文件名（默认：%DOWNLOAD_DIR%\文件名）："
            
            REM 如果没有输入文件名，使用默认的文件名（通过 N_m3u8DL-RE.exe 自动生成）
            if "!CUSTOM_NAME!"=="" (
                set "CUSTOM_NAME=default_filename"
            )

            REM 添加 EP 后缀
            set "FINAL_NAME=【!CUSTOM_NAME!】_【EP!FORMATTED_EP_NUMBER!】"

            echo 正在下载：!URL! 到 !FINAL_NAME!
            REM 调用 N_m3u8DL-RE.exe 下载，--save-dir 参数指定输出目录，--save-name 参数指定文件名
            "%DOWNLOAD_TOOL%" "!URL!" --save-dir "%DOWNLOAD_DIR%" --save-name "!FINAL_NAME!"
            
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

REM 格式化数字，确保位数一致
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
