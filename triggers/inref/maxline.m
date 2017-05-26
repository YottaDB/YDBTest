maxline
	do init
	do longline
	do threetwoKshouldfail
	do threetwoK
	do sixfourK
	halt
init
	do initalphanum^maxsubslen
	set allsubs=$$getsubs^maxsubslen(8192)
	set maxdelim=$char(34)_$translate($justify("",1022)," ","x")_$char(34)
	set eightK=$translate($justify("",8180)," ","x")
	set pieceK="" ; generate a 4k string of pieces
	for i=1:1:1040 set $piece(pieceK,";",i)=i
	quit
	
longline
	new i,longline
	; create the long line
	set longline="+^longline("_allsubs_")"
	set longline=longline_" -commands=Set,Kill,ZWithdraw,ZKill"
	set longline=longline_" -name=longlineshave32kilobyteschar"
	set longline=longline_" -xecute=""s S="_$char(34,34)_eightK_$char(34,34)_" """
	set longline=longline_" -options=noisolation,noconsistencycheck"
	set longline=longline_" -delim="_maxdelim
	set longline=longline_" -piece="_pieceK
	write !,"Load a long line of ",$length(longline),!
	do writefile(longline,"maxline.trg")
	set x=$ztrigger("item",longline)
	quit

threetwoK
	new i,longline
	set pieceK=""
	for i=1:1:3264 set $piece(pieceK,";",i)=i
	set longline="+^longline("_allsubs_")"
	set longline=longline_" -commands=Set,Kill,ZWithdraw,ZKill"
	set longline=longline_" -name=LONGLINESHAVE32KILOBYTESCHAR"
	set longline=longline_" -xecute=""s K="_$char(34,34)_eightK_$char(34,34)_" """
	set longline=longline_" -options=noisolation,noconsistencycheck"
	set longline=longline_" -delim="_maxdelim
	set longline=longline_" -piece="_pieceK
	write !,"Load a long line of ",$length(longline),!
	do writefile(longline,"maxline32.trg")
	set x=$ztrigger("item",longline)
	quit

sixfourK
	new i,longline
	set pieceK=""
	for i=1:1:8192 set $piece(pieceK,";",i)=i
	set $piece(allsubs,",",1)=$piece(allsubs,",",1)*10
	set longline="+^longline("_allsubs_")"
	set longline=longline_" -commands=Set,Kill,ZWithdraw,ZKill"
	set longline=longline_" -name=longlineshave64kilobyteschar"
	set longline=longline_" -xecute=""s Z="_$char(34,34)_eightK_$char(34,34)_" """
	set longline=longline_" -options=noisolation,noconsistencycheck"
	set longline=longline_" -delim="_maxdelim
	set longline=longline_" -piece="_pieceK
	write !,"Load a long line of ",$length(longline),!
	do writefile(longline,"maxline64.trg")
	set x=$ztrigger("item",longline)
	quit

threetwoKshouldfail
	new i,longline
	set pieceK=""
	; set $piece(allsubs,",",1)=$piece(allsubs,",",1)*10
	for i=1:1:3264 set $piece(pieceK,";",i)=i
	set longline="+^longline("_allsubs_")"
	set longline=longline_" -commands=Set,Kill,ZWithdraw,ZKill"
	set longline=longline_" -name=longlineshave32kilobyteschar"
	set longline=longline_" -xecute=""s K="_$char(34,34)_eightK_$char(34,34)_" """
	set longline=longline_" -options=noisolation,noconsistencycheck"
	set longline=longline_" -delim="_maxdelim
	set longline=longline_" -piece="_pieceK
	write !,"Load a long line of ",$length(longline)," that collides with the previous name",!
	do writefile(longline,"maxline32fail.trg")
	set x=$ztrigger("item",longline)
	quit

	; write the max line trigger file, not the width and wrap shenanigans
	; they worked fine in M mode, but UTF-8 mode threw a curveball because
	; it always wraps at 32k-1. The code writes out till 32k-2 (aka 1 before
	; the line wrapping point), fiddles with $x and continues writing.
writefile(line,file)
	set unilinewrap=32768-2
	open file:(newversion:nowrap)
	use file:width=65536
	write "; test "_$length(line),!
	if $length(line)<unilinewrap write line,!
	if '($length(line)<unilinewrap) do
	.	write $extract(line,1,unilinewrap)
	.	set $X=0
	.	write $extract(line,unilinewrap+1,$length(line)),!
	close file
	quit

