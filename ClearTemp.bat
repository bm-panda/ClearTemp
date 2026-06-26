@echo off
chcp 65001 >nul 2>nul
title 系统临时文件清理工具

:: 获取当前脚本的完整路径
set "BatchPath=%~f0"

:: 尝试在系统目录创建文件来检测是否拥有管理员权限
fsutil dirty query %systemdrive% >nul 2>nul

:: 如果错误级别为1（即没有权限），则重新以管理员身份运行自己
if %errorlevel% equ 1 (
    echo 正在请求管理员权限...
    powershell -Command "Start-Process 'cmd' -ArgumentList '/c %BatchPath% %*' -Verb RunAs"
    exit /b
)

:: 以下代码仅在拥有管理员权限时执行
echo ========================================
echo     系统临时文件清理工具 v2.0
echo ========================================
echo.
echo [1/3] 正在清理当前用户临时文件夹...
echo 路径: %temp%
del /f /s /q "%temp%\*" 2>nul
rmdir /s /q "%temp%" 2>nul
mkdir "%temp%" 2>nul
echo ✓ 当前用户临时文件夹清理完成
echo.

echo [2/3] 正在清理系统级临时文件夹...
echo 路径: C:\Windows\Temp
del /f /s /q "C:\Windows\Temp\*" 2>nul
rmdir /s /q "C:\Windows\Temp" 2>nul
mkdir "C:\Windows\Temp" 2>nul
echo ✓ 系统级临时文件夹清理完成
echo.

echo [3/3] 正在清理预读取缓存...
echo 路径: C:\Windows\Prefetch
del /f /q "C:\Windows\Prefetch\*" 2>nul
echo ✓ 预读取缓存清理完成
echo.

echo ========================================
echo 全部清理完成！
echo ========================================
pause