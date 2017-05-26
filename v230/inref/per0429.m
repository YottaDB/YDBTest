per0429	;per0429 s x=$p(@$p("a","/"),"/") ACCVIOs
	;
	k a       ; Guarantees that a is undefined.
	s c=0
	s zt=$zt,$zt="s next=$zpos,$p(next,""+"",2)=$p(next,""+"",2)+1 w !,$zs g @next"
	s x=$e(@$e("a")) s c=c+1 w !,"$e did not detect UNDEF"
	s x=$e(@$e("a")) s c=c+1 w !,"$e did not detect UNDEF"
	s x=$p(@$p("a","/"),"/") s c=c+1 w !,"$p did not detect UNDEF"
	s x=$p(@$p("a","/"),"/") s c=c+1 w !,"$p did not detect UNDEF"
	s $zt=zt
	w !,$s(c:"BAD result",1:"OK")," from test of retry of @$p"
