d002364(file,prefix)	;
	set unix=$zversion'["VMS"
	;
	; <file> which is opened by this routine comes from the test system and must be
	; tagged ASCII (outside the test system) for this test to work on OS390.
	;
	open file:(exception="QUIT:$ZEOF=1  ZSHOW ""*"" HALT")
	for  quit:$zeof=1  do
	.	use file
	.	read line
	.	use $p
	.	set type=$extract(line,1,1)
	.	if unix&((type="p")!(type="u"))  do unix
	.	if 'unix&((type="p")!(type="v")) do vvms
	.	if type="!" write line,!
	close file
	use $p
	quit
	;
unix	;
	set command=prefix_" "_$extract(line,2,9999)
	write "--------- Testing : "_command," ------------",!
	zsystem command
	quit
	;
vvms	;
	;
	new command,file,state,newcommand
	set command=$extract(line,2,9999)
	set command=$translate(command,"-","/")	; to transform unix command to be vvms like
	set state=1,newcommand=""
	for i=1:1:$length(command)  do
	.	set char=$extract(command,i,i)
	.	if char="""" do
	.	.	if state=1 set newcommand=newcommand_"(" set state=0
	.	.	else  set newcommand=newcommand_")" set state=1
	.	if char'="""" set newcommand=newcommand_char
	set command=newcommand
	write "--------- Testing : "_prefix_" "_command," ------------",!
	set file="zsystr.com"
	open file:newversion
	use file
	write "$ ",prefix,!
	write command,!
	write "$"
	close file
	zsystem "@zsystr.com"
	quit
