	; this was originally part of test/triggers/inref/validnames.m
invalidnames
	do initvalidchars^validnames
	do ^echoline
	set logfile="invalidnames.trg.trigout"
	open logfile:newversion
	;
	; use bad chars in the name alone
	write "Test -name for each -name=$c(i)",!
	do bad("badcharcheck","","")
	;
	; use bad chars in the name with a leading valid char
	use $p
	do ^echoline
	write "Test -name for each -name=A_$c(i)",!
	do bad("badleadcheck","A","")
	;
	; use bad chars in the name surrounded by valid chars
	use $p
	do ^echoline
	write "Test -name for each -name=A_$c(i)_a",!
	do bad("badbothcheck","A","a")
	;
	; use bad chars in the name with a trailing valid char
	use $p
	do ^echoline
	write "Test -name for each -name=$c(i)_a",!
	do bad("badtrailcheck","","a")
	;
	use $p
	do ^echoline
	write "Total triggers:",gvn,!
	quit

	; The cases below fail because they are considered "space"
	; characters which the parser considers as delimiters, and not
	; part of the trigger name
	; 011   9     09    HT  '\t' (horizontal tab)
	; 012   10    0A    LF  '\n' (new line)
	; 013   11    0B    VT  '\v' (vertical tab)
	; 014   12    0C    FF  '\f' (form feed)
	; 015   13    0D    CR  '\r' (carriage ret)
	; 040   32    20    SPACE
	;
	; The following fail because they have valid meanings
	; 052   42    2A    *    is valid for named delete and select
	; 205  133    85    ?    unicode next line
	; 240  160    A0    ?    unicode non breaking space
	;
	; The two variables lead and trail are prepended and
	; appended (respectively) to the trigger name.
	; Thus names are tested with the invalid characters as
	; 1. the first character of a name
	; 2. the last character of a name
	; 3. the only character of a name
	; 4. in the middle of a name
	; this gives us coverage of the errors and false negatives
bad(name,lead,trail)
	; all non-alphanumerics
	for i=1:1:254  do
	.	if i=48 set i=58	; skip the digits
	.	if i=65 set i=91	; skip upper case
	.	if i=97 set i=123	; skip lower case
	.	do gentrigfile(name,i,lead,trail)
	.	do useztrigger(i,lead,trail)
	use $p
	quit
	
	; generate a trigger file for use with MUPIP trigger
gentrigfile(name,iter,lead,trail)
	new file
	set file=name_iter_"add.trg"
	; do the trigger load first
	open file:newversion
	use file
	write "; Testing $char(",iter,") lead=[",lead,"] trail=[",trail,"]",!
	write "-*",!
	write $$trigline(iter,lead,trail)
	close file
	use logfile
	if $ztrigger("file",file)  do
	.	use $p 
	.	write "TFILE FAILED:  ",iter,$$escapedchar(43,iter,lead,trail),!
	;
	set file=name_iter_"rm.trg"
	open file:newversion
	use file
	write "; Testing removal $char(",iter,") lead=[",lead,"] trail=[",trail,"]",!
	write $$rmbyname(iter,lead,trail)
	close file
	use logfile ; force ztrigger output into the log file
	if $ztrigger("file",file)  do
	.	use $p
	.	write "TFILE FAILED:  ",iter,$$escapedchar(45,iter,lead,trail),!
	quit
	
	; Use $ztrigger to load the trigger with its funky name and
	; then try to unload it with its funky name
useztrigger(iter,lead,trail)
	; if the trigger load succeeds that is a failure
	; test the load with funky name
	use logfile ; force ztrigger output into the log file
	; delete all triggers in case a load succeeded
	set x=$ztrigger("i","-*")
	write "Doing ZTR   load:  ",iter,$$escapedchar(43,iter,lead,trail),!
	if $ztrigger("ITEM",$$trigline(iter,lead,trail))  do
	.	use $p
	.	write "ZTR   FAILED:  ",iter,$$escapedchar(43,iter,lead,trail),!
	; test the remove by name
	use logfile
	if $ztrigger("ITEM",$$rmbyname(iter,lead,trail))  do
	.	use $p
	.	write "ZTR   FAILED:  ",iter,$$escapedchar(45,iter,lead,trail),!
	quit

	; Create the add trigger line
trigline(iter,lead,trail)
	new line
	set line=$char(43,94,65)_$increment(gvn)
	set line=line_" -commands=S,K -xecute=""do ^mrtn"" -name="
	set line=line_lead_$char(iter,iter,iter)_trail_$char(10)
	quit line

	; Print the character sequence being tested. Don't print the
	; non-printing characters as they cause reference file problems
escapedchar(mode,iter,lead,trail)
	new localiter
	set localiter=iter
	if $char(iter)?1C set localiter=88
	set line=$char(9,mode,39)
	set line=line_lead
	set line=line_$char(localiter)
	set line=line_trail_$char(39)
	quit line

	; Create the remove by NAME line
rmbyname(iter,lead,trail)
	quit $char(45)_lead_$char(iter,iter,iter)_trail_$char(10)

run
	do ^echoline
	write "Execute every installed trigger",!
	; Skip " $C(34) and ( $C(40) because they cause GT.M errors
	for i=1:1:255 do
	.    set gvn=$char(94,65)_i
	.    set @gvn=i
	do ^echoline
	quit
