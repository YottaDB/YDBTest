lkesub0;	test for problem with evaluation of lock subscripts
	;
	set a=1,b=2,c=3,d=4
	set unix=$zv'["VMS"
	l  l ^x(+a),+^x(+b),+^y(+c),+^z(d)
	zsh "l":a
	do lkeexam()

	l  l (^x(+a),^x(+b),^y(+c),^z(d))
	zsh "l":b
	do lkeexam()

	l  set cnt=0
	s x=0 f  s x=$o(a("L",x)) q:x=""  i $g(b("L",x))'=a("L",x) s cnt=cnt+1
	s x=0 f  s x=$o(b("L",x)) q:x=""  i $g(a("L",x))'=b("L",x) s cnt=cnt+1
	if cnt=0 w !,"GTM PASS from ",$t(+0)
	else  w !,"GTM FAIL from ",$t(+0)
	q

lkeexam()
	set cnt=0
	set fname="temp.out",line="----"
	if unix zsystem "$LKE show -all -output="_fname_"; $convert_to_gtm_chset "_fname
	else  zsystem "pipe $LKE show /all 2>temp.out >temp.out"

	open fname:(READONLY)
	use fname
	for  quit:line["DEFAULT"!$ZEOF  read line
	if line'["DEFAULT" close fname   w !,k,"Check REGION"  q
	if unix,'($ZEOF) read line
	if (line'["x(1)")!(line'["Owned by PID") set cnt=cnt+1
	if '$ZEOF read line  if (line'["x(2)")!(line'["Owned by PID") set cnt=cnt+1
	if '$ZEOF read line  if (line'["y(3)")!(line'["Owned by PID") set cnt=cnt+1
	if '$ZEOF read line  if (line'["z(4)")!(line'["Owned by PID") set cnt=cnt+1
	close fname
	if cnt=0 w !,"LKE PASS from ",$t(+0)
	else  w !,"LKE FAIL from ",$t(+0)  zwrite
	q

