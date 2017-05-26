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
gtm7509	; primary and secondary can have different sets of triggers and can continue to replicate fine with on-the-fly trigger changes on primary
pritrig	;
	set x=$ztrigger("item","+^SAMPLE(1) -commands=S -xecute=""if $incr(^count)""")
	set x=$ztrigger("item","+^SAMPLE(2) -commands=S -xecute=""if $incr(^count)""")
	set x=$ztrigger("item","+^SAMPLE(3) -commands=S -xecute=""if $incr(^count)""")
	quit

sectrig	;
	set x=$ztrigger("item","+^SAMPLE(-1) -commands=S -xecute=""if $incr(^count)""")
	set x=$ztrigger("item","+^SAMPLE(-2) -commands=S -xecute=""if $incr(^count)""")
	set x=$ztrigger("item","+^SAMPLE(-3) -commands=S -xecute=""if $incr(^count)""")
	quit

updateSAMPLE	;
	for i=-3:1:3  set ^SAMPLE(i)=i
	quit

multiline	;
	set size=$piece($zcmdline," ",1)
	set lines=+$piece($zcmdline," ",2)
	set file="multiline"_size_".trg"
	open file:(newversion:stream:nowrap)
	use file:(nowrap)
	write "+^MULTILINE("_size_","_lines_") -commands=S -xecute=<<",!," write 1,!",!
	for i=1:1:lines do
	. write $j("if $incr(^M)",size),!
	write ">>",!
	close file
	quit

itemmultiline	;
	set i=0
        for ch="",$c(0),$c(10),$c(13),$c(255) do
        . write "# Trying ",$zwrite(ch)," as line terminator in multi-line trigger",!
        . set trigstr="+^a -commands=S -xecute=<<"_$c(10)_" write 1,!"_$c(10)_" write 2,!"_ch
        . write $ztrigger("item",trigstr),!
        . write "# Try $ztrigger(""select"")",!
        . write $ztrigger("select"),!
        . write "# Backup the database, to be used by prior version later",!
	. set i=i+1
        . zsystem "$MUPIP backup DEFAULT mumps"_i_".dat >&! backup"_i_".out"
        . write "# Delete all triggers",!
        . write $ztrigger("item","-*"),!
        . write "-----------------------------------------------------------------------",!
	; $ztrigger("ITEM",<multi-line>) works for a three line multi-line definition and does not core
	; try some valid and invalid multi-line commands
	write "# Test some valid and invalid multi-line commands with $c(10)",!
        set trigstr="+^a21 -commands=S -xecute=<<"_$c(10)_" if ($incr(a)) write a,!"_$c(10)_" write ^a21,!"_$c(10)_">>"_$c(10)
        write $ztrigger("item",trigstr),!
        set trigstr="+^a22 -commands=S -xecute=<<"_$c(10)_" if ($incr(a)) write a,!"_$c(10)_" write ^a2,!"_$c(10)
        write $ztrigger("item",trigstr),!
        set trigstr="+^a3 -commands=S -xecute=<<"_$c(10)_" if ($incr(a)) write a,!"_$c(10)_" write ^a2,!"_$c(10)_$c(10)
        write $ztrigger("item",trigstr),!
        set trigstr="+^a4 -commands=S -xecute=<<"_$c(10)_" write a,!"_$c(10)_" write ^a3,!"_$c(10)_" write ^a2,!"_$c(10)
        write $ztrigger("item",trigstr),!
        set trigstr="+^a5 -commands=S -xecute=<<"_$c(10)_" do trigwork()"_$c(10)_" write 2,!"_$c(10)
        write $ztrigger("item",trigstr),!
        set trigstr="+^a6 -commands=S -xecute=<<"_$c(10)_" w $gtm()"_$c(10)_" write 2,!"_$c(10)
        write $ztrigger("item",trigstr),!
        quit

deletenl	;
	write "# Expect Newline not allowed and not Invalid trigger for both the ztrigger calls below",!
	write $ztrigger("item","-abcd"_$c(10)_$c(10)),!
	write $ztrigger("item","-*"_$c(10)_$c(10)),!
	quit
