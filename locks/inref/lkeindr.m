lkeindr	;Test indirection in lock arguments
	w !,"Test indirection in lock",!
	Set fncnt=0
	l
	s a234567890123456789012345678901="^a"
	set a234567890="^someotherglobal"
	l @a234567890123456789012345678901
	zshow "L":x
	do LKEEXAM(0,"^a",".",".",1)
	do EXAM(0,"LOCK ^a LEVEL=1",x("L",1))
	l @"^b"
	zshow "L":x
	do LKEEXAM(1,"^b",".",".",1)
	do EXAM(1,"LOCK ^b LEVEL=1",x("L",1))
	s a234567890123456789012345678901="(^a,^b,^c)"
	set a234567890="^someotherglobal"
	l @a234567890123456789012345678901
	zshow "L":x
	do LKEEXAM(2,"^a","^b","^c",3)
	do EXAM(2,"LOCK ^c LEVEL=1",x("L",1))
	do EXAM(3,"LOCK ^b LEVEL=1",x("L",2))
	do EXAM(4,"LOCK ^a LEVEL=1",x("L",3))
	s a="^a"
	l @a:10
	w:'$T "$T is false for l @a:10, a=^a",!
	zshow "L":x
	do LKEEXAM(5,"^a",".",".",1)
	do EXAM(5,"LOCK ^a LEVEL=1",x("L",1))
	l @"^b":10
	w:'$T "$T is false for l @""^b"":10",!
	zshow "L":x
	do LKEEXAM(6,"^b",".",".",1)
	do EXAM(6,"LOCK ^b LEVEL=1",x("L",1))
	s b="@a"
	l @b:10
	w:'$T "$T is false for l @b:10, b=@a a=^a",!
	zshow "L":x
	do LKEEXAM(7,"^a",".",".",1)
	do EXAM(7,"LOCK ^a LEVEL=1",x("L",1))
	s b="@a"
	s a="^a(@c)"
	s c="d"
	s d=1
	l @b:10
	w:'$T "$T is false for l @b:10, b=@a a=^a(@c) c=d d=1",!
	zshow "L":x
	do LKEEXAM(8,"^a(1)",".",".",1)
	do EXAM(8,"LOCK ^a(1) LEVEL=1",x("L",1))
	s a="^a"
	l +@a:10
	w:'$T "$T is false for l +@a:10, a=^a",!
	zshow "L":x
	do LKEEXAM(9,"^a","^a(1)",".",2)
	do EXAM(9,"LOCK ^a LEVEL=1",x("L",1))
	do EXAM(10,"LOCK ^a(1) LEVEL=1",x("L",2))
	s a="^a"
	l +@a:10
	w:'$T "$T is false for l +@a:10, a=^a",!
	zshow "L":x
	do LKEEXAM(11,"^a","^a(1)",".",2)
	do EXAM(11,"LOCK ^a LEVEL=2",x("L",1))
	do EXAM(12,"LOCK ^a(1) LEVEL=1",x("L",2))

	s a="^a"
	l -@a:10
	w:'$T "$T is false for l -@a:10, a=^a",!
	zshow "L":x
	do LKEEXAM(13,"^a","^a(1)",".",2)
	do EXAM(13,"LOCK ^a LEVEL=1",x("L",1))
	do EXAM(14,"LOCK ^a(1) LEVEL=1",x("L",2))
	l



	s a="^a"
	za @a
	do LKEEXAM(15,"^a",".",".",1)
	zshow "L":x zd
	do EXAM(15,"ZAL ^a",x("L",1))
	za @"^b"
	do LKEEXAM(16,"^b",".",".",1)
	zshow "L":x zd
	do EXAM(16,"ZAL ^b",x("L",1))
	s a="(^a,^b,^c)"
	za @a
	do LKEEXAM(17,"^a","^b","^c",3)
	zshow "L":x zd
	do EXAM(17,"ZAL ^c",x("L",1))
	do EXAM(18,"ZAL ^b",x("L",2))
	do EXAM(19,"ZAL ^a",x("L",3))
	s a="^a"
	za @a:10
	w:'$T "$T is false for za @a:10, a=^a",!
	do LKEEXAM(20,"^a",".",".",1)
	zshow "L":x zd
	do EXAM(20,"ZAL ^a",x("L",1))
	za @"^b":10
	w:'$T "$T is false for za @""^b"":10",!
	do LKEEXAM(21,"^b",".",".",1)
	zshow "L":x zd
	do EXAM(21,"ZAL ^b",x("L",1))
	s b="@a"
	za @b:10
	w:'$T "$T is false for za @b:10, b=@a a=^a",!
	do LKEEXAM(22,"^a",".",".",1)
	zshow "L":x zd
	do EXAM(22,"ZAL ^a",x("L",1))
	s b="@a"
	s a="^a(@c)"
	s c="d"
	s d=1
	za @b:10
	w:'$T "$T is false for za @b:10, b=@a a=^a(@c) c=d d=1",!
	zshow "L":x
	do LKEEXAM(23,"^a(1)",".",".",1)
	do EXAM(23,"ZAL ^a(1)",x("L",1))
	zd
	q

EXAM(lbl,corr,comp)
	i corr=comp  w !,lbl,"   GTM PASS"  q
	w lbl,"   GTM FAIL"
	w !,"   GTM CORRECT =",corr
	w !,"   GTM COMPUTED=",comp
	q

LKEEXAM(k,e0,e1,e2,lcnt)
	Set fncnt=fncnt+1
	set fname="lkeindr"_fncnt_".out"
	set cnt=0
	set unix=$zv'["VMS"
	set y="Owned by PID"
	if unix do
	.  SET zscmd="zsystem ""$LKE show -all -OUTPUT="_fname_"; $convert_to_gtm_chset "_fname_""""
	.  x zscmd
	.  set x="which is an existing process"
	else  do
	.  SET zscmd="zsystem ""pipe $LKE show /all 2>"_fname_" > "_fname_""""
	.  x zscmd
	.  set x="which is"

	set line="----"
	open fname:(READONLY)
	use fname  
	if e0=".",e1=".",e2="." do
	.  for  quit:line["DEFAULT"!$ZEOF  read line 
	.  close fname
	.  if line["%GTM-I-NOLOCKMATCH, No matching locks were found in" w !,k,"   LKE PASS" 
	.  else  w !,k,"   LKE FAIL ",line,!  
	.  q
	else  do
	.  for  quit:line["DEFAULT"!$ZEOF  read line
	.  if line'["DEFAULT" close fname   w !,k,"Check REGION"  q
	.  if unix,'($ZEOF) read line  
	.  if $find(line,e0)=$length(e0)+1,line[y,line[x set cnt=cnt+1
	.  if '($ZEOF) read line  if $find(line,e1)=$length(e1)+1,line[y,line[x set cnt=cnt+1
	.  if '($ZEOF) read line  if $find(line,e2)=$length(e2)+1,line[y,line[x set cnt=cnt+1
	.  close fname
	.  if lcnt=cnt w !,k,"   LKE PASS"
	.  else  w !,k,"   LKE FAIL" zwrite
	q 
