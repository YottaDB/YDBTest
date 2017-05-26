symblinetest	;
	set cnt=0
	set $etrap="goto etrap"
	do level1
dummy1	; the dummy label here is introduced for a reason.
	; it is to make sure zshow "S" still reports symblinetest+2 instead of dummy1 as the caller of "level1"
	write !,"Done with symblinetest",!
	quit

level1	;
	do level2
	quit

level2	set x=1/0
dummy2	quit  ; dummy2 introduced for a reason. we want $ZSTATUS to show level2+1 as error point (and not dummy2).
etrap	do traplevel1
	quit

traplevel1;
	write "$ZSTATUS=",$ZSTATUS,!!
	write "ZSHOW ""S"" output follows",!
	write "---------------------------",!
	zshow "S"
	set $ecode=""
	quit
