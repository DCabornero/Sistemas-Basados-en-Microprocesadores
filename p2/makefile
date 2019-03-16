all: pract2.exe pract21.exe
pract2.exe: pract2.obj
	tlink /v pract2
pract2.obj: pract2.asm 
	tasm /zi pract2.asm
pract21.exe: pract21.obj
	tlink /v pract21
pract21.obj: pract21.asm 
	tasm /zi pract21.asm
clean:
	del *.obj
	del *.map
	del *.exe