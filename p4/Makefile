all: p4a.com
p4a.com: p4a.obj
	tlink /t p4a
p4a.obj: p4a.asm
	tasm /zi /ml p4a,,p4a
clean:
	del *.com
	del *.obj
	del *.exe
	del *.lst
	