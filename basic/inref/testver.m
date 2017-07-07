testver	;
	;
	; Construct version from $ZVERSION & $ZYRELEASE
	;
	set zv=$translate($piece($zversion," ",2),".-")
	set zyre=$translate($piece($zyrelease," ",2),".-")
	set testver=$zconvert(zv_"_"_zyre,"U")
	set gtmverno=$ztrnlnm("gtm_verno")
	if testver=gtmverno write "Passed the version test",!
	else                write "Should be ",gtmverno," but is ",testver,!
	quit
