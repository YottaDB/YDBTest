	; Testing the location where ZEDIT creates a new file if the file does not exist in $ZRO
	; Test passes if ZEDIT creates the new file in first source directory in $ZRO
	;      fails if ZEDIT creates the file in the current directory.

zed	;
	s firstsrc=$ztrnlnm("inrefdir")		; inref directory
	s $zro=$zdir_"("_firstsrc_") "_$zro

	w "First source in $ZRO = ",firstsrc,!
	zed "nofile.m"	; a file that does not exist
	q
