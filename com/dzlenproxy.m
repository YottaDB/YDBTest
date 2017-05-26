	; VMS GT.M versions prior to V54001 and Unix versions prior to V52000
	; don't support $zlength. Use this routine to avoid FNOTONSYS or INVFCN
	; messages.
	;
	; C9K04-003264 added support for $zlength on VMS in V5.4-0001
	; C9911-001317 added support for $zlength on Unix in V5.2-0000
	;
dzlenproxy(string,delim)
	new VMS,version,usezlength
	set VMS=$zversion["VMS"
	set version=+$tr($piece($zversion," ",2),"V-","")
	set usezlength=$select((VMS)&(version<5.5):0,version<5.2:0,1:1)
	if usezlength quit:($data(delim)=0) $$^dzlength(string)
	if usezlength quit $$^dzlength(string,delim)
	quit:($data(delim)=0) $length(string)
	quit $length(string,delim)


