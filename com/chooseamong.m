	; This M routine was written to simplify choosing among a set
	;
	; The default chooseamong or one^chooseamong will randomly choose one
	; of the commandline arguments and print it
chooseamong
one
	set options=$zcmdline
	set total=$length(options," ")
	set chosen=($random(total)+1)
	write $piece(options," ",chosen),!
	quit

	; choose some combination of all command line arguments. For instance
	; $gtm_exe/mumps -run all^chooseamong 1 2 3
	; may print the null set, one option, two options, or three options
all
	set options=$zcmdline
	set total=$length(options," ")
	set chosen=""
	for i=1:1:total set:$random(2)>0 $piece(chosen," ",$increment(j))=$piece(options," ",i)
	write chosen,!
	quit

	; $gtm_exe/mumps -run variable^chooseamong X 1 2 3 4
	; choose an unsorted combination of X values from the set of command line args
variable
	set options=$zcmdline
	set variable=$piece(options," ",1),$piece(options," ",1)="",$extract(options,1,1)=""
	set total=$length(options," ")+1
	if variable="all" set variable=$length(options," ")
	if variable="X" set variable=$random($length(options," "))+1
	set variable=+variable
	if variable<1 do
	.	write "TEST-W-WARN : the variable number of options is bogus, deciding randomly",!
	.	zwrite variable,$zcmdline
	.	set variable=$random(($length(options," ")+1))
	set chosen="",j=0
	for  quit:j=variable  do
	.	set opt=$random(total)
	.	quit:$piece(options," ",opt)=""
	.	set $piece(chosen," ",$increment(j))=$piece(options," ",opt)
	.	set $piece(options," ",opt)=""
	write chosen,!
	quit
