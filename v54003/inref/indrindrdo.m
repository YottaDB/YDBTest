; GTM-7008 - On V54002B and earlier versions, the indirect do imbedded inside the Xecute calls 
; do_indr_do() to resolve the label to call. The do_indr_do() function uses exfun_frame() to allocate
; the stack frame. The exfun_frame() function copied the existing (indirect) stack frame for the call
; but this did not take into account that it could be called from an indirect frame which has the wrong
; l_symtab, temps, literals, etc. for a non-indirect frame. Verify the fix.
;
	Set x="snarf",y="SNARF"
	Xecute "Do @x Do @y"
	Write "Complete",!
	Quit

snarf
	Write "In snarf",!
	Q

SNARF
	Write "In SNARF",!
	Goto Narf

Narf
	Write "In Narf",!
	Set z=24,zz=42
	Quit
