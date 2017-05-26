	; do I need to use VIEW "NOBADCHAR" to load these triggers?
	; apparently not

trigbadchar
	do badchargvn
	if $data(^debug) set a=$ztrigger("s")
	do badchartrigname
	if $data(^debug) set a=$ztrigger("s")
	do badcharcmd
	if $data(^debug) set a=$ztrigger("s")
	do badchardelim
	if $data(^debug) set a=$ztrigger("s")
	do badcharxecute
	if $data(^debug) set a=$ztrigger("s")
	do badcharselect
	if $data(^debug) set a=$ztrigger("s")
	do badcharcli
	if $data(^debug) set a=$ztrigger("s")

	do ^echoline
	kill ^fired
	set ^a=$ztrigger("s")
	zwrite ^fired

	do ^echoline
	write "Run time test",!
	kill ^fired
	set ^a=1111
	zwrite ^fired

	do ^echoline
	quit

writescript(line)
	use file
	write line,!
	write !,"echo ''; $echoline",!
	use $p
	quit

item(item,prediction)
	do ztrigger("item",item,prediction)
	quit

select(item,prediction)
	do ztrigger("select",item,prediction)
	quit

ztrigger(cmd,item,prediction)
	set x=$ztrigger(cmd,item)
	if x=prediction write ?63,"PASS",!
	else  write ?63,"FAIL",!
	quit

badchargvn
	do ^echoline
	write "Testing bad characters in the Global Variable Name",!,!

	; Unicode in the GVN (wrong by default)
	write "Use unicode in the GVN",!
	do item("+^a"_$char(2407)_" -commands=SET -xecute=""do mrtn^trigbadchar"" -name=badchargvn",0)

	; High 127 in GVN (wrong by default)
	write !,"Use high 127 character in the GVN",!
	do item("+^a"_$zchar(224)_" -commands=SET -xecute=""do mrtn^trigbadchar"" -name=badcharbytegvn",0)
	do item("+^a"_$zchar(224)_"z -commands=SET -xecute=""do mrtn^trigbadchar"" -name=badcharbytegvn",0)

	; High 127 in subscripts
	write !,"Use high 127 character in the GVN subscript",!
	do item("+^a"_$zchar(40,34,224,165,34,41)_" -commands=SET -xecute=""do mrtn^trigbadchar"" -name=badcharsubscript",1)

	write !,"Use high 127 character without quotes in the GVN subscript",!
	do item("+^a"_$zchar(40,224,165,41)_" -commands=SET -xecute=""do mrtn^trigbadchar"" -name=badcharnakedsubscript",0)

	write !,"SELECT with unicode in the GVN",!
	do select("^a"_$char(2409),0)
	write !,"SELECT with a high 127 character in the GVN",!
	do select("^a"_$zchar(224),0)
	do select("^a"_$zchar(224)_"z",0)


	do ^echoline
	quit

badchartrigname
	do ^echoline
	write "Testing bad characters in the Trigger Name",!

	write !,"Use unicode in the trigger name",!
	do item("+^a -commands=SET -xecute=""do mrtn^trigbadchar set fail=0"" -name=badtrignamefail"_$char(2407)_"bbb",0)

	write !,"Use high 127 character in the trigger name",!
	do item("+^a -commands=SET -xecute=""do mrtn^trigbadchar set fail=1"" -name=badtrignamepass"_$zchar(224,161)_"ccc",1)
	write "Add another trigger to use in a delete by name",!
	do item("+^a -commands=SET -xecute=""do mrtn^trigbadchar set fail=2"" -name=badtrignamepass"_$zchar(224,161)_"ddd",1)

	write !,"SELECT with the bogus name",!
	do select("badtrignamefail"_$char(2407)_"bbb",0)
	do select("badtrignamepass"_$zchar(224,161)_"ccc",0)
	do select("badtrignamepass"_$zchar(224,161)_"ddd",0)

	write !,"SELECT with an asterix",!
	do select("badtrigname*",1)

	write !,"Use unicode in the trigger name and try to DELETE",!
	do item("-^a -commands=SET -xecute=""do mrtn^trigbadchar set fail=0"" -name=badtrignamefail"_$char(2407)_"bbb",0)

	write !,"Use high 127 character in the trigger name and try to DELETE",!
	do item("-^a -commands=SET -xecute=""do mrtn^trigbadchar set fail=1"" -name=badtrignamepass"_$zchar(224,161)_"ccc",1)
	write "DELETE trigger by name",!
	do item("-badtrignamepass"_$zchar(224,161)_"ddd",0)

	do ^echoline
	quit

