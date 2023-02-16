@echo off

if exist MMSP_32.dll del MMSP_32.dll
if exist MMSP_32.exp del MMSP_32.exp
if exist MMSP_32.lib del MMSP_32.lib
if exist MMSP_32.obj del MMSP_32.obj

if exist MMSP_64.dll del MMSP_64.dll
if exist MMSP_64.exp del MMSP_64.exp
if exist MMSP_64.lib del MMSP_64.lib
if exist MMSP_64.obj del MMSP_64.obj

dmd -v -w -g -gf -gx -shared -m32 -release -lowmem -check=on -checkaction=halt -boundscheck=safeonly -O -inline -mcpu=baseline -L="/DYNAMICBASE" -L="/SUBSYSTEM:WINDOWS" -L="/NXCOMPAT" -L="/CETCOMPAT" -L="/OPT:REF" -L="/RELEASE" -allinst -of=MMSP_32.dll MMSP.d
dmd -v -w -g -gf -gx -shared -m64 -release -lowmem -check=on -checkaction=halt -boundscheck=safeonly -O -inline -mcpu=baseline -L="/DYNAMICBASE" -L="/SUBSYSTEM:WINDOWS" -L="/NXCOMPAT" -L="/CETCOMPAT" -L="/OPT:REF" -L="/RELEASE" -allinst -of=MMSP_64.dll MMSP.d

if exist MMSP_32.exp del MMSP_32.exp
if exist MMSP_32.lib del MMSP_32.lib
if exist MMSP_32.obj del MMSP_32.obj

if exist MMSP_64.exp del MMSP_64.exp
if exist MMSP_64.lib del MMSP_64.lib
if exist MMSP_64.obj del MMSP_64.obj

dir MMSP_*.*

pause
