rand    ; call with: r count offset
	; will return count numbers that are $R(r)
	; will return $R(r) + offset
	set unix=$ZVersion'["VMS"
	set inp=$ZCMDLINE
	set r=$P(inp," ",1),count=$P(inp," ",2),offset=$P(inp," ",3),rand=""
	if ""=count set count=1
	for i=1:1:count d
	. if 0=r set rand=rand_" "_0
	. else  set rand=rand_" "_($R(r)+offset)
	if unix write rand,! q
	set fn="rand_tmp.com"
	open fn close fn:delete open fn use fn 
	write "$ rand :== ",rand,!
	close fn
	quit
