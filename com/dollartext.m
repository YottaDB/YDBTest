dollartext
	new label,file,arg
	set label=$piece($zcmdline," ",$increment(arg))
	set file=$piece($zcmdline," ",$increment(arg))
	if file'="" do text(label,file)
	if file="" do textmain(label)
	quit

	; wrap textmain with an output file to
	; write into.
text(labelrtn,outfile)
	open outfile:newversion
	use outfile
	do textmain(labelrtn)
	close outfile
	quit

	; this assumes that the inline text is at the
	; END of the M file or terminated by a quit.
	; double up the comments to push comments
	; into the file
textmain(labelrtn)
	new label,rtn,line,i
	set label=$piece(labelrtn,"^",1)_"+"
	set rtn="^"_$piece(labelrtn,"^",2)
	set line=labelrtn
	for i=1:1  quit:line=""  do
	. set target=label_i_rtn
	. set line=$text(@target)
	. if line=" quit" set line="" quit
	. if line'="" do untext(.line) write line,!
	quit

	; strip off the leading tab and semicolon
untext(line)
	set $extract(line,1,2)=""
	quit
