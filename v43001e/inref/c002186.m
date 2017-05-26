c002186 ;
	; See C9C12-002186 for details
	; Test that zwrite of globals and locals with fixed length patterns works fine
	; Also test that zsearch of fixed length patterns works in Unix. In VMS, we do not go through the GTM
	;	pattern match engine so the zsearch test below is not necessary (though does not hurt) in VMS.
	;
	; test zwrite
	;
	set (x,y,z,xy,yz,xz,xyz)=1
	set (^x,^y,^z,^xy,^yz,^zx,^xyz)=1
	for str="?1A","?1A1E","?1A.E","^?1A","^?1A1E","^?1A.E"  do
	.	set str1="zwrite "_str
	.	write str1,!
	.	xecute str1
	;
	; test zsearch
	;
	set unix=$ZVersion'["VMS"
	if unix'=0 set extn=".o"
	if unix=0  set extn=".obj"
	write !,$zsearch("c00218?"_extn,1)
	write !,$zsearch("c0021??"_extn,1)
	write !,$zsearch("c002???"_extn,1)
	write !,$zsearch("c00????"_extn,1)
	write !,$zsearch("c0?????"_extn,1)
	write !,$zsearch("c??????"_extn,1)
	write !,$zsearch("?????8?"_extn,1)
	write !,$zsearch("c*"_extn,1)
	write !
	quit
