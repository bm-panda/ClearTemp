@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

:: ---- UTF-8 编码兼容性设置 ----
ver | find "10.0." >nul && (
    for /f "tokens=3 delims=." %%a in ('ver') do set "build=%%a"
) || set "build=0"
if !build! geq 18362 ( chcp 65001 >nul ) else ( chcp 936 >nul )

title 系统临时文件清理工具

:: ---- 检测运行模式（有参 = 盒子静默执行，无参 = 手动交互）----
set "BOX_MODE="
if not "%~1"=="" set "BOX_MODE=true"

:: ---- 管理员权限检查 ----
set "BatchPath=%~f0"
fsutil dirty query %systemdrive% >nul 2>&1
if errorlevel 1 (
    if defined BOX_MODE (
        echo [ERROR] 需要管理员权限
        exit /b 1
    )
    echo 正在请求管理员权限...
    powershell -Command "Start-Process 'cmd' -ArgumentList '/c \"%BatchPath%\" %*' -Verb RunAs"
    exit /b
)

:: ---- 执行清理 ----
call :CleanFolder "%TEMP%" "当前用户临时文件夹"
call :CleanFolder "C:\Windows\Temp" "系统级临时文件夹"
call :CleanFolder "C:\Windows\Prefetch" "预读取缓存"

if not defined BOX_MODE (
    echo.
    echo ========================================
    echo 全部清理完成！
    echo ========================================
    echo.
    echo 程序将在 5 秒后自动退出...
    timeout /t 5 >nul
)
exit /b 0

:CleanFolder
set "TargetPath=%~1"
set "DisplayName=%~2"

if not defined BOX_MODE (
    echo.
    echo [%DisplayName%]
    echo 路径: !TargetPath!
)

if not exist "!TargetPath!" (
    if not defined BOX_MODE echo !DisplayName! -- 路径不存在，跳过
    exit /b 0
)

del /f /s /q "!TargetPath!\*" >nul 2>&1

if /i not "!TargetPath!"=="C:\Windows\Prefetch" (
    rmdir /s /q "!TargetPath!" >nul 2>&1
    mkdir "!TargetPath!" >nul 2>&1
)

if not defined BOX_MODE (
    echo !DisplayName! -- 清理完成
) else (
    echo [OK] !DisplayName! 清理完成
)
exit /b 0
