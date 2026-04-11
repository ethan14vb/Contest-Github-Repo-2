@ECHO OFF
rem File: asm_CSE3120.bat
rem Author: Marius Silaghi, 2023
SET IRVINE=C:\Irvine
SET FILEBASE=%~n1
echo Handling Source: %FILEBASE%
setlocal

rem You may use quotes for the whole parameter
set "PATH=C:\Program Files (x86);...;%PATH%"

rem Or you should use quotes only for special
rem characters. Avoid final undesired spaces...
set PATH=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin;C:\Program Files (x86)\Windows Kits\8.1\bin\x86;;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.6.1 Tools;C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\tools;C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\ide;C:\Program Files (x86)\HTML Help Workshop;;C:\Program Files (x86)\MSBuild\14.0\bin\;C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\;C:\WINDOWS\SysWow64;;C:\Program Files\Common Files\Oracle\Java\javapath;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files\Git\cmd;C:\Program Files\CMake\bin;C:\Program Files (x86)\Windows Kits\8.1\Windows Performance Toolkit\;C:\Users\Ethan\AppData\Local\Microsoft\WindowsApps;C:\Users\Ethan\AppData\Local\Programs\Microsoft VS Code\bin;C:\Users\Ethan\AppData\Local\GitHubDesktop\bin;;


set LIB=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\lib;;C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\atlmfc\lib;;C:\Program Files (x86)\Windows Kits\10\lib\10.0.10240.0\ucrt\x86;;;C:\Program Files (x86)\Windows Kits\8.1\lib\winv6.3\um\x86;;C:\Program Files (x86)\Windows Kits\NETFXSDK\4.6.1\Lib\um\x86


set LIBPATH=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\atlmfc\lib;;C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\lib;

set INCLUDE=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\include;;C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\atlmfc\include;;C:\Program Files (x86)\Windows Kits\10\Include\10.0.10240.0\ucrt;;;C:\Program Files (x86)\Windows Kits\8.1\Include\um;C:\Program Files (x86)\Windows Kits\8.1\Include\shared;C:\Program Files (x86)\Windows Kits\8.1\Include\winrt;;

rem EXTERNAL_INCLUDE=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\include;;C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\atlmfc\include;;C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\VS\include;;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\ucrt;;;C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\VS\UnitTest\include;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\um;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\shared;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\winrt;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\cppwinrt;C:\Program Files (x86)\Windows Kits\NETFXSDK\4.8\Include\um;


rem ml.exe /c /nologo /Sg /Zi /Fo"%FILEBASE%.obj"\
rem /Fl"%FILEBASE%.lst" /I "%IRVINE%" /W3 \
rem /errorReport:prompt /Ta%FILEBASE%.asm


FOR %%F IN (%*) DO (
echo Handling %%~nF
ml.exe /c /nologo /Sg /Zi /Fo"%%~nF.obj" /Fl"%%~nF.lst" /I "%IRVINE%" /W3 /errorReport:prompt /Ta%%~nF.asm
)

link.exe /ERRORREPORT:PROMPT /OUT:"%FILEBASE%.exe" /NOLOGO /LIBPATH:%IRVINE% user32.lib irvine32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /MANIFEST /MANIFESTUAC:"level='asInvoker' uiAccess='false'" /manifest:embed /DEBUG /SUBSYSTEM:CONSOLE /TLBID:1 /DYNAMICBASE:NO /MACHINE:X86 /SAFESEH:NO %FILEBASE%.obj

endlocal