badcharcmd
	do ^echoline
	write "Testing bad characters in the COMMAND",!,!

	write "Use unicode in the trigger command",!
	do item("+^a -commands=S,"_$char(2407)_" -xecute=""set x=1"" -name=badcharcmd"_$incr(badcharcmd),0)
	do item("-^a -commands=S,"_$char(2407)_" -xecute=""set x=1"" -name=badcharcmd"_badcharcmd,0)

	write "Use high 127 character in the trigger command",!
	do item("+^a -commands=S,"_$zchar(224,161)_" -xecute=""set x=2"" -name=badcharcmd"_$incr(badcharcmd),0)
	do item("-^a -commands=S,"_$zchar(224,161)_" -xecute=""set x=2"" -name=badcharcmd"_badcharcmd,0)

	write "Use unicode in the trigger command",!
	write "Even without comma the unicode char is rejected",!
	do item("+^a -commands=S"_$char(2407)_" -xecute=""set x=3"" -name=badcharcmd"_$incr(badcharcmd),0)
	do item("-^a -commands=S"_$char(2407)_" -xecute=""set x=3"" -name=badcharcmd"_badcharcmd,0)

	write "Use high 127 character in the trigger command",!
	write "Without comma the bad char gets silently dropped",!
	do item("+^a -commands=S"_$zchar(224,161)_" -xecute=""set x=4"" -name=badcharcmd"_$incr(badcharcmd),1)
	do item("-^a -commands=S"_$zchar(224,161)_" -xecute=""set x=4"" -name=badcharcmd"_badcharcmd,1)

	do ^echoline
	quit

	; badchar in the delimiter
badchardelim
	do ^echoline
	write "Testing bad characters in the DELIMITER.",!
	write "This always works because the delimiter can contain anything",!
	write "In each test, we add and delete the same trigger with the weird delimiter",!

	write !,"Use unicode in the DELIM",!
	do item("+^a -commands=SET -xecute=""do mrtn^trigbadchar s d=1"" -name=badchardelim -delim="_$char(34,224,34),1)
	do item("-^a -commands=SET -xecute=""do mrtn^trigbadchar s d=1"" -name=badchardelim -delim="_$char(34,224,34),1)

	write !,"Use high 127 character in the DELIM",!
	do item("+^a -commands=SET -xecute=""do mrtn^trigbadchar s d=2"" -name=badzchardelim -delim="_$zchar(34,224,171,34),1)
	do item("-^a -commands=SET -xecute=""do mrtn^trigbadchar s d=2"" -name=badzchardelim -delim="_$zchar(34,224,171,34),1)

	write !,"Use high 127 character in the zDELIM",!
	do item("+^a -commands=SET -xecute=""do mrtn^trigbadchar s d=3"" -name=badzcharzdelim -zdelim="_$zchar(34,224,165,34),1)
	do item("-^a -commands=SET -xecute=""do mrtn^trigbadchar s d=3"" -name=badzcharzdelim -zdelim="_$zchar(34,224,165,34),1)

	write !,"Use unicode in the zDELIM",!
	do item("+^a -commands=SET -xecute=""do mrtn^trigbadchar s d=4"" -name=badcharzdelim -zdelim="_$char(34,253,34),1)
	do item("-^a -commands=SET -xecute=""do mrtn^trigbadchar s d=4"" -name=badcharzdelim -zdelim="_$char(34,253,34),1)

	do ^echoline
	quit

	; badchar in the xecute string
badcharxecute
	do ^echoline
	write "Testing bad characters in the XECUTE",!
	write "dropping in random bytes into the spec get silently discarded, so these pass",!
	write !

	set addspec="+^a -commands=SET -xecute="
	set delspec="-^a -commands=SET -xecute="
	set trigcmn="""do mrtn^trigbadchar"
	set name=" -name=disappearingbadchar"

	write "Use unicode in the XECUTE string without quotes",!
	do item(addspec_trigcmn_" set x="_$char(224)_" write x,!"" -name=goodcharxecute",0)

	write !,"Use high 127 character in the XECUTE string",!
	write "In each test, we add and delete the same trigger with the stray bytes"
	do item(addspec_trigcmn_" set x="_$zchar(34,34,224,34,34)_" write x,!"""_name_$incr(disappear),1)
	do item(addspec_trigcmn_" set x="_$zchar(224)_"99 write x,!"""_name_$incr(disappear),1)
	do item(delspec_trigcmn_" set x="_$zchar(224)_"99 write x,!"""_name_disappear,1)

	do item(addspec_trigcmn_" write "_$zchar(224)_"!"""_name_$incr(disappear),1)
	do item(delspec_trigcmn_" write "_$zchar(224)_"!"""_name_disappear,1)

	do item(addspec_"""do mrtn^trig"_$zchar(224)_"badchar write !"""_name_$incr(disappear),1)
	do item(delspec_"""do mrtn^trig"_$zchar(224)_"badchar write !"""_name_disappear,1)

	write !,"Use high 127 character in the XECUTE string without quotation marks",!
	write "Leave this trigger in to see the trigger hit a badchar during the run time test",!
	do item(addspec_trigcmn_" set x=$zchar(224,161) write x,! "" -name=badcharinxecute",1)

	do ^echoline
	quit

	; badchar in the select string
	; either part of a trigger name or part of the GVN
	; select has no variations for unicode because GVNs and names
	; are 7bit ASCII
