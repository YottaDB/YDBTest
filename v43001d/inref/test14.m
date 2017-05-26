test14	;
	; Test that ecodes are appended to $ECODE as they happen rather than being prepended
	;
x	;
	set $etrap="do ecprint"
	do y
	quit
y	;
	new $etrap
	set $etrap="do etr1"
	do z
	quit
z	;
	new $etrap
	set $etrap="do etr2"
	write 1/0
	quit
etr1	;
	do ecprint
	quit 1
	quit
etr2	;
	do ecprint
	w $r(-1)
	quit
ecprint	;
	w "$ecode = ",$ecode,!
	quit
