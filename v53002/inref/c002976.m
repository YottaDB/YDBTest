c002976	; see comment in d002676.m (caller) for details
M11; No parameters passed
 set $ztrap=""
 Write !,$Text(pass)
x Do pass	; The FMLLSTPRESENT was fixed as part of C9I04-002976
 Quit
pass(a,b,c) ; This entry must be called with parameters
 Quit