badcharselect
	do ^echoline
	write "Use unicode in the GVN",!
	do select("^a"_$char(2407),0)

	write !,"Use high 127 character in the GVN",!
	do select("^a"_$zchar(224),0)

	write !,"Use unicode in the name",!
	do select("bad"_$char(2407),0)

	write !,"Use high 127 character in the name",!
	do select("bad"_$zchar(224),0)
	write !

	; Testing the mupip trigger -select command
	view "NOBADCHAR"
	set file="select.csh"
	open file:(newversion:chset="M")
	do writescript("echo ''| $MUPIP trigger -select='^a"_$char(2407)_"'")
	do writescript("echo ''| $MUPIP trigger -select='^a"_$zchar(224)_"'")
	do writescript("echo ''| $MUPIP trigger -select='bad"_$char(2407)_"'")
	do writescript("echo ''| $MUPIP trigger -select='bad"_$zchar(224)_"'")
	view "BADCHAR"
	close file
	zsystem "tcsh ./select.csh && rm select.csh"

	do ^echoline
	quit

	; badchar in the trigger spec cli options
badcharcli
	do ^echoline
	write "Testing bad characters placed in the CLI options",!
	write "dropping in random bytes into the spec get silently discarded, so most pass",!
	write "Since the CLI parser should treat badchars the same for each option,",!
	write "bad chars are placed right before and after the '-', right before the '=',",!
	write "in the middle of the opt and just as a stray character",!

	write !,"First test has no bad chars",!
	do item("+^a -commands=SET -xecute=""do mrtn^trigbadchar set x="_$incr(badcli)_""" -name=badcharcli"_badcli,1)

	write !,"bad char COMMAND - no bad chars",!
	do item("+^a -commands=SET -xecute=""do mrtn^trigbadchar set x="_$incr(badcli)_""" -name=badcharcli"_badcli,1)

	write !,"bad char XECUTE - bad char in front of '-'",!
	do item("+^a -commands=SET "_$zchar(224)_"-xecute=""do mrtn^trigbadchar set x="_$incr(badcli)_""" -name=badcharcli"_badcli,0)

	write !,"bad char NAME - bad char after the '-'",!
	do item("+^a -commands=SET -xecute=""do mrtn^trigbadchar set x="_$incr(badcli)_""" -"_$zchar(224)_"name=badcharcli"_badcli,1)

	write !,"bad char DELIM - bad char right before the '='",!
	do item("+^a -commands=SET -xecute=""do mrtn^trigbadchar set x="_$incr(badcli)_""" -delim"_$zchar(224)_"=$char(9) -name=badcharcli"_badcli,1)

	write !,"bad char PIECE - bad char in the middle the cli option",!
	do item("+^a -commands=SET -xecute=""do mrtn^trigbadchar set x="_$incr(badcli)_""" -delim=$char(9) -pie"_$zchar(224)_"ce=1 -name=badcharcli"_badcli,1)

	write !,"bad char OPTION - bad char as a stray byte in the cli",!
	do item("+^a -commands=SET -xecute=""do mrtn^trigbadchar set x="_$incr(badcli)_""" -option=i "_$zchar(224)_" -name=badcharcli"_badcli,0)
	write !

	do ^echoline
	quit


mrtn
	set ref=$reference
	; the stack currently points to this routine
	; drop down 2 more to get the trigger's name
	zshow "s":stack set ZTNAme=stack("S",2)
	set x=$select('$data(^fired(ZTNAme)):1,1:$length(^fired(ZTNAme),"|")+1)
	set $piece(^fired(ZTNAme),"|",x)="executions="_x_".$reference="_ref
	quit

