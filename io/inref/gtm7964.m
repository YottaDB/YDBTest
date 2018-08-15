;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2014 Fidelity Information Services, Inc		;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7964
	; exercise various pipe device open's with parse device parameter
	new x,a
	write !,"Testing various pipe open's with parse device parameter and PATH defined",!!
	set $ztrap="goto errorAndCont^errorAndCont"
	set a="PP"
	write "open a:(comm=""$/mupip integ -file mumps.dat"":parse)::""pipe""",!
	open a:(comm="$/mupip integ -file mumps.dat":parse)::"pipe"
	write "open a:(comm=""$$/mupip integ -file mumps.dat"":parse)::""pipe""",!
	open a:(comm="$$/mupip integ -file mumps.dat":parse)::"pipe"
	write "open a:(comm=""$ integ -file mumps.dat"":parse)::""pipe""",!
	open a:(comm="$ integ -file mumps.dat":parse)::"pipe"
	write "open a:(comm=""$/ integ -file mumps.dat"":parse)::""pipe""",!
	open a:(comm="$/ integ -file mumps.dat":parse)::"pipe"
	write "open a:(comm=""id -un | sed 's/'$user'/other/g'"":parse:readonly)::""pipe""",!
	open a:(comm="id -un | sed 's/'$user'/other/g'":parse:readonly)::"pipe"
	use a
	read x
	use $P
	write x,!
	close a
	write "open a:(comm=""/bin/cat | nl"":parse)::""pipe""",!
	open a:(comm="/bin/cat | nl":parse)::"pipe"
	use a
	write "one",!
	write /eof
	read x
	use $P
	write x,!
	close a
	write "open a:(comm=""/bin/cat|&nl"":parse)::""pipe""",!
	open a:(comm="/bin/cat|&nl":parse)::"pipe"
	use a
	write "one",!
	write /eof
	read x
	use $P
	write x,!
	close a
	write "open a:(comm=""/bin/cat|&zznl"":parse)::""pipe""",!
	open a:(comm="/bin/cat|&zznl":parse:write)::"pipe"
	write "open a:(comm=""/bin/cat | zznl"":parse)::""pipe""",!
	open a:(comm="/bin/cat | zznl":parse:write)::"pipe"
	write "open a:(comm=""(cd; pwd)"":WRITEONLY:parse)::""pipe""",!
	open a:(comm="(cd; pwd)":WRITEONLY:parse)::"pipe"
	write "open a:(comm=""cd /usr/bin; pwd"":parse)::""pipe""",!
	open a:(comm="cd /usr/bin; pwd":parse)::"pipe"
	use a read x if "/usr/bin"=x use $p write "/usr/bin path verified",!
	close a
	write "open a:(comm=""echo """"(test)"""""":parse)::""pipe""",!
	open a:(comm="echo ""(test)""":parse)::"pipe"
	use a
	read x
	use $p
	write x,!
	close a
	write "open a:(comm=""tr -d '()'"":parse)::""pipe""",!
	open a:(comm="tr -d '()'":parse)::"pipe"
	use a
	write "(test)",!
	write /eof
	read x
	u $p
	write x,!
	close a
	set e="ERR"
	write "open a:(comm=""tr e j | echoback"":parse)::""pipe""",!
	open a:(comm="tr e j | echoback":STDERR=e:parse)::"pipe"
	use a
	write "one",!,"two",!
	write /eof
	read x
	use e
	read y
	use $p
	write x,!,y,!
	close a
	write "open a:(shell=""/usr/local/bin/tcsh"":comm=""/bin/cat |& nl"":parse)::""pipe""",!
	open a:(SHELL="/usr/local/bin/tcsh":comm="/bin/cat |& nl":parse)::"pipe"
	use a
	write "one",!,"two",!
	write /eof
	read x,y
	use $p
	write x,!,y,!
	close a
	write "open a:(comm=""mupip integ -file mumps.dat"":parse)::""pipe""",!
	open a:(comm="mupip integ -file mumps.dat":parse)::"pipe"
	use a
	read x,x
	use $p
	write x,!
	close a
	write "open a:(comm=""$gtm_dist/mupip integ -file mumps.dat"":parse)::""pipe""",!
	open a:(comm="$gtm_dist/mupip integ -file mumps.dat":parse)::"pipe"
	use a
	read x,x
	use $p
	write x,!
	close a
	write "open a:(comm=""nohup cat"":parse)::""pipe""",!
	open a:(comm="nohup cat":parse)::"pipe"
	use a
	write "one",!
	read x
	use $p
	write x,!
	close a
	quit
