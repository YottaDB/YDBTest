	; VMS GT.M versions prior to V54001 and Unix versions prior to V52000
	; don't support $zlength. Use $$^zlenproxy to avoid FNOTONSYS or
	; INVFCN messages.
	;
	; C9K04-003264 added support for $zlength on VMS in V5.4-0001
	; C9911-001317 added support for $zlength on Unix in V5.2-0000
	;
dzlength(string,delim)
	quit:'$data(delim) $zlength(string)
	quit $zlength(string,delim)
