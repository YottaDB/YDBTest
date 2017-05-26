per3043	; ; ; NCS problem with timeout on terminal response to attached printer ready
	;
	n
	s %IO=$i,X="" u %IO:escape w $c(27)_"[?15n"
	r *X:10 s Y=$t,Z=$zb u %IO:noescape
	w !,"X=" f %X=1:1:$L(X) w !,$e(X,%X),?5,$a(X,%X)
	w !,"$T=",Y
	w !,"$ZB=" f %X=1:1:$L(Z) w ! w:$e(Z,%X)'?1c $e(Z,%X) w ?5,$a(Z,%X)
	s z=$p(Z,"?",2)
	i z="10n" w !,"Terminal printer is ready"
	e  i z="11n" w !,"Terminal printer is not ready"
	e  i z="13n" w !,"There is no terminal printer"
	e  w !,"Timeout or unrecognized response from terminal"
	q
