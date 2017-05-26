validnames 	; only valid M literals
	do ^echoline
	do initvalidchars^validnames
	write "Testing trigger names",!
	set file="names.trg"
	set maxlen=28
	write "Interleaved add, select and deletes for each line of names.trg",!,!
	; Create names.trg.  Write lines to
	;	add a trigger with a specific name
	;	delete the just added trigger by name
	; For each line written to the file call
	;	ITEM to add the named trigger
	;	SELECT by the trigger's name
	;	DELETE by the trigger's name
	if '$ztrigger("ITEM","-*")  write "Could not delete all triggers",$increment(del),!
	open file:newversion use file
	write "-*",!
	for i=1:1:4  do
	.	new line,name
	.	set line=$char(43,94,$$validcharindex(i))_" -command=S,K -xecute=""do ^mrtn"" -name="
	.	for li=1:1:maxlen  set $piece(name,"",li)=$$getvalid(li,$increment(vcharindex))
	.	set shortname=$extract(name,1,1+$random($length(name)-1))_$char(42)  ; delete with a wildcard
	.	use file
	.	write !,";;;;;;;;;;;;;;;;;;;;;;;;;;;;",!
	.	write "; Testing name=",name,!
	.	write line_name_$char(10)
	.	write "-"_name_$char(10)
	.	write line_name_$char(10)
	.	write "-"_shortname_$char(10)
	.	use $p
	.	do ^echoline
	.	write "load, select and delete by fullname",!
	.	if '$ztrigger("ITEM",line_name)      write "FAIL: ",line,name,!
	.	if '$ztrigger("SELECT",name)         write "FAIL: select",name,!
	.	if '$ztrigger("ITEM","-"_name)       write "FAIL: -",name,!
	.	write !,"load, select and delete by shortname with wildcard",!
	.	if '$ztrigger("ITEM",line_name)      write "FAIL: ",line,name,!
	.	if '$ztrigger("SELECT",shortname)    write "FAIL: select",shortname,!
	.	if '$ztrigger("ITEM","-"_shortname)  write "FAIL: -",shortname,!
	use $p close file
	; For the above you should see interleaved adds, selects and deletes
	; corresponding to each line of names.trg.
	; now use $ztrigger to load names.trg
	do ^echoline
	write "Use ztrigger to load names.trg",!,!
	; everything should have been deleted by now, but just to be sure
	if '$ztrigger("ITEM","-*")  write "FAIL: Could not delete all triggers",$increment(del),!
	if '$ztrigger("file",file)  write "FAIL: file ",file,!
	if '$ztrigger("SELECT")  write "FAIL: select",!
	; delete all loaded triggers so that we can use mupip trigger next
	if '$ztrigger("ITEM","-*")  write "FAIL: Could not delete all triggers",$increment(del),!
	do ^echoline
	write !
	quit

run
	do ^echoline
	write "Execute every installed trigger",!
	for i=1:1:52 do
	.	set gvn=$char(94,$$validcharindex(i))
	.	set @gvn=i
	do ^echoline
	quit

	; return the indicies of valid characters [A-Za-z] to use in $char for the GVN
validcharindex(index)
	new base,offset
	set base=$select((index+64)>90:97,1:64)
	set offset=index#27
	quit base+offset

getvalid(posn,index)
	if posn=1 set index=(index#53)+1	; first char 1-53, [%A-Za-z]
	else  set index=(index#62)+2		; other chars 2-63, [A-Za-z0-9]
	quit vchar(index)

	; this is a future addition to use random characters in the test
	; the above option, getvalid, is better for reference files
getvalidrand(posn,index)
	new index
	if posn=1 set index=$random(52)+1	; first char 1-53, [%A-Za-z]
	if posn=2 set index=$random(51)+2	; second char 2-53, [A-Za-z]
	if posn>2 set index=$random(61)+2	; other chars 2-63, [A-Za-z0-9]
	quit vchar(index)
	
	; setup an array of valid M label characters
initvalidchars
	set vchar($increment(cindex))="%"
	for i=65:1:90,97:1:122,48:1:57 do
	. set vchar($increment(cindex))=$char(i)
	quit
