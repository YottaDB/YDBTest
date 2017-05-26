label	;
	; checks no labels and variable global var in <expr> (of VIEW "TRACE":0:<expr>)
	w !,"Testing routine calls without labels, and variable in TRACE:0:var ...",!
	VIEW "TRACE":1:"^TRACEN"
	d ^dummy
	VIEW "TRACE":0:"^TRACEN"
	;zwr ^TRACEN
	; with $j
	VIEW "TRACE":1:"^TRACE(""ZMPROF4"")"
	d ^dummy
	VIEW "TRACE":0:"^TRACE(""ZMPROF4"")"
	;zwr ^TRACE("ZMPROF4",*)
	; with variable??
	s var="^TRACE(""NAME"")"
mylbl	VIEW "TRACE":1:var
	d ^dummy
	VIEW "TRACE":0:var
	;zwr ^TRACE("NAME",*)
	VIEW "TRACE":1:"^TRACE(""ZMPROF10"")"
	d ^yeslbl
	d ^nolbl
	VIEW "TRACE":0:"^TRACE(""ZMPROF10"")"
	q
