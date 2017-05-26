;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2009, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
blkfiforead
	set ftest="test1.fifo"
	open ftest:(fifo:readonly)
	use ftest:exception="G EOF"
	; the format being read into x is <line>:<data> so the $piece below gets the line number being read from
	; the fifo.  If ^ztrapfifo is 0 and it is line 1000 then loop for up to 10 sec waiting for it to be non-zero.
	for  read x do
	. u $p write x,!
	. if (0=^ztrapfifo)&(1000=$piece(x,":",1)) do
	.. ; wait up to 10 sec for the writer to block
	.. for i=1:1:10 quit:^ztrapfifo  hang 1
	.. if (0=^ztrapfifo) use $p write "^ztrapfifo is still 0 at "_$ZPOS,!
	. use ftest
EOF
	if (0=^ztrapfifo) use $p write "^ztrapfifo is still 0 at "_$ZPOS,!
	if $zstatus'["IOEOF" use $p write $zstatus,!
	quit
