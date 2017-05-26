	; shrinks a file of long strings, printing the number of ALPHABETalphabet occurrences instead.
	; works on lines created by longstr.m (will not help other lines)
shrnkfil(file,outfile) ;
	set rem=""
	if $DATA(outfile) set output=outfile open output:(NEWVERSION) use output
	if '$DATA(outfile) set output=$PRINCIPAL
	open file:(REWIND)
	use file:WIDTH=1048576
	for i=1:1 use file read line quit:$zeof  d
	. use output
	. if $LENGTH(line) w $$shrnkstr(line),!
	close file
	if $DATA(outfile) use outfile
	quit
shrnkstr(str) ; convert "AB..Zab..zAB..Zab..zAB..Zab..u" to "<2_ALPHABETalphabets>AB..Zab..u"
	new (str)
	;set sep=$$^longstr(52) actually
	set sep="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	set lnlim=80
	set lsep=$LENGTH(sep)
	set lstr=$LENGTH(str)
	if 'lstr write ! quit
	;
	set unix=$ZVersion'["VMS"
	if unix do
	. ; The $LENGTH above would have already checked the UTF8 validity (if applicable) of "str" at this point so no need to
	. ; do it again and again. The $FIND/$EXTRACT usages below will keep revalidating so avoid that by setting VIEW "NOBADCHAR".
	. ; For long strings (1MB), the time taken below could exponentially rise (taking 10 minutes instead of 10 seconds) due to
	. ; the revalidation. Save current setting so it can be restored at end before we quit from this level.
	. set badcharstate=$view("BADCHAR") 
	. view "NOBADCHAR"
	;
	set count=0,fexp=1,resstr="",prevpt=1
	for subsc=1:lsep:lstr  d
	. set fexp=fexp+lsep
	. set fres=$FIND(str,sep,subsc)
	. if fres=fexp set count=count+1
	. else  d
	. . if count set resstr=resstr_"<"_count_"_ALPHABETalphabets>"
	. . s resstr=resstr_$EXTRACT(str,prevpt,fres-(lsep+1))
	. . if fres set fexp=fres-lsep,count=0,subsc=(fexp-lsep)
	. . else  set resstr=resstr_$EXTRACT(str,prevpt,lstr),subsc=lstr ; finished the string
	. set prevpt=fres
	;
	if unix do
	. ; restore BADCHAR setting to what it was at function entry
	. if badcharstate  view "BADCHAR"
	;
	if lnlim<$LENGTH(resstr) quit $EXTRACT(resstr,1,lnlim)_"<...length="_$LENGTH(resstr)_"...> "
	else  quit resstr
	quit "TEST-E-IMPOSSIBLE"
