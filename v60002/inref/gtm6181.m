;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2013-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm6181
	set $etrap="goto error^gtm6181"
	set showcmdstr="$LKE show -lock="
	set postfix=" |& $tst_awk '""'""'/Owned/ {gsub(/PID= [0-9]*/,""PIDVAL"",$0); print }'""'""'"
	lock n("x"_$c(0))
	lock +n($c(0)_"x")
	lock +n("x"_$c(0)_"y")
	lock +n($c(0,1)_"x"_$c(1,0)_"y")
	if ("UTF-8"=$zch) lock +n("x"_$zchar(228,2,4,184,187))
	lock +n("x_y")
	lock +n("""")
	lock +n("x""y")
	lock +n("x,y")
	write !,"-----------------------------",!
	write "***BEGIN List of all locks***"
	write !,"-----------------------------",!
	zsystem "$LKE show | & $tst_awk '""'""'$0 !~ /LOCKSPACEUSE/ {gsub(/PID= [0-9]*/,""PIDVAL"",$0); print }'""'""'"
	write !,"-----------------------------",!
	write "***END List of all locks***"
	write !,"-----------------------------",!
	do runlke("\""n\(\""\""x\""\""_\$c\(0\)\)\""",1)
	do runlke("\""n\(\""\""x\""\""_\$ch\(0\)\)\""",1)
	do runlke("\""n\(\""\""x\""\""_\$chA\(0\)\)\""",1)
	do runlke("\""n\(\""\""x\""\""_\$char\(0\)\)\""",1)
	if ("UTF-8"=$zch) do
	.  do runlke("\""n\(\""\""x\""\""_\$zchar\(228\)_\$c\(2,4\)_\$zchar\(184,187\)\)\""",1)
	do runlke("\""n\(\$c\(0\)_\""\""x\""\""\)\""",1)
	do runlke("\""n\(\""\""x\""\""_\$c\(0\)_\""\""y\""\""\)\""",1)
	do runlke("\""n\(\$c\(0,1\)_\""\""x\""\""_\$C\(1,0\)_\""\""y\""\""\)\""",1)
	do runlke("\""n\(\""\""x_y\""\""\)\""",1)
	do runlke("\""n\(\""\""\""\""\""\""\""\""\)\""",1)
	do runlke("\""n\(\""\""x\""\""\""\""y\""\""\)\""",1)
	do runlke("\""n\(\""\""x\""\""_\$CHARNONSENSE\(0\)\)\""",0)
	do runlke("\""n\(\)\""",0)
	do runlke("\""n\(\""\""x\""\"",\)\""",0)
	do runlke("\""n\(\""\""x\""\""_\)\""",0)
	quit

runlke(str,isvalid)
	write !,"-----------------------------",!
	write $select(isvalid:"Valid",1:"Invalid")_" search string:",!,str,!
	write "After shell evaluation:"
	zsystem "echo "_str
	zsystem showcmdstr_str_postfix
	quit
error
	zshow "*"
	quit
