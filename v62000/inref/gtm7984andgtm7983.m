;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pipe;
        set dev="gtmProc"
	for devparm1="",":fixed",":variable",":stream" do
	. for devparm2="",":wrap",":nowrap" do
	. . write !
	. . set openstr="open dev:(command=""ps -ef|grep mumps"":readonly"_devparm1_devparm2_":exception=""goto done"")::""PIPE"""
	. . write "Open command ----> ",openstr,!
	. . xecute openstr
	. . kill x zshow "d":x  write "ZSHOW D output --> ",x("D",3),!
	. . close dev
        quit

done	;
	quit

shrink(file,sep)
	;
	; note for future : this can be integrated into test/com/shrinkfil.m as it provides the ability to
	; 	shrink the output containing repeated occurrences of a single-character separator with a run-length encoding.
	;	i.e. aaaaa is replaced as <5a> where sep="a". file is the file containing list of lines that need to be shrinked.
	;
	if $zlength(sep)'=1 write "SHRINK-E-CANNOTPROCEED",!  halt
	new line,dollarx,shortline
	new len,i,nlines,j,seplen,state
	open file:(readonly:recordsize=1048576:stream)
	use file:nowrap
	for i=1:1 read line(i) set dollarx(i)=$x  quit:$zeof
	close file
	use $p
	set nlines=i,shortline="",seplen=0,state=0
	for j=1:1:nlines  do
	. set line=line(j)
	. set len=$zlength(line)
	. for i=1:1 quit:i>len  do
	. . set ch=$zextract(line,i)
	. . if (state=0) do
	. . . if ch=sep set state=1,seplen=1
	. . . else      set state=2,seplen=1
	. . else  if (state=1) do
	. . . if ch=sep if $incr(seplen)
	. . . else      do addshortline(.shortline,seplen,sep) set state=2,seplen=1
	. . else  if (state=2) do
	. . . if ch=sep set state=1,shortline=shortline_$ze(line,i-seplen,i-1),seplen=1
	. . . else      if $incr(seplen)
	. if (state=2) do
	. . set shortline=shortline_$ze(line,i-seplen,i-1),seplen=0
	. . if (dollarx(j)=0) if $zl(shortline) write shortline,! set shortline="",seplen=0
	. if (state=1)&(dollarx(j)=0) do
	. . do addshortline(.shortline,seplen,sep) if $zl(shortline) write shortline,! set shortline="",seplen=0
	quit

addshortline(shortline,seplen,sep)
	if seplen>10 set shortline=shortline_"<"_seplen_sep_">"
	else      set shortline=shortline_$tr($j(sep,seplen)," ",sep)
	quit
