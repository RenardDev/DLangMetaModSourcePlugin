
rm -f MMSP_32.o
rm -f MMSP_64.o

dmd -v -w -g -gdwarf=5 -gf -gx -fPIC -shared -m32 -release -lowmem -check=on -checkaction=halt -boundscheck=safeonly -O -inline -mcpu=baseline -allinst -of=MMSP_32.so MMSP.d
dmd -v -w -g -gdwarf=5 -gf -gx -fPIC -shared -m64 -release -lowmem -check=on -checkaction=halt -boundscheck=safeonly -O -inline -mcpu=baseline -allinst -of=MMSP_64.so MMSP.d

rm -f MMSP_32.o
rm -f MMSP_64.o
