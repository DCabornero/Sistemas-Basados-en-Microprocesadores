all: p4a.com p4b.exe p4c.exe
p4a.com: p4a.obj
	tlink /t p4a
p4a.obj: p4a.asm
	tasm /zi /ml p4a,,p4a
p4b.exe: p4b.obj
	tlink /v p4b
p4b.obj: p4b.asm
	tasm /zi /ml p4b,,p4b
p4c.exe: p4c.obj
	tlink /v p4c
p4c.obj: p4c.asm
	tasm /zi /ml p4c,,p4c
clean:
	del *.com
	del *.obj
	del *.exe
	del *.lst
	del *.map