c021651	;
	; Test to compare sizes of generated object files.  This is the
	; original file.  c02165_1.m is a shorter version of the same
	; file.  The object files should show the same size relationships.
	set a=1,b=2,c=3,d=4,e=5,f=6,g=7,h=8
	for i=1:1:1000 set m(i)=i*i
	quit
